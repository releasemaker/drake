[![CircleCI](https://circleci.com/gh/releasemaker/drake.svg?style=shield&circle-token=fec31c3a0c46b668a8338b1c935e3d4c4654259e)](https://circleci.com/gh/releasemaker/drake)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/c88324f51bc74398933e00c5677b2b06)](https://www.codacy.com/gh/releasemaker/drake?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=releasemaker/drake&amp;utm_campaign=Badge_Grade)
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
* vite to build and serve frontend assets

### Prerequisites

This project uses [rbenv](https://github.com/rbenv/rbenv)
to install and select a consistent version of Ruby.
This is optional, but it is highly recommended.

The `pg` gem requires that Postgres client libraries be installed.

### GitHub OAuth

To enable OAuth authentication against GitHub, an OAuth application needs to exist.
Callback URL for your GitHub OAuth app is `/auth/github/callback`

## Development

### Setup

It is recommended that you use [puma-dev](https://github.com/puma/puma-dev)
so that the application runs
on a real-looking hostname with HTTPS.

1. If you don't already have rbenv set up, add rbenv to your shell rc file (run `rbenv init` for instructions)
1. [Install puma-dev](https://github.com/puma/puma-dev)
   - (This readme assumes you used the subdomain `.localdev`, but the default is `.test`)
1. [Add the puma-dev CA certificate to your browser/keychain](https://github.com/puma/puma-dev#puma-dev-root-ca)
1. Open a new shell in the project
1. `rbenv install` to install the correct version of Ruby
1. From this project run `ln -s $(pwd) ~/.puma-dev/releasemaker`
1. Copy `.env.development` to `.env.development.local`
1. Edit `.env.development.local` to set up your environment
   - Including pointing to your puma-dev key+cert so that vite's dev server can enable HTTPS

### Day-to-day

1. Start `bin/vite dev` and leave it running
1. Visit [https://releasemaker.localdev](https://releasemaker.localdev) and the app will be started automatically.
1. Run `bundle exec guard` so you can follow TDD!

### Better Errors

We use [Better Errors](https://github.com/charliesome/better_errors) as a development console,
which allows inspection of runtime state and an in-browser REPL.
It is presented when an error occurs during an HTML request.

If an error occurs during a JSON request, the response will include some basic information about the error that occurred.

Visiting [/__better_errors](https://releasemaker.localdev/__better_errors) will present the console
for the most recent error that occurred.

### Tests

We use [rspec](https://www.relishapp.com/rspec).

VCR is used to record actual API responses and play them back during test runs.

If VCR episodes need to be recorded, you need to have a GitHub account with the following repositories:
- `release-maker-tester-no-releases`
- `release-maker-tester-with-draft-release` with one draft release
- `release-maker-tester-with-prior-release` with one published release

Copy `.env.test` to `.env.test.local` and edit it to set your account information.
