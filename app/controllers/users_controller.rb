class UsersController < ApplicationController

  # MME Els usuaris no autenticats nomes poden mostrar un usuari i crear una compta
  before_filter :authenticate, :except => [:show, :new, :create, :password, :activation]
  # MME evitem que usuaris no correctes puguin editar altres registres
  before_filter :correct_user, :only => [:edit, :update]
  # MME nomes permetem esborrar als administradors
  before_filter :admin_user, :only => :destroy
  # MME Signed-in users have no reason to access the new and create actions
  before_filter :signed_in_user, :only => [:new, :create]

  # MME will_paginate: valor per defecte de items per pagina
  ITEMS_PER_PAGE = 5

  # GET /users
  # GET /users.json
  def index
    @title = "All users"
    @users = User.paginate(:page=>params[:page], :per_page => ITEMS_PER_PAGE)
    session[:idx_last_page]=params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.not_messages.paginate(:page=>params[:page], :per_page => 5)
    @title = "Show '#{@user.name}'"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @title = "Sign Up"
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    # @user ja el troba el before_filter correct_user
    # @user = User.find(params[:id]) 
    @title = "Edit User"
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        format.html {
          @user.generate_activation_token
          UserMailer.activation_token(@user).deliver
          flash[:success] = "Benvingut a Rettiwet! ... T'hem enviat un mail per activar el teu account ... consulta'l en breu!"
          redirect_to signin_path
        }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { 
          @title = "Sign Up"
          render action: "new" 
        }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    # @user ja el troba el before_filter correct_user
    # @user = User.find(params[:id]) 

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, :flash => { success: 'Profile updated.'} }
        format.json { head :ok }
      else
        format.html { 
          @title = "Edit user"
          render "edit" 
        }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # Actualitza el password de l'usuari, pero sense ser necessari que l'usuari estigui signed in (password reminder)
  # PUT /users/1/password
  # PUT /users/1.json/password
  def password
    @user = User.find_by_password_reminder(params[:token])
    respond_to do |format|
      if @user
        if @user.update_attributes(params[:user])
          format.html { redirect_to root_path, :flash => { success: 'Password updated'} }
          format.json { head :ok }
        else
          format.html {
            @title = "Edit user"
            render "password_reminders/edit"
          }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path, :flash => { error: 'Invalid Password Reminder'} }
        format.json { head :ok }
      end
    end
  end

  # Activa l'usuari quan aquest clica al link del token que se li ha enviat
  # GET /users/1/activation
  # GET /users/1.json/activation
  def activation
    @user = User.find_by_activation_token(params[:token])
    respond_to do |format|
      if @user
        @user.activate
        @user.remove_activation_token
        format.html { redirect_to signin_path, :flash => { success: "You've successfully activated your account ... please signin!"} }
        format.json { head :ok }
      else
        format.html { redirect_to root_path, alert: 'Invalid Activation Token' }
        format.json { head :ok }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    user=User.find(params[:id])
    if current_user?(user)
      flash[:error] = "Admin user can't do suicide"
    else
      user.destroy
      flash[:success] = "User destroyed"
    end
    
    respond_to do |format|
      format.html { redirect_to users_url(:page=>session[:idx_last_page]) }
      format.json { head :ok }
    end

  end

  # GET /users/1/following
  # GET /users/1/following.json
  def following
    @title = "Following"
    @user=User.find(params[:id])
    @other_users=@user.following.paginate(:page=>params[:page], :per_page => 30)
    respond_to do |format|
      format.html { render 'show_follow' }
      format.json { render json: @other_users }
    end
  end

  # GET /users/1/followers
  # GET /users/1/followers.json
  def followers
    @title = "Followers"
    @user=User.find(params[:id])
    @other_users=@user.followers.paginate(:page=>params[:page], :per_page => 30)
    respond_to do |format|
      format.html { render 'show_follow' }
      format.json { render json: @other_users }
    end
  end

  # Prepara el formulari de resposta per a enviar un micropost reply a un usuari
  # GET /users/1/reply
  # GET /users/1/reply.json
  def reply
    @title = "Reply"
    @user=User.find(params[:id])
    @micropost=Micropost.new
    respond_to do |format|
      format.html
      format.json { render json: @micropost }
    end

  end

  # Prepara el formulari de resposta per a enviar un micropost message a un usuari
  # GET /users/1/message
  # GET /users/1/message.json
  def message
    @title = "Message"
    @user=User.find(params[:id])
    @messages = current_user.messages_to_or_from(@user).paginate(:page=>params[:page], :per_page => 10)
    @message=Micropost.new
    respond_to do |format|
      format.html
      format.json { render json: @messages }
    end
  end

  private

    def correct_user
      @user ||= User.find(params[:id])
      unless current_user?(@user)
        flash[:notice]="No es permes editar #{@user.name} per #{current_user.name}"
        redirect_to root_path
      end
    end

    def admin_user
      unless current_user && current_user.admin?
        flash[:notice]="Nomes poden esborrar els usuaris admin"
        redirect_to root_path
      end
    end

    def signed_in_user
      if signed_in?
        flash[:notice]="#{current_user.name} ... you've already Signed Up!"
        redirect_to root_path
      end
    end
end
