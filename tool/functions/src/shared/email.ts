import nodemailer from 'nodemailer';

export interface Email {
  to: string;
  /** Where replies go, when not to the sender. */
  replyTo?: string;
  subject: string;
  text: string;
  /** An iCalendar `REQUEST`, which mail apps show as an invite. */
  calendarInvite?: string;
}

export interface EmailSender {
  send(email: Email): Promise<void>;
}

export interface GmailAccount {
  /** The Gmail address the emails are sent from. */
  user: string;
  /** An app password of that account, not its sign-in password. */
  appPassword: string;
  /** The name shown as the sender. */
  senderName: string;
}

/** Sends from a Gmail account over SMTP. */
export function gmailEmailSender({
  user,
  appPassword,
  senderName,
}: GmailAccount): EmailSender {
  const transport = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: { user, pass: appPassword },
  });
  return {
    async send({ to, replyTo, subject, text, calendarInvite }) {
      await transport.sendMail({
        from: { name: senderName, address: user },
        to,
        replyTo,
        subject,
        text,
        icalEvent: calendarInvite
          ? {
              method: 'REQUEST',
              filename: 'invite.ics',
              content: calendarInvite,
            }
          : undefined,
      });
    },
  };
}
