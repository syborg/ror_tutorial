class ActivationTokensController < ApplicationController

  # Presenta el formulari pera omplir el mail on enviar el activation token
  # GET /activation_tokens/new
  def new
    @title = "Send Activation Token"
  end

  # Envia el activation token
  # POST /activation_tokens
  def create
    user = User.find_by_email(params[:activation_token][:email])
    if user.nil?
      flash.now[:error] = "User doesn't exist!"
      @title = "Send Activation Token"
      render 'new'
    else
      # Generates a Activation Token and notifies user that is being sent a mail
      user.generate_activation_token
      UserMailer.activation_token(user).deliver
      flash[:success] = "Activation Token sent to #{user.email}! check it soon."
      redirect_to root_path
    end
  end

end