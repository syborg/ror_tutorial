class ApplicationController < ActionController::Base

  protect_from_forgery

  # MME sEls moduls XXXHelper estan disponibes des dels View. Ara b, per conveniencia
  # les funcions de les sessions volem que estiguin disponibles a tota l'aplicacio
  # per lo qual la incloem aqui
  include SessionsHelper    
end
