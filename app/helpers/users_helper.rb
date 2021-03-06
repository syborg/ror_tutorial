module UsersHelper

  # MME torna un gravatar o, en el seu defcte, un avatar local aleatori
  def gravatar_for(user, options = {})
   	options ||={}
    default_img_url=root_url+url_for("assets/avatars/#{random_avatar}")
   	opts = { :default => default_img_url , :size => 50 }
    opts.merge! options
    options = {
    	:alt => h(user.name),
    	:class => 'gravatar round',
    	:gravatar => opts
    }
  	# if gravatar doesn't exist we have to resize random_avatar
    options.merge!({:heigth=>opts[:size], :width=>opts[:size]}) if opts.has_key? :size
    gravatar_image_tag user.email.downcase, options
  end

  # MME returns a link with a shortened version of the name to include in replies
  def shortened_link_for(user)
    #link_to "@" + user.email.match(/(.*)@/i)[1] + user.id.to_s, user
    link_to "@" + user.pseudo_login_name, user
  end

  private

    # chooses a random image (png, jpg or gif) from .../avatars directory
    def random_avatar
      avatars_dir = File.join(Rails.configuration.root.to_s,"/app/assets/images/avatars/")
      Dir["#{avatars_dir}*{png,jpg,gif}"].map {|f| f.sub!(avatars_dir,"")}.sample
    end

end
