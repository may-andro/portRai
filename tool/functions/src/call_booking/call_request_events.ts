import type { EmailSender } from '../shared/email.js';
import {
  notifyUserDevices,
  type UserDeviceNotifier,
} from '../shared/user_devices.js';
import type { CallBookingSettings } from './call_booking_settings.js';
import { callInviteCalendar } from './call_invite.js';
import {
  type CallOwner,
  newCallRequestNotification,
  ownerAcceptedEmail,
  visitorEmail,
} from './call_messages.js';
import { type CallRequest, callBookingLanguages } from './call_request.js';
import { callSlotId } from './call_slots.js';

export interface CallRequestEventDependencies {
  loadSettings(): Promise<CallBookingSettings | null>;
  /** The owner's name and address, or null when the profile has none. */
  loadOwner(): Promise<CallOwner | null>;
  emailSender: EmailSender;
  devices: UserDeviceNotifier;
  /** Frees the slot [slotId] when [requestId] still holds it. */
  releaseSlot(slotId: string, requestId: string): Promise<void>;
}

export type CallRequestStep =
  'owner_notification' | 'visitor_email' | 'owner_email' | 'release_slot';

export type CallRequestEventOutcome =
  | { kind: 'not_set_up' }
  | { kind: 'handled'; failures: { step: CallRequestStep; error: unknown }[] };

/** Runs every step, even when one fails, and returns the steps that failed. */
async function runSteps(
  steps: [CallRequestStep, () => Promise<unknown>][],
): Promise<CallRequestEventOutcome> {
  const results = await Promise.allSettled(steps.map(([, run]) => run()));
  const failures = results.flatMap((result, index) =>
    result.status === 'rejected'
      ? [{ step: steps[index][0], error: result.reason }]
      : [],
  );
  return { kind: 'handled', failures };
}

async function loadContext(
  deps: CallRequestEventDependencies,
): Promise<{ settings: CallBookingSettings; owner: CallOwner } | null> {
  const [settings, owner] = await Promise.all([
    deps.loadSettings(),
    deps.loadOwner(),
  ]);
  return settings === null || owner === null ? null : { settings, owner };
}

/** Tells the owner's devices about a new [request] and the visitor that it is in. */
export async function handleNewCallRequest(
  deps: CallRequestEventDependencies,
  ownerId: string,
  request: CallRequest,
): Promise<CallRequestEventOutcome> {
  const context = await loadContext(deps);
  if (context === null) return { kind: 'not_set_up' };
  const { settings, owner } = context;
  return runSteps([
    [
      'owner_notification',
      () =>
        notifyUserDevices(
          deps.devices,
          ownerId,
          callBookingLanguages,
          (language) =>
            newCallRequestNotification(language, request, settings.timeZone),
        ),
    ],
    [
      'visitor_email',
      () =>
        deps.emailSender.send(
          visitorEmail(
            'received',
            request,
            owner,
            settings.timeZone,
            settings.meetingLink,
          ),
        ),
    ],
  ]);
}

export type CallRequestDecision = 'accepted' | 'declined';

/** The owner's answer when [before] waited for one and [after] has it, else null. */
export function callRequestDecision(
  before: CallRequest | null,
  after: CallRequest | null,
): CallRequestDecision | null {
  if (before?.status !== 'requested' || after === null) return null;
  return after.status === 'requested' ? null : after.status;
}

/**
 * Sends the invite to the visitor and the owner when the owner accepted
 * [request], or tells the visitor and frees the slot when they declined it.
 */
export async function handleCallRequestDecision(
  deps: CallRequestEventDependencies,
  decision: CallRequestDecision,
  request: CallRequest,
  now: Date,
): Promise<CallRequestEventOutcome> {
  const context = await loadContext(deps);
  if (context === null) return { kind: 'not_set_up' };
  const { settings, owner } = context;
  const { timeZone, meetingLink } = settings;
  if (decision === 'declined') {
    return runSteps([
      [
        'release_slot',
        () => deps.releaseSlot(callSlotId(request.slotStart), request.id),
      ],
      [
        'visitor_email',
        () =>
          deps.emailSender.send(
            visitorEmail('declined', request, owner, timeZone, meetingLink),
          ),
      ],
    ]);
  }
  const calendarInvite = callInviteCalendar({
    uid: `${request.id}@portrai`,
    start: request.slotStart,
    end: request.slotEnd,
    summary: `${owner.name} / ${request.name}: ${request.topic}`,
    description: `${request.topic}\n\n${meetingLink}`,
    location: meetingLink,
    organizer: owner,
    attendee: { name: request.name, email: request.email },
    createdAt: now,
  });
  return runSteps([
    [
      'visitor_email',
      () =>
        deps.emailSender.send({
          ...visitorEmail('accepted', request, owner, timeZone, meetingLink),
          calendarInvite,
        }),
    ],
    [
      'owner_email',
      () =>
        deps.emailSender.send({
          ...ownerAcceptedEmail(request, owner, timeZone, meetingLink),
          calendarInvite,
        }),
    ],
  ]);
}
