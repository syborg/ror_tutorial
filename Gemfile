source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
# MME classe que manega els gravatars globals
gem 'gravatar_image_tag', '1.0.0.pre2'

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
  # MME crea grafic
  # $ bundle viz
  gem 'ruby-graphviz'
end

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
  # MME enables context tot tests
  gem 'shoulda-context'
end
