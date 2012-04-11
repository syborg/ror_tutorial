class RelationshipsController < ApplicationController

  before_filter :authenticate

  # POST /relationships
  def create
    @user=User.find(params[:relationship][:followed_id])
    current_user.follow! @user
    # notifies to followed
    UserMailer.new_follower_notification(@user, current_user).deliver unless current_user.notify_followers
    respond_to do |format|
      format.html  {
        flash[:info]="Now following #{@user.name}!"
        redirect_to @user
      }
      format.js    # /app/view/relationship/create.js.erb es renderitza quan se sol.licita amb xhr (AJAX)
    end
  end

  # DELETE /relationships/1
  def destroy
    rs=Relationship.find(params[:id])
    @user=rs.followed
    # MME tambe funcionaria current_user.unfollow!(@user))
    rs.destroy
    # notifies @user that is being dropped from current_user's following list
    UserMailer.old_follower_notification(@user, current_user).deliver unless current_user.notify_followers
    respond_to do |format|
      format.html  {
        flash[:alert]="Bye #{@user.name}!"
        redirect_to @user
      }
      format.js    # /app/view/relationship/destroy.js.erb es renderitza quan se sol.licita amb xhr (AJAX)
    end
  end

end
