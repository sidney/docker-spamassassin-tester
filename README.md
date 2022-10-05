# docker-spamassassin-tester fork of docker-perl-tester

This repo is used to build Perl Docker images with various pre-installed bits required for building and testing SpamAssassin

- apt packages required for perl module building and for SpamAssassin building and testing
- `cpanminus`
- `App::cpm`
- dcc and re2c built from source
- various cpan modules listed below
- Mail::SPF installed as CPAN module and as application in /usr/local/bin

A cron task updates at a set interval which can be changed.

Note: if one dependency fails to install, this should not impact you as the image would not be published
on failures.

# List of Perl modules

## Available on all Perl Versions

Archive::Zip BSD::Resource BerkeleyDB Compress::Zlib DBI DB_File Devel::Cycle
Digest::SHA Digest::SHA1 Email::Address::XS Encode::Detect Encode::Detect::Detector
Geo::IP GeoIP2 GeoIP2::Database::Reader Geography::Countries HTML::Parser HTTP::Cookies
HTTP::Daemon HTTP::Date HTTP::Negotiate IO::Socket::INET6 IO::Socket::SSL IO::String
IP::Country IP::Country::DB_File LWP::Protocol::https LWP::UserAgent Mail::DKIM
Mail::DMARC::PurePerl Math::Int128 MaxMind::DB::Reader::XS Net::CIDR::Lite Net::DNS
Net::DNS::Nameserver Net::LibIDN Net::LibIDN2 Net::Patricia Net::Works::Network NetAddr::IP
Params::Validate Razor2::Client::Agent Sys::Hostname::Long Test::Perl::Critic Test::Pod
Test::Pod::Coverage WWW::RobotRules
Perl::Critic::Policy::Bangs::ProhibitBitwiseOperators Perl::Critic::Policy::Perlsecret
Perl::Critic::Policy::Compatibility::ProhibitThreeArgumentOpen
Perl::Critic::Policy::Lax::ProhibitStringyEval::ExceptForRequire
Perl::Critic::Policy::ValuesAndExpressions::PreventSQLInjection
Perl::Critic::Policy::ControlStructures::ProhibitReturnInDoBlock

## Only on Perl 5.16.3 and earlier

Devel::SawAmpersand

# Using Docker Images for your projects

The images can be found at [https://hub.docker.com/r/sidney1310/spamassassin-tester/](https://hub.docker.com/r/sidney1310/spamassassin-tester/)

The following tags are available from the repository `perldocker/perl-tester`

```
5.36
5.34
5.32
5.30
5.28
5.26
5.24
5.22
5.20
5.18
5.16
5.14
```

# Continuous Integrations

## Using the images with GitHub Workflow

Here is a sample workflow for Linux running on all Perl version 5.14 to 5.36
You can save the content in `.github/workflow/linux.yml`.

Note: this example is using cpm to install the dependencies from a cpanfile.
You can comment this line or use Dist::Zilla instead for supported Perl versions.

```yaml
name: linux

on:
  push:
    branches:
      - '*'
    tags-ignore:
      - '*'
  pull_request:

jobs:
  perl:
    env:
      # some plugins still needs this to run their tests...
      PERL_USE_UNSAFE_INC: 0
      AUTHOR_TESTING: 1
      AUTOMATED_TESTING: 1
      RELEASE_TESTING: 1

    runs-on: ubuntu-latest

    strategy:
      fail-fast: false
      matrix:
        perl-version:
          - '5.36'
          - '5.34'        
          - '5.32'
          - '5.30'
          - '5.28'
          - '5.26'
          - '5.24'
          - '5.22'
          - '5.20'
          - '5.18'
          - '5.16'
          - '5.14'

    container:
      image: perldocker/perl-tester:${{ matrix.perl-version }}

    steps:
      - uses: actions/checkout@v2
      - name: perl -V
        run: perl -V
      - name: Install Dependencies
        run: cpm install -g --no-test --show-build-log-on-failure --cpanfile cpanfile
      - name: Makefile.PL
        run: perl Makefile.PL
      - name: make test
        run: make test
```

You can find more details on how to setup GitHub workflow to smoke Perl projects by reading [skaji/perl-github-actions-sample](https://github.com/skaji/perl-github-actions-sample) GitHub repository.

## Using GitHub actions

You can also consider using GitHub actions:
- [perl-actions/install-with-cpanm](https://github.com/perl-actions/install-with-cpanm)
- [perl-actions/install-with-cpm](https://github.com/perl-actions/install-with-cpm)

## Building Docker images

When pushing to GitHub, it's using a GitHub action `.github/workflows/publish-to-docker.yml`
to automagically build and publish the docker images for you.

If you consider cloning this repository, you would have to set in your GitHub repository the following secret variables, with some example values.

```
DOCKER_REPO=perldocker/perl-tester
DOCKER_USERNAME=username
DOCKER_GITHUB_TOKEN=a-token-or-password
```

## Developer Notes:

The main branch is named `main` and not `master`.

# Author

@oalders initiated the project and @atoomic tried to give it more public visibility
volunteers/ideas are welcome to improve the project.
