module UsersHelper

  def gravatar_for(user, options = { :size => 100 })
    gravatar_image_tag user.email.downcase, :alt => h(user.name),
                                            :class => 'gravatar round',
                                            :gravatar => options
  end

end
