source 'http://rubygems.org'

gem 'bundler', '~> 1.6.0'
gem "rails", "3.1.10"
gem "mysql2", "~> 0.3.11" # this gem works better with utf-8

gem 'jquery-rails', '1.0.19'
gem 'devise', '2.0.4' # user authentication
gem 'formtastic', '2.1.1' # create forms easier
gem "formtastic-bootstrap", :git => "https://github.com/cgunther/formtastic-bootstrap.git", :branch => "bootstrap-2"
gem 'globalize3', '0.2.0' # internationalization
gem 'psych', '1.2.2' # yaml parser - default psych in rails has issues
gem 'will_paginate', '3.0.3' # add paging to long lists
gem 'gon', '2.2.2' # push data into js
gem 'dynamic_form', '1.1.4' # to see form error messages
gem 'ancestry', '1.2.5' # control parent/child relationships with shapes
gem 'nokogiri', '1.5.2' # xml parser
#gem 'exception_notification', '2.5.2' # send an email when exception occurs
gem 'exception_notification', :require => 'exception_notifier'
gem 'capistrano'
gem 'therubyracer'
gem 'fancybox-rails', '~> 0.1.4' # to open pop-up windows
gem "i18n-js", "~> 2.1.2" # to show translations in javascript
gem "active_attr", "~> 0.5.1" # to create tabless models; using for contact form
gem "dalli", "~> 2.0.5" # memory cache
gem "kgio", "~> 2.7.4" # makes dalli faster
gem "json", "~> 1.7.4" # json parser faster than default
#gem "useragent", :git => "https://github.com/jilion/useragent.git" # browser detection
gem "useragent", "~> 0.7.0"
gem "rubyzip", "~> 0.9.9" # generate zip files
gem 'rack-utf8_sanitizer', '~> 1.2.2' # prevent invalid encoding error

group :development do
	gem 'mailcatcher', '0.5.10' # small smtp server for dev, http://mailcatcher.me/
#	gem 'ruby-prof' # analyze code perofrmance
#	gem "query_reviewer", :git => "git://github.com/nesquena/query_reviewer.git" # query analyzer
#	gem "bullet" # notifies you when n+1 queries are being called
#	gem 'slim_scrooge' # looks for queries that get columns that are not used
#	gem "rails-indexes" # looks for fields in db that need index
#	gem "lol_dba", "~> 1.3.0" # looks for fields in db that need index
  gem 'rb-inotify', '~> 0.9' # rails dev boost needs this
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git' # speed up loading page in dev mode
end

group :assets do
  gem "sass-rails", "3.1.4"
  gem "coffee-rails", "~> 3.1.1"
  gem "uglifier", ">= 1.0.3"
  gem "therubyracer"
  gem "less-rails"
	gem "twitter-bootstrap-rails", "~> 2.1.0"
  gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
  gem 'jquery-ui-rails'
end

group :staging do
	gem 'unicorn', '4.2.1' # http server
end

group :production do
	gem 'unicorn', '4.2.1' # http server
end
