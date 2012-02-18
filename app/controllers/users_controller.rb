class UsersController < ApplicationController

  # MME evitem que usuaris no autenticats puguin editar registres
  before_filter :authenticate, :only => [:edit, :update, :index, :destroy]
  # MME evitem que usuaris no correctes puguin editar altres registres
  before_filter :correct_user, :only => [:edit, :update]
  # MME nomes permetem esborrar als administradors
  before_filter :admin_user, :only => :destroy

  # GET /users
  # GET /users.json
  def index
    @title = "All users"
    @users = User.paginate(:page=>params[:page], :per_page=>10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
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
          sign_in @user
          flash[:success] = "Benvingut a l'aplicacio de prova!"
          redirect_to @user
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

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed"

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end

  end

  private

    def authenticate
      deny_access unless signed_in?
    end

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
end
