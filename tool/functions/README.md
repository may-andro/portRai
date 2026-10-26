# Functions

Cloud Functions for PortRai, written in TypeScript for Node.js 22 and deployed as the `portrai`
codebase.

## Functions

| Function                        | Trigger                                                                   | Region         | Feature                                 |
| ------------------------------- | ------------------------------------------------------------------------- | -------------- | --------------------------------------- |
| `fetchJobOpenings`              | Schedule, every Monday 06:00 Europe/Amsterdam                             | `europe-west3` | [Job openings](#job-openings)           |
| `portfolioUpdates-<collection>` | A write to `<collection>/{locale}`, one function per portfolio collection | `us-central1`  | [Portfolio updates](#portfolio-updates) |
| `sendPortfolioUpdates`          | Schedule, every 5 minutes                                                 | `europe-west3` | [Portfolio updates](#portfolio-updates) |

None of the functions retries a failed run.

## Structure

```text
src/
  index.ts          # initializes Firebase Admin and exports every function
  shared/           # code any feature can use: JSON over HTTP, JSON value parsing, the Gemini
                    # client, push messaging, concurrency and time-limit helpers, regions and
                    # service account emails
  job_opening/      # fetchJobOpenings, in fetch_job_openings.ts
  portfolio_update/ # portfolioUpdates and sendPortfolioUpdates, in portfolio_updates.ts
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

`fetchJobOpenings` searches remote job feeds for the portfolio's roles, scores how well each
recent job fits the portfolio with Gemini and stores the good fits for each user who has job
search turned on.

- Runs every Monday at 06:00 Europe/Amsterdam in `europe-west3`, with a 15-minute timeout and
  512 MiB of memory.
- Derives search terms, such as Flutter or Android, from the portfolio's roles.
- Reads the public Greenhouse, Lever and Ashby job boards of a list of companies, searches
  Himalayas and Jobicy for the terms, reads the latest jobs from Remotive, Remote OK and
  Arbeitnow, and lets Gemini read the roles out of matching posts in Hacker News "Who is
  hiring?" threads.
- Maps every job to one shape, turns HTML descriptions into plain text and removes duplicates
  across feeds.
- Drops jobs posted more than 30 days ago, jobs their source has already expired, jobs limited
  to regions other than the preferred ones and jobs that are another kind of role, such as a
  product manager for a mobile app.
- Keeps a job when its title names a search term, or when at least two portfolio skills appear
  in its title, tags or description.
- Scores up to 120 of those jobs from 0 to 100 with Gemini and keeps the ones scoring 60 or more
  that Gemini finds open to the preferred regions.
- Writes the kept jobs to `users/{uid}/job_openings/{dedupeKey}` for every user whose
  `jobSearch.enabled` is `true`, and notifies each user of openings they did not have yet.
- Openings expire 14 days after the last run that found them.

### Portfolio profile

The search reads the same Firestore documents the app reads, in English only. Each collection
holds one document per locale with the items in one array:

| Document         | Fields                                                                                                              |
| ---------------- | ------------------------------------------------------------------------------------------------------------------- |
| `profile/en`     | `profile.currentRole`, `profile.title`, `profile.subtitle`, `profile.yearsOfExperience`, `profile.location.country` |
| `experiences/en` | `experiences[].position`, `experiences[].technologies`                                                              |
| `expertise/en`   | `experties[].skills[].name`                                                                                         |
| `projects/en`    | `projects[].technologies`                                                                                           |

The roles are the current role, the title, the subtitle and every past position. The search
terms are the words of those roles without seniority and generic job words, such as Senior,
Lead, Developer or Engineer, most frequent first and at most four. For example, `Tech Lead -
Flutter Developer` and `Senior Android Developer` give `Flutter` and `Android`.

The skills are the expertise skill names and the technologies of projects and experiences, with
duplicates dropped ignoring case. A skill or search term matches only as a whole term, so `Java`
does not match `JavaScript`, while `C++`, `.NET` and `Node.js` still match. Skills of one or two
characters, such as `Go` or `R`, count only when they appear in the title or tags.

When there are no job search users, the run skips the feeds. When the portfolio has no skills
and no roles, it stops before reading them.

### Feeds

| Feed                                                                | Request                                                                                                                                                | Kept                                                                                                                         | Terms                                                                                                                                                            |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Greenhouse](https://developers.greenhouse.io/job-board.html)       | `GET /v1/boards/{slug}/jobs` per company, then `GET /v1/boards/{slug}/jobs/{id}` per kept job                                                          | Recent remote jobs whose title names a term, in a preferred region and of the portfolio's kind of role, up to 10 per company | Public job board API; every opening links to the company's posting                                                                                               |
| [Lever](https://github.com/lever/postings-api)                      | `GET /v0/postings/{slug}?mode=json` per company                                                                                                        | As Greenhouse                                                                                                                | Public postings API; every opening links to the company's posting                                                                                                |
| [Ashby](https://developers.ashbyhq.com/docs/public-job-posting-api) | `GET /posting-api/job-board/{slug}` per company                                                                                                        | As Greenhouse                                                                                                                | Public job posting API; every opening links to the company's posting                                                                                             |
| [Himalayas](https://himalayas.app/api)                              | `GET /jobs/api/search?q={term}&sort=recent&page=1..3` per term                                                                                         | Every job                                                                                                                    | Apply through the job's `applicationLink` unchanged, show Himalayas as the source with a link, don't pass jobs to other job boards, remove jobs once they expire |
| [Remotive](https://remotive.com/api-documentation)                  | `GET /api/remote-jobs?category=software-development`                                                                                                   | Every job                                                                                                                    | Link to the job's Remotive URL, name Remotive as the source, don't pass jobs to other job sites, request at most a few times a day                               |
| [Remote OK](https://remoteok.com/api)                               | `GET /api`                                                                                                                                             | Every job                                                                                                                    | Link back to the job's Remote OK URL and mention Remote OK as the source; don't use its logo                                                                     |
| [Jobicy](https://jobicy.com/jobs-rss-feed)                          | `GET /api/v2/remote-jobs?count=50&tag={term}` per term                                                                                                 | Every job                                                                                                                    | Credit Jobicy with a link to the source, and send apply buttons to the original job URL                                                                          |
| [Hacker News](https://hn.algolia.com/api)                           | `GET /api/v1/search_by_date?tags=story,author_whoishiring&hitsPerPage=10`, then `GET /api/v1/items/{thread}` for the latest 2 "Who is hiring?" threads | Remote roles Gemini reads out of posts from the last 30 days that mention a term and remote work                             | Public API; every opening links to its post on Hacker News                                                                                                       |
| [Arbeitnow](https://www.arbeitnow.com/blog/job-board-api)           | `GET /api/job-board-api?page=1..5`                                                                                                                     | Jobs with `remote: true`                                                                                                     | Don't abuse the free API, link back to the site                                                                                                                  |

Every stored opening keeps the source's job `url` and `sourceName`, which the app must show
with the job. Earlier feeds in the table win when two list the same job. A request whose
connection fails, or that is answered with `429` or a `5xx` status, is tried once more after two
seconds; each request times out after 30 seconds.

Himalayas and Jobicy search two terms at a time. Himalayas reads up to three pages per term and
Arbeitnow up to five pages; when a later page fails, they keep the pages read before it. A
Himalayas term or Arbeitnow fails only when its first page fails, and a Jobicy term fails on its
one request. Himalayas and Jobicy fail only when every term fails.

Feeds that know a job's date, title and location apply the same freshness, region and role
filters while reading, so Greenhouse details are fetched only for postings that pass them and
descriptions are converted only for jobs that are kept.

If one feed fails, or is still running after 4 minutes, the run continues with the others and
logs a warning. The run fails only when every feed fails.

### Company boards

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

`system` is `greenhouse`, `lever` or `ashby`, `slug` is the board's name in its URL, such as
`reddit` in `job-boards.greenhouse.io/reddit`, and `name` is shown as the opening's company and
source, falling back to the slug. Entries with another system or without a slug are skipped.
Without the document, or without a `boards` list in it, the 32 companies in
`defaultCompanyBoards` in `src/job_opening/feed/company_board.ts` are used; an empty `boards`
list turns the company boards off. The document is read once per run, when the board feeds start.

A posting counts as remote when its location says so, or for Lever and Ashby also its workplace
type. Postings that are not remote, whose title names no search term, that have no date or one
more than 30 days ago, or that the [region and role](#region-and-role) filters drop are skipped
before the limit of 10 per company is applied, so they never take a place. Postings left with
the same title become one opening that lists their locations. Up to four boards are read at a
time; a board that fails, such as a misspelled slug, is logged with its system and slug and
skipped. A board feed fails only when every board fails.

### Hacker News posts

"Who is hiring?" posts are free text, so the function reads them in two steps. First it reads the
latest two threads and keeps the top-level posts from the last 30 days that mention a search
term and the word remote, at most 40, newest first. Then Gemini lists the roles each post offers,
two posts at a time, with title, company, location and whether remote work is allowed; only
remote roles are kept. The post is sent as data apart from the instructions, with thinking
turned off, since the roles are copied from the post. The reply is validated: at most five roles,
each with a title and a company, and texts capped in length.

Each opening's `url` is its post on Hacker News, which holds the company's own application
details; links inside a post are never followed. A post whose roles cannot be read is skipped.
The feed fails when the thread search or a thread cannot be read, or when every post fails.

### Region and role

Many remote jobs can only be taken from some countries, such as `Remote - USA`. The regions are
`europe`, `north_america`, `latin_america`, `asia_pacific` and `middle_east_africa`. The
preferred ones come from the `regions` list of the `job_search/settings` document, which only
the function reads, for example `{ "regions": ["europe"] }`. Without that list, the region of the
portfolio's `profile.location.country` is used. When neither gives a region, every region is
kept.

A job's location is matched against region, country, state and city names, country and US state
codes such as `Boulder, CO`, and time zones such as `CET` or `EST`. A job is dropped when its
location names other regions alone, including limited worldwide wording such as `Anywhere in the
US` or `Worldwide (US time zones)`. Himalayas lists the places in the preferred regions first
when a job names more than three. A job without a location, with a worldwide one such as
`Anywhere`, or with a location that names no known place is kept, and scoring judges it.

The location and description are also read for wording that limits who can apply, such as
`US only`, `must be based in the US`, `authorized to work in the United States` or `must be a US
citizen`. A job whose limits name other regions alone is dropped, whatever its location says.
A contract or freelance job, by its job types, is otherwise kept wherever it is located.

Titles that name a role other than building software, such as product manager, designer,
marketing, sales or recruiter, are dropped unless they also name an engineering role, such as
`Engineering Manager, Mobile`. A word that one of the portfolio's own roles uses is never a
reason to drop a job, so a portfolio with a designer role keeps designer jobs.

Both filters run before keyword matching, so no Gemini call goes to a job that cannot be taken.
The run applies them again to every job the feeds return and logs how many each one dropped.

### Scoring

Gemini (`gemini-2.5-flash` through the Agent Platform, formerly Vertex AI, in the `global`
location, at temperature 0) reads each matched job with the portfolio's skills, roles and years
of experience and the preferred regions, and replies with JSON:

| Field             | Kept as                                                                                                                          |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `score`           | An integer from 0 to 100, rounded and clamped                                                                                    |
| `matchedSkills`   | Only portfolio skills, in their portfolio spelling, added to the keyword matches                                                 |
| `missingSkills`   | At most 8 skills the job asks for that the portfolio lacks, each at most 60 characters                                           |
| `reasons`         | At most 3 sentences of up to 300 characters                                                                                      |
| `openToCandidate` | False when the job states that candidates must live in, or be authorized to work in, other regions; anything else counts as true |

- **Threshold:** openings scoring below 60, or that Gemini finds closed to the preferred regions,
  are not stored. The instructions define 80 or more as the job's core stack being in the
  portfolio and the role and seniority matching.
- **Limit:** a run scores at most the 120 best matches, role-title matches first, then by matched
  skills and then by date, 2 at a time. Gemini may think with up to 1,024 tokens before replying.
- **Reuse:** each fit is stored under a hash of the model, the instructions and the prompt (see
  [Stored fits](#stored-fits)). A matched job whose request is unchanged since an earlier run
  reuses that fit without a Gemini call and does not count towards the 120. A change to the job's
  text, to the portfolio's skills, roles or years of experience, or to the preferred regions
  changes the hash, so the job is scored again.
- **Retries:** a `408`, `429` or `5xx` reply is retried up to 3 times, after about 5, 10 and 20
  seconds. Each attempt gets 45 seconds and each call 150 seconds in total. Scoring stops starting
  new jobs 11 minutes after the run starts, so the run ends before the 15-minute timeout; skipped
  jobs count as failed.
- **Untrusted text:** job descriptions come from public job boards. The instructions go in the
  system instruction and the job only in the prompt, as data. The reply is validated, so the
  model cannot add skills the portfolio lacks or return unbounded text.
- **Data sent:** the portfolio's skills, roles, years of experience and preferred regions, and the
  job's title, company, location, job types, tags and description. No user data is sent.
- **Failures:** a job whose score fails is skipped with a warning. The run fails without writing
  when every score fails and no stored fit was reused, which usually means the API or permission
  is not set up.

### Firestore data

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

`jobSearch` holds settings the user controls. Anything the function reports back belongs
outside this map, so Firestore rules can let the user change `jobSearch` while only the server
writes the rest.

The app's job search switch writes both fields (see the
[app README](../../app/portrai/README.md#job-openings)). Without the app, create the document in
the Firebase console: in the `users` collection, add a document whose ID is the user's UID from
Authentication, with a map field `jobSearch` holding the boolean `enabled` set to `true` and the
timestamp `updatedAt` set to now.

Each opening is stored at `users/{uid}/job_openings/{dedupeKey}`. The key is a hash of the
normalized company and title, so the same job keeps one document across feeds and weeks.

| Field           | Type           | Description                                                                                                |
| --------------- | -------------- | ---------------------------------------------------------------------------------------------------------- |
| `source`        | string         | `greenhouse`, `lever`, `ashby`, `himalayas`, `remotive`, `remoteok`, `jobicy`, `hackernews` or `arbeitnow` |
| `sourceName`    | string         | The feed's name, or the company's name for a company board, for attribution                                |
| `sourceId`      | string         | The job's id at the source                                                                                 |
| `title`         | string         | Job title                                                                                                  |
| `company`       | string         | Company name                                                                                               |
| `url`           | string         | Job page at the source                                                                                     |
| `location`      | string or null | Location or region restriction                                                                             |
| `tags`          | string[]       | Tags from the source                                                                                       |
| `jobTypes`      | string[]       | Employment types from the source                                                                           |
| `description`   | string         | Plain text, cut at 5,000 characters                                                                        |
| `matchedSkills` | string[]       | Portfolio skills the job needs                                                                             |
| `score`         | number         | Gemini's fit score, 60 to 100                                                                              |
| `missingSkills` | string[]       | Skills the job asks for that are missing                                                                   |
| `reasons`       | string[]       | Gemini's short explanation of the score                                                                    |
| `publishedAt`   | timestamp      | When the source published the job                                                                          |
| `fetchedAt`     | timestamp      | When this run stored it                                                                                    |
| `expiresAt`     | timestamp      | `fetchedAt` plus 14 days, or the source's expiry when that is earlier                                      |

A job found again replaces its document, which also moves `expiresAt` back.

### Stored fits

Each new fit is stored at `job_fits/{fitKey}`, whether or not the job scored high enough to be
kept. Only the function reads and writes this collection; the Firestore rules give clients no
access to it.

| Field             | Type      | Description                     |
| ----------------- | --------- | ------------------------------- |
| `score`           | number    | Gemini's fit score, 0 to 100    |
| `matchedSkills`   | string[]  | As validated from the reply     |
| `missingSkills`   | string[]  | As validated from the reply     |
| `reasons`         | string[]  | As validated from the reply     |
| `openToCandidate` | boolean   | As validated from the reply     |
| `expiresAt`       | timestamp | When it was scored plus 30 days |

Jobs older than 30 days are dropped before scoring, so a fit is not needed for longer. When
reading or saving fits fails, the run logs a warning and scores the jobs again.

### Expiry

Firestore deletes expired openings and fits through TTL policies on `expiresAt`. Create them
once, with `PROJECT_ID` set as in [Getting Started](#getting-started):

```bash
gcloud firestore fields ttls update expiresAt \
  --collection-group=job_openings \
  --enable-ttl \
  --project="$PROJECT_ID"
gcloud firestore fields ttls update expiresAt \
  --collection-group=job_fits \
  --enable-ttl \
  --project="$PROJECT_ID"
```

TTL deletion is not immediate, so expired openings can stay readable for a while after
`expiresAt`.

### New job notifications

Before writing a user's openings, the run checks which of them the user already has. When some
are new, it sends one notification to each of the user's devices, such as "3 new job openings
match your portfolio.", in the device's language (`en`, `es` or `nl`, English otherwise). A user
with no new openings gets nothing. A newer notification replaces the one shown.

The app registers a device while the user is signed in on it and removes it when they sign out:

| Path                          | Field       | Type      | Description                         |
| ----------------------------- | ----------- | --------- | ----------------------------------- |
| `users/{uid}/devices/{token}` | `locale`    | string    | The app's language on the device    |
|                               | `platform`  | string    | `android`, `ios` or `web`           |
|                               | `updatedAt` | timestamp | When the device was last registered |

The function reads only `locale`. The notification's data holds `kind: job_openings`. Devices
whose token is no longer registered are deleted. Openings are stored before the notification is
sent, so a failed send is logged and the run still succeeds. The run's logged result reports
`notifiedUserCount`, the users told on at least one device.

## Portfolio updates

`portfolioUpdates-<collection>` records each change to the portfolio, and
`sendPortfolioUpdates` notifies the app's users of them. There is one `portfolioUpdates`
function for each portfolio collection: `profile`, `experiences`, `expertise`, `projects`,
`services` and `testimonials`.

- `portfolioUpdates-<collection>` runs when a document `<collection>/{locale}` is created,
  changed or deleted, in `us-central1`, the region of the Cloud Firestore database. In one batched
  write, it:
  - records the change time of the collection in `portfolio_versions/{locale}`, such as
    `{ profile: <time>, projects: <time> }`. The app compares these times with its caches and
    refreshes only the collections that changed.
  - adds the collection to the batch of the locale, `portfolio_update_batches/{locale}`, as
    `{ collections: [...], lastChangedAt: <time> }`.
- It records nothing when the document was deleted, when its content did not change, such as an
  import of the same data, or when the locale is not two lowercase letters. It logs the outcome:
  `recorded`, `unchanged`, `deleted` or `unknown_locale`.
- `sendPortfolioUpdates` runs every 5 minutes in `europe-west3`. It sends each batch with no
  change in the last 2 minutes as one notification to the topic `portfolio_updates_<locale>`, so
  one import that writes many documents gives one notification, 2 to 7 minutes after its last
  write. The app subscribes to the topic of its language when the user turns notifications on.
- The notification names the changed sections as the app does, in the locale (`en`, `es` or
  `nl`, English otherwise), such as the title "Portfolio updated" with "Updated: Projects and
  Services.".
- A transaction deletes each batch before it is sent, so it is sent once. A change made after
  that starts a new batch. A failed send is logged and not retried.
- The notification's data holds `kind: portfolio_update` and the changed collections, such as
  `sections: projects,services`. A newer notification replaces the one shown.

The functions run as the `notifications` service account (see
[Service account](#service-account)).

## Getting Started

The commands below read the project ID from `PROJECT_ID`. Set it first:

```bash
export PROJECT_ID=<your-firebase-project-id>
```

### Prerequisites

- Node.js 22. The `volta` field in `package.json` pins it for Volta users.
- A Firebase project on the Blaze plan, with the Cloud Scheduler API on. `.firebaserc` sets the
  default project the Firebase CLI deploys to.
- The Agent Platform API (`aiplatform.googleapis.com`) on, and the `job-openings` service
  account with its roles. See [Service account](#service-account).
- The Eventarc API on, and the `notifications` service account with its roles.
- A Cloud Firestore database in `us-central1`, where the Firestore triggers run.
- The Firebase CLI, signed in to an account that can deploy to the project.

### Service account

`fetchJobOpenings` runs as the `job-openings` service account, which may only read and write
Firestore, call Gemini and send notifications. It calls Gemini as that account, so there is no
API key to store. The code builds each account's full email from the project it is deployed to.

Enable the API, create the account and grant its roles once:

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

| Role                                 | Console name                       | Needed for                                               |
| ------------------------------------ | ---------------------------------- | -------------------------------------------------------- |
| `roles/datastore.user`               | Cloud Datastore User               | Reading and writing the versions and batches             |
| `roles/firebasecloudmessaging.admin` | Firebase Cloud Messaging API Admin | Sending notifications                                    |
| `roles/eventarc.eventReceiver`       | Eventarc Event Receiver            | Receiving the Firestore events                           |
| `roles/run.invoker`                  | Cloud Run Invoker                  | Letting Eventarc and Cloud Scheduler start the functions |

Firestore triggers must run in the database's region, set by `firestoreTriggerRegion` in
`src/shared/function_options.ts`. Check the location with:

```bash
gcloud firestore databases describe --project="$PROJECT_ID" --format="value(locationId)"
```

Deploying needs permission to act as these accounts, which project Owners have.

The model and its location are `geminiModel` and `geminiLocation` in `src/shared/gemini.ts`.
Before changing the model, check that it answers in the `global` location, for example from
Cloud Shell:

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  "https://aiplatform.googleapis.com/v1/projects/$PROJECT_ID/locations/global/publishers/google/models/gemini-2.5-flash:generateContent" \
  -d '{"contents":[{"role":"user","parts":[{"text":"Reply OK"}]}]}'
```

Each request sets a `thinkingBudget`, which Gemini 2.5 models take; Gemini 3 models take a
`thinkingLevel` instead.

### Installation

From `tool/functions`:

```bash
npm ci            # install from package-lock.json
npm run format    # format with Prettier
npm run build     # compile to lib/
```

## Deployment

```bash
melos run deploy_functions
```

This runs `npm ci` and `npm run check` in `tool/functions`, then
`firebase deploy --only functions:portrai`, whose predeploy step runs `npm run build`. Deploying
a named codebase only changes the functions in that codebase, so functions deployed from
elsewhere are left alone. To deploy one function, run
`firebase deploy --only functions:portrai:fetchJobOpenings` from `tool/functions`. The deploy
does not change Firestore rules or indexes.

### Deploying from GitHub Actions

`functions_production.yaml` deploys the `portrai` codebase when a push to `develop` changes
`tool/functions` or the workflow. It first runs `functions.yaml`, the same check as pull
requests, then `firebase deploy --only functions:portrai --non-interactive --force` with
`firebase-tools` 15.34.1. `--force` deletes functions removed from the codebase and sets the
container image cleanup policy without a prompt. A newer push waits for a running deploy instead
of cancelling it.

The deploy signs in as the `github-actions-functions` service account, whose base64-encoded key
is the `FUNCTIONS_DEPLOY_SERVICE_ACCOUNT` secret, and deploys to the project in the
`FIREBASE_PROJECT_ID` secret. Create the account, grant its roles and store its key once:

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

#### Owner-only setup

The deploy account may not change IAM policies, so a project Owner grants these once. When one is
missing, the deploy fails with the message below. Grant the roles, then re-run the failed job.

- **The first 2nd-gen or Firestore-triggered function in the project** fails with "We failed to
  modify the IAM policy for the project". Grant the Google service agents their roles:

  ```bash
  PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com" \
    --role=roles/iam.serviceAccountTokenCreator
  for role in roles/run.invoker roles/eventarc.eventReceiver; do
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" --role="$role"
  done
  ```

  The Eventarc service agent can take a few minutes to get its permissions after that. Until
  then, the deploy fails with "Permission denied while using the Eventarc Service Agent".

- **Each new scheduled function** fails with "Failed to set the IAM Policy on the Service". The
  Firebase CLI lets the function's account call its Cloud Run service, which the deploy account
  may not do. The first deploy still creates the service, so grant it, with the service named
  after the function in lowercase:

  ```bash
  gcloud run services add-iam-policy-binding <function-name-in-lowercase> \
    --region=europe-west3 --project="$PROJECT_ID" \
    --member="serviceAccount:<account>@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role=roles/run.invoker
  ```

  `fetchJobOpenings` runs as `job-openings`, and `sendPortfolioUpdates` as `notifications`.

## Testing

Tests use Vitest and live under `test/`, mirroring `src/`. From `tool/functions`:

```bash
npm test          # run the tests
npm run check     # format check, type check and tests, as CI runs them
```

From the workspace root, `melos run functions_check` runs `npm ci` and `npm run check`. The
`functions.yaml` workflow runs `npm ci` and `npm run check` on pull requests that change
`tool/functions`.
