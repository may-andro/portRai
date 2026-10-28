# Schedule Appointment

The `schedule_appointment` feature lets a visitor schedule an appointment with the portfolio owner: they pick a free
slot, fill in their details and send the request. The owner then accepts or declines it, and the
visitor hears back by email. Visitors do not sign in.

## Features

- `ScheduleAppointmentScreen` at `/schedule-appointment` is one vertical form. On desktop it starts at the screen
  padding, beside a decorative panel on the right with the floating calendar scene and the title,
  and the whole form fits on the screen; on short windows the panel stays in view while the
  form scrolls. Phones and tablets show the panel as a gradient header above the form. The screen
  loads the free slots and shows them in the device's time zone: a dropdown of the free days, the
  first one picked, then the picked day's free times as chips as tall as the text fields. The send
  button works once a time is picked. The visitor enters their name, email and a message, all
  required, and agrees to the use of their details, with a link to the privacy policy. The form
  does not ask what the appointment is about: it sends the optional `topic` query parameter, such as a
  service title, or a general topic.
- When another visitor took the chosen time first, the screen loads the free times again and says
  so. Other refusals, such as too many requests, keep the form as it is and show their message.
- After sending, a card with an animated calendar confirms the request and says that emails
  follow.
- `ScheduleAppointmentEntryWidget` is the way into scheduling for other features. The host builds its own
  button and calls the given callback, which tracks the tap and opens the screen with the host's
  topic. While scheduling is off, the widget shows the host's `fallback`, which is empty unless
  given. Hosts build with `ScheduleAppointmentBandWidget`, a compact full-width band with an animated
  calendar, a catchy line and the button. The entries are:

  | Host                                                                        | Topic             | While scheduling is off |
  | --------------------------------------------------------------------------- | ----------------- | ----------------------- |
  | The hiring summary of the [profile](../profile/) feature                    | None              | The email button        |
  | The [portfolio](../portfolio/README.md)'s band after About for recruiters   | None              | No section              |
  | The [service](../service/) feature's services screen, a band below the list | None              | Nothing                 |
  | A service's page, a band as its last section                                | The service title | Nothing                 |

- Scheduling is off unless the `feature_call_booking` flag is on (`IsScheduleAppointmentAvailableUseCase`).
- `AppointmentRequestsScreen` at `/appointment-requests` lists the requests sent to the signed-in
  owner, and the route asks for sign-in first. Requests that wait for an answer come first,
  earliest first, each with Accept and Decline buttons. A confirmation says that the visitor will
  get an email, and the request then shows its new status. Answered requests, and requests whose
  time came without an answer, follow under Earlier, latest first.
- `AppointmentRequestsCardWidget` opens the screen from Settings, shown while the
  `feature_appointment_requests` flag is on. Tapping a `call_request` notification also opens it.

## Configuration

`FirebaseScheduleAppointmentRepository` calls two callable functions in the
[functions](../../../../../../tool/functions/README.md#call-booking) project without a signed-in
user:

| Function       | Sends                                                                          | Returns                                                       |
| -------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| `getCallSlots` | Nothing                                                                        | The free slots in UTC, their length and the owner's time zone |
| `requestCall`  | `slotStart` in UTC, `name`, `email`, `topic`, `message` and the app's `locale` | The request's ID                                              |

Both functions accept only calls with a valid App Check token, and `requestCall` gets a fresh
limited-use token each time, so a captured call cannot be replayed. The reason a function sends
with a refusal (`details.reason`) decides the message the visitor sees:

| Reason                                  | Message                                       |
| --------------------------------------- | --------------------------------------------- |
| `slot_taken`, `slot_not_offered`        | The time was just taken; the times load again |
| `too_many_open_requests`, `daily_limit` | The limit for requests is reached             |
| `invalid`                               | Some details are too long or invalid          |
| `not_set_up`                            | Scheduling is not available right now         |

The app checks the name, email, message, topic and consent before sending, and the text fields allow as
many characters as the function does.

`FirestoreAppointmentRequestRepository` reads the owner's requests from Firestore without a cache
and saves the answer:

| Path                             | Access | Content                                                          |
| -------------------------------- | ------ | ---------------------------------------------------------------- |
| `users/{uid}/call_requests/{id}` | Read   | The requests the function saved                                  |
| `users/{uid}/call_requests/{id}` | Update | `status` `accepted` or `declined`, and `decidedAt` (server time) |

The Firestore rules allow only that answer, and only while the request waits for one. The
function then emails the visitor. A request that is gone or already answered shows its message,
and the list loads again.

The visitor's details are never logged: `SendAppointmentRequestClickEvent`, `RequestAppointmentParam`,
`AppointmentRequestEntity`, `AppointmentRequestModel`, `ReceivedAppointmentRequestEntity` and
`ReceivedAppointmentRequestModel` leave them out of their `toString`, and a request that does not
parse is logged with its ID only. The scheduling screen's state holds none.

## Testing

```bash
flutter test test/src/feature/schedule_appointment
```
