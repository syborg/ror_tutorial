xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    # channel ha de tenir minim: title, link i description
    xml.title "#{@user.name}'s Microposts"
    xml.description "Lots of microposts"
    xml.link user_microposts_url(@user, :format=>:rss)
    for mp in @microposts
      # cada chanel te varis items
      xml.item do
        # cada item te al menys description i title
        xml.title "MP # #{mp.id}: " + (mp.is_reply? ? "(Reply to #{mp.replied_user.name})":"")
        xml.description mp.content
        xml.pubDate mp.created_at.to_s(:rfc822)
      end
    end
  end
end