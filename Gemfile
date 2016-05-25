source 'https://rubygems.org'

RAILS_VERSION = '4.2.6'
RSPEC_VERSION = '~> 2.0.0'

gem 'rails', RAILS_VERSION

gem 'rake',          '~> 11.1'
gem 'bundler',       '~> 1.12'

gem 'request_store', '~> 1.3.1'

gem 'jquery-rails',  '~> 4.1'
gem 'env'
gem 'json',          '~> 1.8.3'

# Jruby
gem 'jruby-openssl',               :platforms => :jruby
gem 'warbler',                     :platforms => :jruby
gem 'jruby-rack-worker',           :platforms => :jruby
# gem 'glassfish', :platforms => :jruby

# DateTime Patches
gem 'home_run',                    :require => 'date', :platforms => :mri

gem 'mysql2',                      '0.4.4'

# Deploy with Capistrano
gem 'capistrano',                  '2.14.1'

# Rails Plugins
gem 'jammit',                      '~> 0.7.0'
gem 'cancan',                      '~> 1.6'
gem 'devise',                      '~> 3.5'
gem 'rubycas-client'
gem 'devise_cas_authenticatable'
gem 'mail',                        '~> 2.6'
gem 'RedCloth',                    "~> 4.2.9", :require => 'redcloth'
gem 'chronic',                     '~> 0.3.0'
gem 'pdfkit',                      '~> 0.5.0'
gem 'ezprint',                     '~> 1.0.0'
gem 'daemons',                     '~> 1.1.0'
gem 'will_paginate',               '~> 3.1.0'

gem 'delayed_job_active_record',   '~> 4.1.1'
gem 'composite_primary_keys',      '~> 8.1'

# Working On This
# gem 'delayed_job',                 '~> 3.0'
# gem 'delayed_job_data_mapper',     '~> 1.0.0.rc', :git => 'https://github.com/collectiveidea/delayed_job_data_mapper.git'

# Old - Remove Avatar Support
# gem 'rmagick',                     '~> 2.13.1'
# gem 'dm-paperclip',                '~> 2.4.1', :git => 'https://github.com/Snorby/dm-paperclip.git'

gem 'net-dns',                     '~> 0.8.0'
gem 'whois',                       '~> 3.6.5'
gem 'simple_form',                 '~> 3.2.1'
gem 'geoip',                       '~> 1.6.1'
gem 'netaddr',                     '~> 1.5.1'
# gem 'dm-zone-types',               '~> 0.3'
gem 'timezone_local',              '~> 0.1.5'

group(:development) do
  gem "letter_opener"
  gem 'thin'
  gem 'byebug'
  gem 'pry-rails'
end

group(:test) do
  gem 'capybara'
  gem 'test-unit'
  gem 'rspec',                	  RSPEC_VERSION
  gem 'rspec-core',               RSPEC_VERSION, :require => 'rspec/core'
  gem 'rspec-expectations',       RSPEC_VERSION, :require => 'rspec/expectations'
  gem 'rspec-rails',		          RSPEC_VERSION
  gem 'ansi'
  gem 'turn'
  gem 'minitest'
end
