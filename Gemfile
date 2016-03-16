source "https://rubygems.org"

# rails basics
gem "rails", "4.2.6"
gem "mysql2", "0.3.20"
gem "uglifier", "1.2.4"
gem "sass-rails", "4.0.2"
gem "less-rails", "2.2.6"
gem "builder", "3.1.4"
gem "jquery-rails", "3.1.3"
gem "therubyracer", "0.12"

# rails additions
gem "protected_attributes", "1.0.8"
gem "simple_form", "~> 3.2"
gem "useragent", "0.4.16"

# types and conversions
gem "money", "~> 6.7"
gem "monetize", "~> 1.4"
gem "uk_postcode", "~> 2.1"
gem "weekdays", "1.0.2"

# pagination
gem "will_paginate", "3.0.5"
gem "bootstrap-will_paginate", "0.0.10"

# user authentication
gem "devise", "~> 3.5"
gem "devise-encryptable", "~> 0.2"
gem "devise_zxcvbn", "~> 2.1"
gem "devise_security_extension", "~> 0.8"

# authorization
gem "canable", "0.3.0"

# styles
gem "bourbon", "2.1.1"
gem "twitter-bootstrap-rails", "2.2.7"

# csv and pdf handling
gem "prawn", "~> 2.1"
gem "prawn-table", "~> 0.2"
gem "progressbar", "0.11.0"

# background jobs
gem "whenever", "0.9.2", require: false

# web server
gem "unicorn", "4.6.2"
gem "rack-ssl-enforcer"

# monitoring and stats
gem "exception_notification", "4.0.1"
gem "aws-ses", require: "aws/ses" # Needed by exception_notification
gem "statsd-ruby", "1.0.0"

# logging
gem "lograge", "0.1.2"

# gds specific
gem "plek", "0.3.0"

group :development, :test do
  gem "brakeman", "2.0.0"
  gem "ci_reporter", "1.8.4"
  gem "parallel_tests", "0.16.10"
  gem "rspec-rails", "~> 3.4"
  gem "simplecov-rcov", "0.2.3"
end

group :test do
  gem "capybara"
  gem "factory_girl_rails", "~> 4.6"
  gem "launchy", "2.1.0"
  gem "pdf-reader", "1.1.1"
  gem "rspec-collection_matchers"
  gem "rspec-its"
  gem "timecop"
end

group :extract do
  gem "data-anonymization", "~> 0.7"
  gem "sqlite3", "1.3.6"
end
