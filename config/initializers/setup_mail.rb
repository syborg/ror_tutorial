# MME Initializer for ActionMailer

# MME servei SMTP de google
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "rettiwet.com",
  :user_name            => "marcel.auding",  # conta de google
  :password             => "d2iJgo9s",       # conta de google
  :authentication       => "plain",
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"

# Registra l'interceptor de mails en cas de Desenvolupament (veure lib/development_mail_interceptor.rb)
require 'development_mail_interceptor'
Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?