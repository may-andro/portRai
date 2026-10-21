# Functions

Cloud Functions for PortRai, written in TypeScript and deployed as the `portrai` codebase.

| Function           | Trigger                             | Feature                       |
| ------------------ | ----------------------------------- | ----------------------------- |
| `fetchJobOpenings` | Every Monday 06:00 Europe/Amsterdam | [Job openings](#job-openings) |

## Structure

```
src/
  index.ts          # initializes Firebase and exports every function
  shared/           # code any feature can use: HTTP JSON, JSON parsing, the region
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

`fetchJobOpenings` collects remote job openings that match the portfolio's skills and stores
them for each user who has job search turned on.

### Features

- Runs every Monday at 06:00 Europe/Amsterdam in `europe-west3`.
- Reads remote jobs from two public feeds: Remotive and Arbeitnow.
- Maps every job to one shape, turns HTML descriptions into plain text and removes duplicates
  across feeds.
- Keeps a job when at least two portfolio skills appear in its title, tags or description.
- Writes the matches to `users/{uid}/job_openings/{dedupeKey}` for every user whose
  `jobSearch.enabled` is `true`.
- Lets openings expire 14 days after the last run that found them.

### How it works

#### Portfolio skills

The skills come from the same Firestore collections the app reads, in every locale:

| Collection    | Field           |
| ------------- | --------------- |
| `expertise`   | `skills[].name` |
| `projects`    | `technologies`  |
| `experiences` | `technologies`  |

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

#### Firestore data

A user takes part when their document has job search turned on:

```jsonc
// users/{uid}
{
  "jobSearch": { "enabled": true },
}
```

No user document exists until job search is turned on, and a run with no such users skips the
feeds. To turn it on, create the document in the Firebase console: in the `users` collection,
add a document whose ID is the user's UID from Authentication, with a map field `jobSearch`
holding the boolean `enabled` set to `true`.

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
| `matchedSkills` | string[]       | Portfolio skills found in the job          |
| `publishedAt`   | timestamp      | When the source published the job          |
| `fetchedAt`     | timestamp      | When this run stored it                    |
| `expiresAt`     | timestamp      | `fetchedAt` plus 14 days                   |

A job found again replaces its document, which also moves `expiresAt` back.

#### Expiry

Firestore deletes expired openings through a TTL policy on `expiresAt`. Create it once:

```bash
gcloud firestore fields ttls update expiresAt \
  --collection-group=job_openings \
  --enable-ttl \
  --project=portrai-96f2b
```

TTL deletion usually runs within a day of `expiresAt`, so expired openings can stay readable
for a short time.

## Getting Started

### Requirements

- Node.js 22. The `volta` field in `package.json` pins it for Volta users.
- The Firebase project `portrai-96f2b` on the Blaze plan, with the Cloud Scheduler API on.
- The Firebase CLI, signed in to an account that can deploy to the project.

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
