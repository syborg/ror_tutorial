class MicropostsController < ApplicationController

  before_filter :authenticate, :except=>:index   # in session_helper.rb (shared with UsersController)
  before_filter :owner_user, :only => :destroy

  # POST /microposts
  # POST /microposts.json
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    # MME parses if @ or d at the beginning to patch and convert to reply or message
    @micropost.parse_and_patch

    respond_to do |format|
      if @micropost.save
        format.html { 
          flash[:success]= 'Micropost was successfully created.' 
          redirect_to root_path
        }
        format.json { render json: @micropost, status: :created, location: @micropost }
      else
        format.html { render 'pages/home' }
        format.json { render json: @micropost.errors, status: :unprocessable_entity }
      end
    end
  end

 
  # DELETE /microposts/1
  # DELETE /microposts/1.json
  def destroy
    # MME @micropost already set by :owner_user
    @micropost.destroy

    respond_to do |format|
      format.html { redirect_back_or root_path }
      format.json { head :ok }
    end
  end

  # GET /users/:id/microposts
  # GET /users/:id/microposts.rss
  # GET /users/:id/microposts.json
  def index
    @user=User.find_by_id(params[:user_id])
    respond_to do |format|
      format.html { @microposts=@user.microposts.not_messages.paginate(:page => params[:page], :per_page => 5) }
      format.rss { @microposts=@user.microposts.not_messages }
      format.atom { @microposts=@user.microposts.not_messages }
      format.json { @microposts=@user.microposts.not_messages
                    render json: @microposts }
    end
  end


  private

    def owner_user
      # ALTERNATIVA 1
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_path, :alert => "only owner can delete microposts" unless @micropost

      # ALTERNATIVA 2: utilitzant find (genera excepcio si no troba) i rescue
      # @micropost = current_user.microposts.find(params[:id])
      # rescue
      #   redirect_to root_path, :alert => "only owner can delete microposts" unless @micropost
      # end

      # ALTERNATIVA 3: No tant segur segons http://www.rubyfocus.biz/blog/2011/06/15/access_control_101_in_rails_and_the_citibank-hack.html
      # @micropost = Micropost.find(params[:id])
      # redirect_to root_path, :alert => "only owner can delete microposts" unless current_user?(@micropost.user)
    end

end
