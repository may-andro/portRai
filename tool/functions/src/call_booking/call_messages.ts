import { DateTime } from 'luxon';

import type { Email } from '../shared/email.js';
import type { PushNotification } from '../shared/messaging.js';
import type { CallBookingLanguage, CallRequest } from './call_request.js';

/** Tells the app what a tapped notification is about. */
export const callRequestKind = 'call_request';

/** The owner's name and address, from the portfolio profile. */
export interface CallOwner {
  name: string;
  email: string;
}

interface Texts {
  received: { subject: string; body: string };
  accepted: { subject: string; body: string };
  declined: { subject: string; body: string };
  ownerAccepted: { subject: string; body: string };
  newRequestTitle: string;
}

// {name}, {owner}, {topic}, {date}, {link}, {email} and {message} are
// replaced in every text.
const texts: Record<CallBookingLanguage, Texts> = {
  en: {
    received: {
      subject: 'Your call request with {owner}',
      body: 'Hi {name},\n\nThanks for booking a call about "{topic}" on {date}.\n\n{owner} will confirm the time by email soon.\n\n{owner}',
    },
    accepted: {
      subject: 'Your call with {owner} is confirmed',
      body: 'Hi {name},\n\nYour call about "{topic}" is confirmed for {date}.\n\nJoin here: {link}\n\nThe invite is attached, so you can add it to your calendar.\n\nSee you then,\n{owner}',
    },
    declined: {
      subject: 'About your call request',
      body: 'Hi {name},\n\nSorry, {owner} can\'t make the call about "{topic}" on {date}. You\'re welcome to pick another time on the portfolio.\n\nBest,\n{owner}',
    },
    ownerAccepted: {
      subject: 'Call with {name} confirmed',
      body: '{name} ({email}) about "{topic}" on {date}.\n\nMessage:\n{message}\n\nJoin here: {link}',
    },
    newRequestTitle: 'New call request',
  },
  es: {
    received: {
      subject: 'Tu solicitud de llamada con {owner}',
      body: 'Hola {name}:\n\nGracias por reservar una llamada sobre «{topic}» el {date}.\n\n{owner} te confirmará la hora por correo pronto.\n\n{owner}',
    },
    accepted: {
      subject: 'Tu llamada con {owner} está confirmada',
      body: 'Hola {name}:\n\nTu llamada sobre «{topic}» está confirmada para el {date}.\n\nÚnete aquí: {link}\n\nLa invitación va adjunta para que la añadas a tu calendario.\n\nHasta pronto,\n{owner}',
    },
    declined: {
      subject: 'Sobre tu solicitud de llamada',
      body: 'Hola {name}:\n\nLo siento, {owner} no puede atender la llamada sobre «{topic}» el {date}. Puedes elegir otra hora en el portfolio.\n\nUn saludo,\n{owner}',
    },
    ownerAccepted: {
      subject: 'Llamada con {name} confirmada',
      body: '{name} ({email}) sobre «{topic}» el {date}.\n\nMensaje:\n{message}\n\nÚnete aquí: {link}',
    },
    newRequestTitle: 'Nueva solicitud de llamada',
  },
  nl: {
    received: {
      subject: 'Je belverzoek bij {owner}',
      body: 'Hoi {name},\n\nBedankt voor het inplannen van een gesprek over ‘{topic}’ op {date}.\n\n{owner} bevestigt de tijd binnenkort per e-mail.\n\n{owner}',
    },
    accepted: {
      subject: 'Je gesprek met {owner} is bevestigd',
      body: 'Hoi {name},\n\nJe gesprek over ‘{topic}’ is bevestigd voor {date}.\n\nDoe hier mee: {link}\n\nDe uitnodiging zit in de bijlage, zodat je hem aan je agenda kunt toevoegen.\n\nTot dan,\n{owner}',
    },
    declined: {
      subject: 'Over je belverzoek',
      body: 'Hoi {name},\n\nHelaas kan {owner} het gesprek over ‘{topic}’ op {date} niet doen. Je kunt een ander tijdstip kiezen in het portfolio.\n\nGroeten,\n{owner}',
    },
    ownerAccepted: {
      subject: 'Gesprek met {name} bevestigd',
      body: '{name} ({email}) over ‘{topic}’ op {date}.\n\nBericht:\n{message}\n\nDoe hier mee: {link}',
    },
    newRequestTitle: 'Nieuw belverzoek',
  },
};

/** [start] in [timeZone] and [language], such as "Tuesday, November 3, 2026 at 9:00 AM GMT+1". */
export function callTime(
  start: Date,
  timeZone: string,
  language: CallBookingLanguage,
): string {
  return DateTime.fromJSDate(start)
    .setZone(timeZone)
    .setLocale(language)
    .toLocaleString({
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
      timeZoneName: 'short',
    });
}

function fill(template: string, values: Record<string, string>): string {
  return template.replace(/\{(\w+)\}/g, (placeholder, key: string) =>
    key in values ? values[key] : placeholder,
  );
}

type VisitorEmailKind = 'received' | 'accepted' | 'declined';

/**
 * The email to the visitor of [request], in their language, with the time in
 * their time zone, or the owner's when they sent none.
 */
export function visitorEmail(
  kind: VisitorEmailKind,
  request: CallRequest,
  owner: CallOwner,
  ownerTimeZone: string,
  meetingLink: string,
): Email {
  const { subject, body } = texts[request.language][kind];
  const values = {
    name: request.name,
    owner: owner.name,
    topic: request.topic,
    date: callTime(
      request.slotStart,
      request.timeZone ?? ownerTimeZone,
      request.language,
    ),
    link: meetingLink,
  };
  return {
    to: request.email,
    replyTo: owner.email,
    subject: fill(subject, values),
    text: fill(body, values),
  };
}

/** The confirmation to the owner of an accepted [request], in English. */
export function ownerAcceptedEmail(
  request: CallRequest,
  owner: CallOwner,
  ownerTimeZone: string,
  meetingLink: string,
): Email {
  const { subject, body } = texts.en.ownerAccepted;
  const values = {
    name: request.name,
    email: request.email,
    topic: request.topic,
    message: request.message === '' ? '-' : request.message,
    date: callTime(request.slotStart, ownerTimeZone, 'en'),
    link: meetingLink,
  };
  return {
    to: owner.email,
    replyTo: request.email,
    subject: fill(subject, values),
    text: fill(body, values),
  };
}

/** The notification to the owner's devices about a new [request]. */
export function newCallRequestNotification(
  language: string,
  request: CallRequest,
  ownerTimeZone: string,
): PushNotification {
  const deviceLanguage =
    language in texts ? (language as CallBookingLanguage) : 'en';
  return {
    title: texts[deviceLanguage].newRequestTitle,
    body: `${request.name} · ${callTime(request.slotStart, ownerTimeZone, deviceLanguage)}`,
    data: { kind: callRequestKind, requestId: request.id },
    group: `${callRequestKind}_${request.id}`,
  };
}
