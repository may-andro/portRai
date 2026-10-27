import { DateTime } from 'luxon';

import {
  type CallBookingSettings,
  minutesOfDay,
  weekdays,
} from './call_booking_settings.js';

/** The ID of the slot starting at [start], such as `2026-11-03T09:00:00.000Z`. */
export function callSlotId(start: Date): string {
  return start.toISOString();
}

/**
 * The start of every slot in the owner's weekly hours from [now] plus the
 * notice to the end of the horizon, earliest first. Slots whose ID is in
 * [takenSlotIds] are left out, and so are local times that a daylight saving
 * change skips.
 */
export function openCallSlots(
  settings: CallBookingSettings,
  now: Date,
  takenSlotIds: ReadonlySet<string> = new Set(),
): Date[] {
  const { timeZone, slotMinutes, minNoticeHours, horizonDays } = settings;
  const earliest = now.getTime() + minNoticeHours * 60 * 60 * 1000;
  const today = DateTime.fromJSDate(now).setZone(timeZone).startOf('day');
  const slotsById = new Map<string, Date>();
  for (let dayIndex = 0; dayIndex < horizonDays; dayIndex++) {
    const day = today.plus({ days: dayIndex });
    const weekday = weekdays[day.weekday - 1];
    for (const { start, end } of settings.weeklyHours[weekday]) {
      const endMinutes = minutesOfDay(end);
      for (
        let startMinutes = minutesOfDay(start);
        startMinutes + slotMinutes <= endMinutes;
        startMinutes += slotMinutes
      ) {
        const slot = day.set({
          hour: Math.floor(startMinutes / 60),
          minute: startMinutes % 60,
        });
        if (slot.hour * 60 + slot.minute !== startMinutes) continue;
        if (slot.toMillis() < earliest) continue;
        const slotStart = slot.toJSDate();
        const slotId = callSlotId(slotStart);
        if (!takenSlotIds.has(slotId)) slotsById.set(slotId, slotStart);
      }
    }
  }
  return [...slotsById.values()].sort(
    (first, second) => first.getTime() - second.getTime(),
  );
}

/** Whether a slot starts at [start] in the weekly hours, taken or not. */
export function isCallSlot(
  settings: CallBookingSettings,
  now: Date,
  start: Date,
): boolean {
  return openCallSlots(settings, now).some(
    (slot) => slot.getTime() === start.getTime(),
  );
}
