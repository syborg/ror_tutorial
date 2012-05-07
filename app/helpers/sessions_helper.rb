module SessionsHelper
  
  # registra la sessio com de l'usuari (ja autenticat previament)  
  def sign_in(user)
    # MME guarda una cookie anomenada remember_token (:remember_token)
    # amb un període de vigencia de 20 anys (permenent) i signada (signed),
    # es a dir encriptada i protegida contra canvis 
    cookies.permanent.signed[:remember_token]=[user.id, user.salt]
    self.current_user=user
    # removes its password reminder if it existed to make it unusable
    user.remove_password_reminder
    user
  end

  def sign_out
    cookies.delete(:remember_token)
    self.current_user=nil
  end

  def signed_in?
    !current_user.nil?
  end

  # Assigna el propietari de la sessio
  def current_user=(user)
    @current_user = user
  end

  # Torna el propietari de la sessio
  def current_user
    # Si no s'havia iniciat s'agafa la identificacio que es tenia al cookie "remember_token"
    @current_user ||= user_from_remember_token
  end

  def current_user?(user)
    current_user == user
  end

  def authenticate
    deny_access unless signed_in?
  end

  def deny_access
    store_location
    redirect_to signin_path, :notice => "Si us plau signegi-in per a accedir"
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end

    def store_location
      session[:return_to]=request.fullpath
    end

    def clear_return_to
      session[:return_to]=nil
    end

end
