# Functions

Cloud Functions for PortRai, written in TypeScript and deployed as the `portrai` codebase.

| Function           | Trigger                             | Feature                       |
| ------------------ | ----------------------------------- | ----------------------------- |
| `fetchJobOpenings` | Every Monday 06:00 Europe/Amsterdam | [Job openings](#job-openings) |

## Structure

```
src/
  index.ts          # initializes Firebase and exports every function
  shared/           # code any feature can use: HTTP JSON, JSON parsing, Gemini, the region
  job_opening/      # one folder per feature, with its function in fetch_job_openings.ts
test/               # mirrors src/
```

A feature imports from `shared/` but never from another feature. Code two features need moves
into `shared/`.

### Adding a function

1. Create `src/<feature>/` with the function in its own file, using `functionRegion` from
   `shared/function_options.ts`.
2. Export it from `src/index.ts`.
3. Add tests under `test/<feature>/` and a row to the table above.

Every function is part of the `portrai` codebase, so `melos run deploy_functions` deploys it
with the others.

## Job openings

`fetchJobOpenings` collects remote job openings, scores how well each fits the portfolio's
skills with Gemini and stores the good fits for each user who has job search turned on.

### Features

- Runs every Monday at 06:00 Europe/Amsterdam in `europe-west3`.
- Reads remote jobs from two public feeds: Remotive and Arbeitnow.
- Maps every job to one shape, turns HTML descriptions into plain text and removes duplicates
  across feeds.
- Keeps a job when at least two portfolio skills appear in its title, tags or description.
- Scores up to 50 of those jobs from 0 to 100 with Gemini and keeps the ones scoring 60 or more.
- Writes the kept jobs to `users/{uid}/job_openings/{dedupeKey}` for every user whose
  `jobSearch.enabled` is `true`.
- Lets openings expire 14 days after the last run that found them.

### How it works

#### Portfolio skills

The skills come from the same Firestore documents the app reads, in English only, since both
feeds publish mostly in English. Each collection holds one document per locale with the items in
one array:

| Document         | Field                        |
| ---------------- | ---------------------------- |
| `expertise/en`   | `experties[].skills[].name`  |
| `projects/en`    | `projects[].technologies`    |
| `experiences/en` | `experiences[].technologies` |

Duplicates are dropped ignoring case. A skill matches only as a whole term, so `Java` does not
match `JavaScript`, while `C++`, `.NET` and `Node.js` still match. Skills of one or two
characters, such as `Go` or `R`, count only when they appear in the title or tags.

#### Feeds

| Feed                                                      | Request                                              | Kept                     | Terms                                                                                                                              |
| --------------------------------------------------------- | ---------------------------------------------------- | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| [Remotive](https://remotive.com/api-documentation)        | `GET /api/remote-jobs?category=software-development` | Every job                | Link to the job's Remotive URL, name Remotive as the source, don't pass jobs to other job sites, request at most a few times a day |
| [Arbeitnow](https://www.arbeitnow.com/blog/job-board-api) | `GET /api/job-board-api?page=1..5`                   | Jobs with `remote: true` | Don't abuse the free API, link back to the site                                                                                    |

Every stored opening keeps the source's job `url` and `sourceName`, which the app must show
with the job. Remotive's free API returns only its 10 most recent jobs, which arrive 24 hours
after they are posted on Remotive.

If one feed fails, the run continues with the others and logs a warning. The run fails only
when every feed fails. The function does not retry, so a failed run waits for the next Monday.

#### Scoring

Keyword matching is a cheap first filter. Gemini (`gemini-3.8-flash` through the Agent
Platform, formerly Vertex AI, in the `global` location) then reads each matched job with the
portfolio skills and replies with JSON:

| Field           | Kept as                                                                          |
| --------------- | -------------------------------------------------------------------------------- |
| `score`         | An integer from 0 to 100, rounded and clamped                                    |
| `matchedSkills` | Only portfolio skills, in their portfolio spelling, added to the keyword matches |
| `missingSkills` | At most 8 skills the job asks for that the portfolio lacks                       |
| `reasons`       | At most 3 sentences of up to 300 characters                                      |

- **Threshold:** openings scoring below 60 are not stored. 80 or more means the job's core
  stack is in the portfolio.
- **Cost:** a run scores at most the 50 best keyword matches, ranked by matched skills and then
  by date, 2 at a time.
- **Retries:** a throttled (`429`), timed-out or server-error (`5xx`) call is retried up to 3
  times, after about 5, 10 and 20 seconds. Each attempt gets 45 seconds and each opening 150 seconds in total.
  Scoring stops starting new openings after 10 minutes, so the run ends before the function's
  15-minute timeout; skipped openings count as failed.
- **Untrusted text:** job descriptions come from public job boards. The instructions go in the
  system instruction and the job only in the prompt, as data. The reply is validated, so the
  model cannot add skills the portfolio lacks or return an unbounded text.
- **Data sent:** the portfolio skills and the job's title, company, location, types, tags and
  description. No user data is sent.
- **Failures:** a job whose score fails is skipped with a warning. The run fails without
  writing when every score fails, which usually means the API or permission is not set up.

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
feeds. To turn it on, create the document in the Firebase console: in the `users` collection,
add a document whose ID is the user's UID from Authentication, with a map field `jobSearch`
holding the boolean `enabled` set to `true` and the timestamp `updatedAt` set to now.

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

#### Expiry

Firestore deletes expired openings through a TTL policy on `expiresAt`. Create it once, with
`PROJECT_ID` set as in [Getting Started](#getting-started):

```bash
gcloud firestore fields ttls update expiresAt \
  --collection-group=job_openings \
  --enable-ttl \
  --project="$PROJECT_ID"
```

TTL deletion usually runs within a day of `expiresAt`, so expired openings can stay readable
for a short time.

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
  account with its two roles. See [Service account](#service-account).
- The Firebase CLI, signed in to an account that can deploy to the project.

### Service account

The function runs as its own service account, `job-openings`, which may only read and write
Firestore and call Gemini. It calls Gemini as that account, so there is no API key to store.
The code builds the account's full email from the project it is deployed to.

Enable the API, create the account and grant its two roles once:

```bash
gcloud services enable aiplatform.googleapis.com --project="$PROJECT_ID"
gcloud iam service-accounts create job-openings \
  --display-name="Job openings function" --project="$PROJECT_ID"
for role in roles/aiplatform.user roles/datastore.user; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:job-openings@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="$role"
done
```

| Role                    | Console name                            | Needed for                    |
| ----------------------- | --------------------------------------- | ----------------------------- |
| `roles/aiplatform.user` | Vertex AI User (or Agent Platform User) | Calling Gemini                |
| `roles/datastore.user`  | Cloud Datastore User                    | Reading and writing Firestore |

The deploy lets the account start the function from Cloud Scheduler, so it needs no other
role. Deploying needs permission to act as the account, which project Owners have.

Check that the model is offered in the `global` location before the first run. Changing the
model or location means changing `src/shared/gemini.ts` and deploying again.

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
