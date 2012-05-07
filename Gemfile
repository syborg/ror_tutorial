source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
# MME classe que manega els gravatars globals
gem 'gravatar_image_tag', '1.0.0.pre2'
# MME per a paginar els llistats llargs
gem 'will_paginate'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
# MME Javascript Runtime
gem 'therubyracer'

# MME suport de maquina d'estats per a fer el seguiment de les subscripcions'
gem 'state_machine'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development do
  # MME afegim annotate per a incloure comentaris que documenten la estructura de la BBDD.
  # $ bundle exec annotate --position before
  gem 'annotate', '~>2.4.1.beta'
  # MME crea grafic de dependencies dels gems i el mostra
  # $ bundle viz
  # $ display gem_graph.png
  gem 'ruby-graphviz'
  # MME to create fictious users
  gem 'faker'
end

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
  # MME enables context to tests
  gem 'shoulda-context'
  # MME easy integration tests with capybara
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'launchy'
  gem 'database_cleaner'
  # MME continuous testing (detecta canvis i reexecuta tests)
  # (veure http://railscasts.com/episodes/264-guard)
  # bundle exec guard
  gem 'rb-inotify'
  gem 'guard-test'
  gem 'guard-livereload'
  # gem 'ruby-gntp'
  gem 'libnotify'
end
