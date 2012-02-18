class SessionsController < ApplicationController
  
  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email], 
                             params[:session][:password])
    if user.nil?
      # Create an error message and re-render the signin form.
      flash.now[:error] = "Invalid credentials"
      @title = "Sign in"
      render 'new'
    else
      # Sign the user in and redirect to the user's show page.
      flash[:success] = "Welcome!"
      sign_in user
      redirect_back_or user
    end
  end

  def destroy
    flash[:alert] = "Bye Babe! ... you're signed out"
    sign_out
    redirect_to root_path
  end

 end
