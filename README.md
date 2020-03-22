[![CircleCI](https://circleci.com/gh/releasemaker/drake.svg?style=shield&circle-token=fec31c3a0c46b668a8338b1c935e3d4c4654259e)](https://circleci.com/gh/releasemaker/drake)
[![Codacy](https://api.codacy.com/project/badge/Grade/d28ce4c6f44741d2a9bddd01a3ff08b0)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=robindaugherty/drake&amp;utm_campaign=Badge_Grade)
[![Coverage](https://api.codacy.com/project/badge/Coverage/d28ce4c6f44741d2a9bddd01a3ff08b0)](https://www.codacy.com/app/releasemaker/drake?utm_source=github.com&utm_medium=referral&utm_content=releasemaker/drake&utm_campaign=Badge_Coverage)
[![Join the chat at https://gitter.im/Release-Maker/community](https://badges.gitter.im/Release-Maker/community.svg)](https://gitter.im/Release-Maker/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# Release Maker

When notified by Github that a pull request was merged, creates or adds to a draft
release on Github for the same project.

To run or develop this project:

* `git clone <repository-url>` this repository
* change into the new directory
* `rbenv install`
* `gem install bundler`
* `bundle install`

## Functionality

This is a Rails application that uses:

* Postgres as a relational database. It [manages changes to the structure of the database](http://edgeguides.rubyonrails.org/active_record_migrations.html).

### Prerequisites

This project uses `rbenv` to install and select the correct version of Ruby.
This is optional, but it is highly recommended.
You can also use rvm for example, but you will need to configure it within this project.

The `pg` gem requires that Postgres client libraries be installed.

### Configuration

The following environment variables are used:

- `WEBHOOK_PROTOCOL`: 'https' by default.
- `GITHUB_AUTH_TOKEN`: Personal Access Token used during tests where the Github API is going to be called. When recording VCR episodes, this will need to be set.

The following are required in production:

- `DATABASE_URL`: Database used to store operational data.
- `GITHUB_OAUTH_CLIENT_ID`
- `GITHUB_OAUTH_SECRET`
- `GITHUB_WEBHOOK_SECRET`: Webhook secret configured on Github
- `WEBHOOK_HOST`
- `SENTRY_DSN`: Used by Sentry. Should not be set in development unless developing changes to Sentry integration.

### Github OAuth

Callback URL for Github is `/auth/github/callback`

## Development

It is recommended that you use [puma-dev](https://github.com/puma/puma-dev)
so that the application runs
on a real-looking hostname, and doesn't clash with other applications.
This is best managed using Powder, which can be installed using `gem install powder`.

To set this application up:

    powder link

Then visit [http://releasemaker.localdev](http://releasemaker.localdev).
The app will be started automatically.

### Better Errors

We use [Better Errors](https://github.com/charliesome/better_errors) as a development console,
which allows inspection of runtime state and an in-browser REPL.
It is presented when an error occurs during an HTML request.

If an error occurs during a JSON request, the response will include some basic information about the error that occurred.

Visiting [/__better_errors](http://releasemaker.localdev/__better_errors) will present the console
for the most recent error that occurred.

### Tests

We use [rspec](https://www.relishapp.com/rspec).

VCR is used to record actual API responses and play them back during test runs.

If the VCR episodes need to be re-recorded, you will need to have:

- `GITHUB_AUTH_TOKEN` environment variable set to your personal access token.
- `GITHUB_TEST_REPO_OWNER` environment variable set to your Github username.
- `GITHUB_TEST_REPO_UID` set to the uid of the `release-maker-tester-no-releases` repo.
- Repository named `release-maker-tester-no-releases`
- Repository named `release-maker-tester-with-draft-release` with one draft release.
- Repository named `release-maker-tester-with-prior-release` with one completed release.

