source "https://rubygems.org"

gem "rails", "~> 7.2.3"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

group :production do
  gem "pg"
  gem "net-imap", require: false
  gem "net-pop", require: false
  gem "net-smtp", require: false
end

group :development, :test do
  gem "sqlite3", "~> 1.4"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 8.0.2"
  gem "factory_bot_rails"
end
