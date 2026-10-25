# Functions

Cloud Functions for PortRai, written in TypeScript and deployed as the `portrai` codebase.

| Function                        | Trigger                                                                   | Feature                                 |
| ------------------------------- | ------------------------------------------------------------------------- | --------------------------------------- |
| `fetchJobOpenings`              | Every Monday 06:00 Europe/Amsterdam                                       | [Job openings](#job-openings)           |
| `portfolioUpdates-<collection>` | A write to `<collection>/{locale}`, one function per portfolio collection | [Portfolio updates](#portfolio-updates) |

## Structure

```
src/
  index.ts          # initializes Firebase and exports every function
  shared/           # code any feature can use: HTTP JSON, JSON parsing, Gemini, push
                    # notifications, the region
  job_opening/      # one folder per feature, with its function in fetch_job_openings.ts
  portfolio_update/ # the portfolio update triggers in portfolio_updates.ts
test/               # mirrors src/
```

A feature imports from `shared/` but never from another feature. Code two features need moves
into `shared/`.

### Adding a function

1. Create `src/<feature>/` with the function in its own file, using `functionRegion` from
   `shared/function_options.ts`, or `firestoreTriggerRegion` for a Firestore trigger.
2. Export it from `src/index.ts`.
3. Add tests under `test/<feature>/` and a row to the table above.

Every function is part of the `portrai` codebase, so `melos run deploy_functions` deploys it
with the others.

## Job openings

`fetchJobOpenings` searches remote job boards for the portfolio's roles, scores how well each
recent job fits the portfolio with Gemini and stores the good fits for each user who has job
search turned on.

### Features

- Runs every Monday at 06:00 Europe/Amsterdam in `europe-west3`.
- Derives search terms, such as Flutter, Android and Mobile, from the portfolio's roles.
- Reads the public Greenhouse, Lever and Ashby job boards of a list of companies, searches
  Himalayas and Jobicy for those terms, reads the latest jobs from Remotive, Remote OK and
  Arbeitnow, and lets Gemini read the roles out of matching posts in Hacker News "Who is
  hiring?" threads.
- Maps every job to one shape, turns HTML descriptions into plain text and removes duplicates
  across feeds. Jobs a feed can already tell are too old, in another region or another kind of
  role are dropped before their description is read.
- Drops jobs posted more than 30 days ago, and jobs their source has already expired.
- Drops jobs limited to regions other than the preferred ones, by default the region of the
  portfolio's country, and jobs that are another kind of role, such as a product manager for a
  mobile app. Contract and freelance jobs are kept wherever they are located, unless they limit
  who can apply to other regions.
- Keeps a job when its title names a portfolio role term, or when at least two portfolio skills
  appear in its title, tags or description.
- Scores up to 120 of those jobs from 0 to 100 with Gemini against the skills, roles and years of
  experience, and keeps the ones scoring 60 or more that Gemini finds open to the preferred
  regions.
- Writes the kept jobs to `users/{uid}/job_openings/{dedupeKey}` for every user whose
  `jobSearch.enabled` is `true`.
- Notifies each user's devices when the run stored openings the user did not have yet. See
  [New job notifications](#new-job-notifications).
- Lets openings expire 14 days after the last run that found them.

### How it works

#### Portfolio profile

The search reads the same Firestore documents the app reads, in English only, since the feeds
publish mostly in English. Each collection holds one document per locale with the items in one
array:

| Document         | Fields                                                                                  |
| ---------------- | --------------------------------------------------------------------------------------- |
| `profile/en`     | `profile.currentRole`, `profile.title`, `profile.subtitle`, `profile.yearsOfExperience` |
| `experiences/en` | `experiences[].position`, `experiences[].technologies`                                  |
| `expertise/en`   | `experties[].skills[].name`                                                             |
| `projects/en`    | `projects[].technologies`                                                               |

The roles are the current role, the title, the subtitle and every past position. The search
terms are the words of those roles without seniority and generic job words, such as Senior,
Lead, Developer or Engineer, most frequent first and at most four. For example, `Tech Lead -
Flutter Developer` and `Senior Android Developer` give `Flutter` and `Android`.

Skill duplicates are dropped ignoring case. A skill or role term matches only as a whole term, so `Java` does not
match `JavaScript`, while `C++`, `.NET` and `Node.js` still match. Skills of one or two
characters, such as `Go` or `R`, count only when they appear in the title or tags.

#### Feeds

| Feed                                                                | Request                                                                                                                                 | Kept                                                                                                                         | Terms                                                                                                                                                            |
| ------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Greenhouse](https://developers.greenhouse.io/job-board.html)       | `GET /v1/boards/{slug}/jobs` per company, then `GET /v1/boards/{slug}/jobs/{id}` per kept job                                           | Recent remote jobs whose title names a term, in a preferred region and of the portfolio's kind of role, up to 10 per company | Public job board API; every opening links to the company's posting                                                                                               |
| [Lever](https://github.com/lever/postings-api)                      | `GET /v0/postings/{slug}?mode=json` per company                                                                                         | As Greenhouse                                                                                                                | Public postings API; every opening links to the company's posting                                                                                                |
| [Ashby](https://developers.ashbyhq.com/docs/public-job-posting-api) | `GET /posting-api/job-board/{slug}` per company                                                                                         | As Greenhouse                                                                                                                | Public job posting API; every opening links to the company's posting                                                                                             |
| [Himalayas](https://himalayas.app/api)                              | `GET /jobs/api/search?q={term}&sort=recent&page=1..3` per term                                                                          | Every job                                                                                                                    | Apply through the job's `applicationLink` unchanged, show Himalayas as the source with a link, don't pass jobs to other job boards, remove jobs once they expire |
| [Remotive](https://remotive.com/api-documentation)                  | `GET /api/remote-jobs?category=software-development`                                                                                    | Every job                                                                                                                    | Link to the job's Remotive URL, name Remotive as the source, don't pass jobs to other job sites, request at most a few times a day                               |
| [Remote OK](https://remoteok.com/api)                               | `GET /api`                                                                                                                              | Every job                                                                                                                    | Link back to the job's Remote OK URL and mention Remote OK as the source; don't use its logo                                                                     |
| [Jobicy](https://jobicy.com/jobs-rss-feed)                          | `GET /api/v2/remote-jobs?count=50&tag={term}` per term                                                                                  | Every job                                                                                                                    | Credit Jobicy with a link to the source, and send apply buttons to the original job URL                                                                          |
| [Hacker News](https://hn.algolia.com/api)                           | `GET /api/v1/search_by_date?tags=story,author_whoishiring`, then `GET /api/v1/items/{thread}` for the latest 2 "Who is hiring?" threads | Remote roles Gemini reads out of posts from the last 30 days that mention a term and remote work                             | Public API; every opening links to its post on Hacker News                                                                                                       |
| [Arbeitnow](https://www.arbeitnow.com/blog/job-board-api)           | `GET /api/job-board-api?page=1..5`                                                                                                      | Jobs with `remote: true`                                                                                                     | Don't abuse the free API, link back to the site                                                                                                                  |

Every stored opening keeps the source's job `url` and `sourceName`, which the app must show
with the job. Earlier feeds in the table win when two list the same job. Remotive's free API
returns only its 10 most recent jobs, which arrive 24 hours after they are posted on Remotive.
A request whose connection fails, or that is answered with `429` or a `5xx` status, is tried
once more after two seconds.

Himalayas and Jobicy search two terms at a time. When a later page of a term fails, Himalayas and
Arbeitnow keep the pages read before it; a feed fails only when it reads nothing, that is when
the first page of every term, or Arbeitnow's first page, fails.

#### Company boards

Greenhouse, Lever and Ashby host companies' own job boards, so each one is read per company.
The companies come from the `job_search/company_boards` document, which only the function
reads; the owner edits it in the Firebase console:

```json
{
  "boards": [
    { "system": "greenhouse", "slug": "reddit", "name": "Reddit" },
    { "system": "lever", "slug": "qonto", "name": "Qonto" },
    { "system": "ashby", "slug": "ramp", "name": "Ramp" }
  ]
}
```

The board feeds read this document when they start. `system` is `greenhouse`, `lever` or `ashby`, `slug` is the board's name in its URL, such as
`reddit` in `job-boards.greenhouse.io/reddit`, and `name` is shown as the opening's source.
Without the document, a built-in list of about 30 companies with mobile engineering roles is
used (`defaultCompanyBoards` in `src/job_opening/feed/company_board.ts`); an empty `boards` list
turns the company boards off. Entries with another system or without a slug are skipped.

A job counts as remote when its location or workplace type says so. Postings that are not remote,
whose title names no search term, that were published more than 30 days ago or without a date,
or that the [region and role](#region-and-role) filters drop are skipped before the limit of 10
per company is applied, so they never take a place; for Greenhouse, only the postings left are
read in full. Companies often post one job once per location, so the postings with the same
title that are left become one opening that lists their locations. Up to four boards are read at
a time, and the next board starts as soon as one finishes; a board that fails, such as a
misspelled slug, is logged with its slug and skipped.

#### Hacker News posts

"Who is hiring?" posts are free text, so the function reads them in two steps. First it reads the
latest two threads at the same time and keeps the top-level posts from the last 30 days that
mention a search term and the word remote, at most 40, newest first. Then Gemini lists the roles each post offers, with title, company,
location and whether remote work is allowed; only remote roles are kept. The post is sent as
data apart from the instructions, with thinking turned off, since the roles are copied from the
post. The reply is validated: at most five roles, each with a title and a company, and capped
texts.

Each opening links to its post on Hacker News, which holds the company's own application
details. Links inside a post are never followed or stored, so no address comes from the model.
A post whose roles cannot be read is skipped; the source fails only when every post fails.

#### Freshness

Jobs posted more than 30 days ago are dropped before matching, so stale postings are never
scored or stored. Feeds that know a job's date drop it already while reading, before its
description is converted or, for Greenhouse and Hacker News, before its details are read or
Gemini is called. A stored opening expires 14 days after the last run that found it, or earlier
when its source gives an earlier expiry, as Himalayas does.

If one feed fails, or is still running after 4 minutes, the run continues with the others and
logs a warning. The run fails only when every feed fails. The function does not retry, so a failed run waits for the next Monday.

#### Region and role

Many remote jobs can only be taken from some countries, such as `Remote - USA`. The preferred
regions are `europe`, `north_america`, `latin_america`, `asia_pacific` and
`middle_east_africa`. They come from the `regions` list of the `job_search/settings` document,
which only the function reads, for example `{ "regions": ["europe"] }`. Without that document
the region of the portfolio's `profile.location.country` is used, and when the country is not
known, every region is kept.

A job's location is matched against region, country, state and city names, US state codes such
as `Boulder, CO`, and time zones such as `CET` or `EST`. A job is dropped when its location names
other regions alone, including limited worldwide wording such as `Anywhere in the US` or
`Worldwide (US time zones)`. A long list such as `Albania, Andorra, Argentina +70 more` is judged
by the places it names; Himalayas lists the places in the preferred regions first. A job without
a location, with a worldwide one such as `Anywhere`, or with a location that names no known place
is kept, and scoring judges it.

The location and description are also read for wording that limits who can apply, such as
`US only`, `must be based in the US`, `authorized to work in the United States` or `must be a US
citizen`. A job whose limits name other regions alone is dropped, whatever its location says.

A contract or freelance job, by its job types, is kept wherever it is located, since such work
can often be done from anywhere. The wording that limits who can apply still drops it.

Titles that name a role other than building software, such as product manager, designer,
marketing, sales or recruiter, are dropped unless they also name an engineering role, such as
`Engineering Manager, Mobile`. A word that one of the portfolio's own roles uses is never a
reason to drop a job, so a portfolio with a designer role keeps designer jobs.

Both filters run before keyword matching, so no Gemini call goes to a job that cannot be taken.
The regions are read before the feeds start, so the feeds that know a job's title and location
apply the same filters while reading; the run applies them again to every job the feeds return
and logs how many each one dropped there. Jobs a feed already skipped are not in those counts.

#### Scoring

Keyword matching is a cheap first filter. Gemini (`gemini-2.5-flash` through the Agent
Platform, formerly Vertex AI, in the `global` location) then reads each matched job with the
portfolio's skills, roles and years of experience and the preferred regions, and replies with
JSON:

| Field             | Kept as                                                                                                                          |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `score`           | An integer from 0 to 100, rounded and clamped                                                                                    |
| `matchedSkills`   | Only portfolio skills, in their portfolio spelling, added to the keyword matches                                                 |
| `missingSkills`   | At most 8 skills the job asks for that the portfolio lacks                                                                       |
| `reasons`         | At most 3 sentences of up to 300 characters                                                                                      |
| `openToCandidate` | False when the job states that candidates must live in, or be authorized to work in, other regions; anything else counts as true |

- **Threshold:** openings scoring below 60, or that Gemini finds closed to the preferred regions,
  are not stored. 80 or more means the job's core stack is in the portfolio.
- **Cost:** a run scores at most the 120 best matches, role-title matches first, then by matched
  skills and then by date, 2 at a time. Gemini may think with up to 1,024 tokens before
  replying to each.
- **Reuse:** each fit is stored under a hash of the model, the instructions and the prompt (see
  [Stored fits](#stored-fits)). A matched job whose request is unchanged since an earlier run
  reuses that fit without a Gemini call and does not count towards the 120. A change to the job's
  text, to the portfolio's skills, roles or years of experience, or to the preferred regions
  changes the hash, so the job is scored again.
- **Retries:** a throttled (`429`), timed-out or server-error (`5xx`) call is retried up to 3
  times, after about 5, 10 and 20 seconds. Each attempt gets 45 seconds and each opening 150 seconds in total.
  Scoring stops starting new openings 11 minutes after the run starts, so the run ends before
  the function's 15-minute timeout; skipped openings count as failed.
- **Untrusted text:** job descriptions come from public job boards. The instructions go in the
  system instruction and the job only in the prompt, as data. The reply is validated, so the
  model cannot add skills the portfolio lacks or return an unbounded text.
- **Data sent:** the portfolio skills and the job's title, company, location, types, tags and
  description. No user data is sent.
- **Failures:** a job whose score fails is skipped with a warning. The run fails without
  writing when every score fails and no stored fit was reused, which usually means the API or
  permission is not set up.

#### Firestore data

A user takes part when their document has job search turned on:

```jsonc
// users/{uid}
{
  "jobSearch": {
    "enabled": true,
    "updatedAt": "<timestamp>", // when job search was last turned on or off
  },
}
```

| Field                 | Type      | Read by the function | Description                              |
| --------------------- | --------- | -------------------- | ---------------------------------------- |
| `jobSearch.enabled`   | boolean   | Yes                  | Whether the weekly run includes the user |
| `jobSearch.updatedAt` | timestamp | No                   | When `enabled` last changed              |

`jobSearch` holds settings the user controls. Anything the function reports back, such as its
last run, belongs outside this map, so Firestore rules can let the user change `jobSearch` while
only the server writes the rest.

No user document exists until job search is turned on, and a run with no such users skips the
feeds. The app's "Weekly job search" switch on the Job openings screen writes both fields (see
the [app README](../../app/portrai/README.md#job-openings)). Without the app, create the document
in the Firebase console: in the `users` collection, add a document whose ID is the user's UID from
Authentication, with a map field `jobSearch` holding the boolean `enabled` set to `true` and the
timestamp `updatedAt` set to now.

Each opening is stored at `users/{uid}/job_openings/{dedupeKey}`. The key is a hash of the
normalized company and title, so the same job keeps one document across feeds and weeks.

| Field           | Type           | Description                                |
| --------------- | -------------- | ------------------------------------------ |
| `source`        | string         | `remotive` or `arbeitnow`                  |
| `sourceName`    | string         | `Remotive` or `Arbeitnow`, for attribution |
| `sourceId`      | string         | The job's id at the source                 |
| `title`         | string         | Job title                                  |
| `company`       | string         | Company name                               |
| `url`           | string         | Job page at the source                     |
| `location`      | string or null | Location or region restriction             |
| `tags`          | string[]       | Tags from the source                       |
| `jobTypes`      | string[]       | Employment types from the source           |
| `description`   | string         | Plain text, at most 5,000 characters       |
| `matchedSkills` | string[]       | Portfolio skills the job needs             |
| `score`         | number         | Gemini's fit score, 60 to 100              |
| `missingSkills` | string[]       | Skills the job asks for that are missing   |
| `reasons`       | string[]       | Gemini's short explanation of the score    |
| `publishedAt`   | timestamp      | When the source published the job          |
| `fetchedAt`     | timestamp      | When this run stored it                    |
| `expiresAt`     | timestamp      | `fetchedAt` plus 14 days                   |

A job found again replaces its document, which also moves `expiresAt` back.

#### Stored fits

Each new fit is stored at `job_fits/{fitKey}`, whether or not the job scored high enough to be
kept. Only the function reads and writes this collection; the Firestore rules give clients no
access to it.

| Field             | Type      | Description                     |
| ----------------- | --------- | ------------------------------- |
| `score`           | number    | Gemini's fit score, 0 to 100    |
| `matchedSkills`   | string[]  | As Gemini returned them         |
| `missingSkills`   | string[]  | As Gemini returned them         |
| `reasons`         | string[]  | As Gemini returned them         |
| `openToCandidate` | boolean   | As Gemini returned it           |
| `expiresAt`       | timestamp | When it was scored plus 30 days |

Jobs older than 30 days are dropped before scoring, so a fit is not needed for longer.

#### Expiry

Firestore deletes expired openings through a TTL policy on `expiresAt`. Create it once, with
`PROJECT_ID` set as in [Getting Started](#getting-started):

```bash
gcloud firestore fields ttls update expiresAt \
  --collection-group=job_openings \
  --enable-ttl \
  --project="$PROJECT_ID"
```

Stored fits expire the same way, through a TTL policy on the `job_fits` collection group:

```bash
gcloud firestore fields ttls update expiresAt \
  --collection-group=job_fits \
  --enable-ttl \
  --project="$PROJECT_ID"
```

TTL deletion usually runs within a day of `expiresAt`, so expired openings can stay readable
for a short time.

#### New job notifications

Before writing a user's openings, the run checks which of them the user already has. When some
are new, it sends one notification to each of the user's devices, such as "3 new job openings
match your portfolio.", in the device's language (`en`, `es` or `nl`, English otherwise). A run
with no new openings for a user sends nothing. A newer notification replaces the one shown.

The app registers a device while the user is signed in on it and removes it when they sign out,
so only the signed-in user's devices receive these notifications:

| Path                          | Field       | Type      | Description                         |
| ----------------------------- | ----------- | --------- | ----------------------------------- |
| `users/{uid}/devices/{token}` | `locale`    | string    | The app's language on the device    |
|                               | `platform`  | string    | `android`, `ios` or `web`           |
|                               | `updatedAt` | timestamp | When the device was last registered |

The notification's data holds `kind: job_openings`. Devices whose token is no longer registered
are deleted. Openings are stored before the notification is sent, so a failed send is logged and
the run still succeeds. The result reports `notifiedUserCount`, the users told on at least one
device.

## Portfolio updates

`portfolioUpdates-<collection>` notifies the app's users that the portfolio changed. There is
one function for each portfolio collection: `profile`, `experiences`, `expertise`, `projects`,
`services` and `testimonials`.

- Runs when a document `<collection>/{locale}` is created or changed, in `us-central1`, the
  region of the Cloud Firestore database.
- Sends one notification to the topic `portfolio_updates_<locale>`, such as "Portfolio updated
  — Take a look at what's new.", in that locale (`en`, `es` or `nl`, English otherwise). The
  app subscribes to the topic of its language when the user turns notifications on.
- Records the change time of the collection in `portfolio_versions/{locale}`, such as
  `{ profile: <time>, projects: <time> }`, on every change, without the cooldown. The app
  compares these times with its caches and refreshes only the collections that changed.
- Sends nothing and records nothing when the document was deleted, when its content did not
  change, or when the locale is not two lowercase letters.
- Sends to a topic at most once every 6 hours, so one import that writes many documents gives
  one notification. The last send to each topic is kept at `notification_sends/{topic}` as
  `sentAt`; a transaction claims the send, so triggers running at the same time cannot both send.
- The notification's data holds `kind: portfolio_update`. A newer notification replaces the one
  shown.
- Logs the outcome of each change: `sent`, `unchanged`, `deleted`, `unknown_locale` or
  `cooling_down`. A failed send is not retried.

The functions run as the `notifications` service account (see
[Service account](#service-account)).

## Getting Started

The commands below read the project ID from `PROJECT_ID`. Set it first:

```bash
export PROJECT_ID=<your-firebase-project-id>
```

### Requirements

- Node.js 22. The `volta` field in `package.json` pins it for Volta users.
- A Firebase project on the Blaze plan, with the Cloud Scheduler API on. `.firebaserc` sets the
  project the Firebase CLI deploys to.
- The Agent Platform API (`aiplatform.googleapis.com`) on, and the `job-openings` service
  account with its three roles. See [Service account](#service-account).
- The Eventarc API on, and the `notifications` service account with its roles.
- A Cloud Firestore database in `us-central1`, where the Firestore triggers run.
- The Firebase CLI, signed in to an account that can deploy to the project.

### Service account

The job openings function runs as its own service account, `job-openings`, which may only read
and write Firestore, call Gemini and send notifications. It calls Gemini as that account, so
there is no API key to store. The code builds the account's full email from the project it is
deployed to.

Enable the API, create the account and grant its three roles once:

```bash
gcloud services enable aiplatform.googleapis.com --project="$PROJECT_ID"
gcloud iam service-accounts create job-openings \
  --display-name="Job openings function" --project="$PROJECT_ID"
for role in roles/aiplatform.user roles/datastore.user roles/firebasecloudmessaging.admin; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:job-openings@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="$role"
done
```

| Role                                 | Console name                            | Needed for                    |
| ------------------------------------ | --------------------------------------- | ----------------------------- |
| `roles/aiplatform.user`              | Vertex AI User (or Agent Platform User) | Calling Gemini                |
| `roles/datastore.user`               | Cloud Datastore User                    | Reading and writing Firestore |
| `roles/firebasecloudmessaging.admin` | Firebase Cloud Messaging API Admin      | Sending notifications         |

The portfolio update functions run as the `notifications` service account, which may only read
and write Firestore, send notifications and receive the Firestore events that start them:

```bash
gcloud services enable eventarc.googleapis.com --project="$PROJECT_ID"
gcloud iam service-accounts create notifications \
  --display-name="Notification functions" --project="$PROJECT_ID"
for role in roles/datastore.user roles/firebasecloudmessaging.admin \
  roles/eventarc.eventReceiver roles/run.invoker; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:notifications@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="$role"
done
```

| Role                                 | Console name                       | Needed for                               |
| ------------------------------------ | ---------------------------------- | ---------------------------------------- |
| `roles/datastore.user`               | Cloud Datastore User               | Reading and writing `notification_sends` |
| `roles/firebasecloudmessaging.admin` | Firebase Cloud Messaging API Admin | Sending notifications                    |
| `roles/eventarc.eventReceiver`       | Eventarc Event Receiver            | Receiving the Firestore events           |
| `roles/run.invoker`                  | Cloud Run Invoker                  | Letting Eventarc start the functions     |

Firestore triggers must run in the database's region, set by `firestoreTriggerRegion`. Check the
location with `gcloud firestore databases describe --project="$PROJECT_ID" --format="value(locationId)"`.

The deploy lets the account start the function from Cloud Scheduler, so it needs no other
role. Deploying needs permission to act as the account, which project Owners have.

Before changing the model, check that it is offered in the `global` location and has capacity
there. A model with little shared capacity answers most calls with `429 RESOURCE_EXHAUSTED`, even
after retries. A few calls in a row from Cloud Shell should all return `200`:

```bash
for attempt in 1 2 3 4 5; do curl -s -o /dev/null -w "%{http_code} " -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  "https://aiplatform.googleapis.com/v1/projects/$PROJECT_ID/locations/global/publishers/google/models/gemini-2.5-flash:generateContent" \
  -d '{"contents":[{"role":"user","parts":[{"text":"Reply OK"}]}]}'; done; echo
```

Changing the model or location means changing `src/shared/gemini.ts` and deploying again. Gemini
2.5 models take a `thinkingBudget`, which each request sets, while Gemini 3 models take a
`thinkingLevel`.

### Development

From `tool/functions`:

```bash
npm ci            # install from package-lock.json
npm run check     # format check, type check and tests
npm run format    # format with Prettier
npm run build     # compile to lib/
```

From the workspace root, `melos run functions_check` runs `npm ci` and `npm run check`.

Generating a new `package-lock.json` needs npm 11 or later. npm 10 fails while resolving
`firebase-functions` peer dependencies with `Cannot read properties of null (reading
'edgesOut')`. `npm ci` from the existing lockfile works with npm 10.

## Deployment

```bash
melos run deploy_functions
```

This runs the checks and then `firebase deploy --only functions:portrai` from
`tool/functions`. Deploying a named codebase only changes the functions in that codebase, so
functions deployed from elsewhere are left alone. To deploy one function, run
`firebase deploy --only functions:portrai:fetchJobOpenings` from `tool/functions`. The deploy does not change Firestore rules or
indexes.

### Deploying from GitHub Actions

`functions_production.yaml` deploys the `portrai` codebase when a push to `develop` changes
`tool/functions`. It runs the same checks as pull requests first, then
`firebase deploy --only functions:portrai --force`. `--force` deletes functions removed from the
codebase and sets the container image cleanup policy without a prompt.

The deploy signs in as the `github-actions-functions` service account. Create it, grant its roles
and store its key once:

```bash
gcloud iam service-accounts create github-actions-functions \
  --display-name="GitHub Actions functions deploy" --project="$PROJECT_ID"
DEPLOYER="serviceAccount:github-actions-functions@${PROJECT_ID}.iam.gserviceaccount.com"
for role in roles/cloudfunctions.developer roles/cloudscheduler.admin \
  roles/artifactregistry.admin roles/serviceusage.serviceUsageConsumer roles/firebase.viewer; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="$DEPLOYER" --role="$role"
done
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
for account in "job-openings@${PROJECT_ID}.iam.gserviceaccount.com" \
  "notifications@${PROJECT_ID}.iam.gserviceaccount.com" \
  "${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  "${PROJECT_ID}@appspot.gserviceaccount.com"; do
  gcloud iam service-accounts add-iam-policy-binding "$account" \
    --member="$DEPLOYER" --role=roles/iam.serviceAccountUser --project="$PROJECT_ID"
done
gcloud iam service-accounts keys create key.json \
  --iam-account="github-actions-functions@${PROJECT_ID}.iam.gserviceaccount.com"
base64 < key.json | gh secret set FUNCTIONS_DEPLOY_SERVICE_ACCOUNT
rm key.json
```

| Role                                      | Needed for                                                                                                                                                                                                    |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `roles/cloudfunctions.developer`          | Creating and updating functions                                                                                                                                                                               |
| `roles/cloudscheduler.admin`              | Creating and updating the jobs that start scheduled functions                                                                                                                                                 |
| `roles/artifactregistry.admin`            | Setting the cleanup policy on the repository of function images                                                                                                                                               |
| `roles/serviceusage.serviceUsageConsumer` | Checking that the APIs the deploy needs are on                                                                                                                                                                |
| `roles/firebase.viewer`                   | Reading the Firebase project                                                                                                                                                                                  |
| `roles/iam.serviceAccountUser`            | Running functions as `job-openings` and `notifications`, building them as the default compute account and deploying scheduled functions, which the Firebase CLI checks against the App Engine default account |

The workflow also reads the `FIREBASE_PROJECT_ID` secret that the other deploys use.
