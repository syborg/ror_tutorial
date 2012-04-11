# MME Definint aquesta classe i registrant-la com Interceptor (veure config/initializers/setup_mail.rb) permet
# interceptar i modificar mails adequadament abans de ser enviats.
# (Similarment es pot fer despres d'enviar el mail amb els Observers)

class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "RETTIWETDEV: [#{message.to}] #{message.subject}"
    message.to = "xaxaupua@gmail.com"
  end
end