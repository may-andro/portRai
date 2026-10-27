/** A person in an invite. */
export interface InvitePerson {
  name: string;
  email: string;
}

export interface CallInvite {
  /** Stays the same for one call, so a calendar updates instead of duplicating it. */
  uid: string;
  start: Date;
  end: Date;
  summary: string;
  description: string;
  /** The meeting link. */
  location: string;
  organizer: InvitePerson;
  attendee: InvitePerson;
  createdAt: Date;
}

/** A UTC time as iCalendar writes it, such as `20261103T090000Z`. */
function icalTime(date: Date): string {
  return date
    .toISOString()
    .replace(/[-:]/g, '')
    .replace(/\.\d{3}/, '');
}

/** Escapes the characters iCalendar text values reserve. */
function icalText(value: string): string {
  return value
    .replace(/\\/g, '\\\\')
    .replace(/;/g, '\;')
    .replace(/,/g, '\\,')
    .replace(/\r?\n/g, '\\n');
}

/** A quoted parameter value, which may not hold double quotes or line breaks. */
function icalParameter(value: string): string {
  return `"${value.replace(/["\r\n]/g, '')}"`;
}

/** Splits [line] into lines of at most 75 bytes, each continued with a space. */
function fold(line: string): string {
  const parts: string[] = [];
  let current = '';
  let currentBytes = 0;
  for (const character of line) {
    const bytes = Buffer.byteLength(character);
    const limit = parts.length === 0 ? 75 : 74;
    if (currentBytes + bytes > limit) {
      parts.push(current);
      current = '';
      currentBytes = 0;
    }
    current += character;
    currentBytes += bytes;
  }
  parts.push(current);
  return parts.join('\r\n ');
}

/** The invite as an iCalendar `REQUEST`, which calendar apps offer to add. */
export function callInviteCalendar(invite: CallInvite): string {
  const { organizer, attendee } = invite;
  const lines = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//PortRai//Call booking//EN',
    'CALSCALE:GREGORIAN',
    'METHOD:REQUEST',
    'BEGIN:VEVENT',
    `UID:${invite.uid}`,
    `DTSTAMP:${icalTime(invite.createdAt)}`,
    `DTSTART:${icalTime(invite.start)}`,
    `DTEND:${icalTime(invite.end)}`,
    `SUMMARY:${icalText(invite.summary)}`,
    `DESCRIPTION:${icalText(invite.description)}`,
    `LOCATION:${icalText(invite.location)}`,
    `URL:${invite.location}`,
    `ORGANIZER;CN=${icalParameter(organizer.name)}:mailto:${organizer.email}`,
    `ATTENDEE;CN=${icalParameter(attendee.name)};ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE:mailto:${attendee.email}`,
    'STATUS:CONFIRMED',
    'SEQUENCE:0',
    'END:VEVENT',
    'END:VCALENDAR',
  ];
  return lines.map(fold).join('\r\n') + '\r\n';
}
