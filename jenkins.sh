#!/bin/bash -x
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment --without=development

export DEVISE_SECRET_KEY=example_secret_key
export DEVISE_PEPPER=example_pepper

RAILS_ENV=test bundle exec rake db:setup
RAILS_ENV=test bundle exec rake db:migrate
RAILS_ENV=test COVERAGE=1 bundle exec rake ci:setup:rspec parallel:prepare parallel:spec
RESULT=$?
exit $RESULT
