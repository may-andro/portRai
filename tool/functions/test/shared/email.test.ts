import { beforeEach, describe, expect, it, vi } from 'vitest';

import { gmailEmailSender } from '../../src/shared/email.js';

const { sendMail, createTransport } = vi.hoisted(() => {
  const sendMail = vi.fn().mockResolvedValue({});
  return { sendMail, createTransport: vi.fn(() => ({ sendMail })) };
});

vi.mock('nodemailer', () => ({ default: { createTransport } }));

const account = {
  user: 'sender@gmail.com',
  appPassword: 'app-password',
  senderName: 'Sender',
};

describe('gmailEmailSender', () => {
  beforeEach(() => {
    sendMail.mockClear();
    createTransport.mockClear();
  });

  it('should sign in to Gmail over TLS with the app password', () => {
    gmailEmailSender(account);

    expect(createTransport).toHaveBeenCalledWith({
      host: 'smtp.gmail.com',
      port: 465,
      secure: true,
      auth: { user: 'sender@gmail.com', pass: 'app-password' },
    });
  });

  it('should send from the account with the sender name', async () => {
    await gmailEmailSender(account).send({
      to: 'visitor@example.com',
      replyTo: 'owner@example.com',
      subject: 'Subject',
      text: 'Text',
    });

    expect(sendMail).toHaveBeenCalledWith({
      from: { name: 'Sender', address: 'sender@gmail.com' },
      to: 'visitor@example.com',
      replyTo: 'owner@example.com',
      subject: 'Subject',
      text: 'Text',
      icalEvent: undefined,
    });
  });

  it('should attach a calendar invite as a request', async () => {
    await gmailEmailSender(account).send({
      to: 'visitor@example.com',
      subject: 'Subject',
      text: 'Text',
      calendarInvite: 'BEGIN:VCALENDAR',
    });

    expect(sendMail).toHaveBeenCalledWith(
      expect.objectContaining({
        icalEvent: {
          method: 'REQUEST',
          filename: 'invite.ics',
          content: 'BEGIN:VCALENDAR',
        },
      }),
    );
  });
});
