class PasswordRemindersController < ApplicationController

  # Presenta el formulari pera omplir el mail on enviar el password reminder
  # GET /password_reminders/new
  def new
    @title = "Recreate Password"
  end

  # Crea i Envia el password reminder
  # POST /password_reminders
  def create
    user = User.find_by_email(params[:password_reminder][:email])
    if user.nil?
      # Create an error message and re-render the password reminder form
      flash.now[:error] = "User doesn't exist!"
      @title = "Recreate Password"
      render 'new'
    else
      # Generates a Password Reminder and notifies user that is being sent a mail
      user.generate_password_reminder
      UserMailer.password_reminder(user).deliver
      flash[:success] = "Password Reminder sent to #{user.email}! check it soon."
      redirect_to root_path
    end
  end

  # Mostra el formulari per recrear el password
  # GET /password_reminders/:token
  def edit
    pr = PasswordReminder.find_by_token(params[:token], :include=>:user)  # inclou el user
    unless pr.nil?
      @user = pr.user
      @title = "Type new password"
    else
      flash[:error] = "Password Reminder is not valid"
      redirect_to root_path
    end
  end

end