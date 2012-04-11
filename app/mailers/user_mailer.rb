class UserMailer < ActionMailer::Base
  default from: "support@rettiwet.com"

  # MME sends a mail to notify to a user that is being followed by a follower
  def new_follower_notification(user, follower)
    @user, @follower = user, follower
    mail :to=>"#{user.name} <#{user.email}>", :subject=>"You've got a new follower!"
  end

  # MME sends a mail to notify to a user that is being followed by a follower
  def old_follower_notification(user, follower)
    @user, @follower = user, follower
    mail :to=>"#{user.name} <#{user.email}>", :subject=>"You've lost a follower!"
  end

end
