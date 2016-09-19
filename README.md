EFG
===

[![Build Status](https://travis-ci.org/alphagov/EFG.png?branch=master)](https://travis-ci.org/alphagov/EFG) [![Dependency Status](https://gemnasium.com/alphagov/EFG.png)](https://gemnasium.com/alphagov/EFG)

Enterprise Finance Guarantee

## Getting started

[Dotenv](https://github.com/bkeepers/dotenv) is used for managing environment variables in development:

    cp .env.example .env

You will need MySQL and an app-specific MySQL user - see `config/database.yml` for details.

    bundle install
    rake db:create
    rake db:reset

To run the tests in parallel across multiple cores create the correct number of databases for your machine and run `rake` as usual:

    rake parallel:create
    rake
