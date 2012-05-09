atom_feed('xml:lang'=>'CA-es') do |feed|
  feed.title "#{@user.name}'s Microposts"
  feed.updated(@microposts.first.created_at) if @microposts.length > 0
  @microposts.each do |mp|
    feed.entry(mp) do |entry|
      entry.title "MP # #{mp.id}: " + (mp.is_reply? ? "(Reply to #{mp.replied_user.name})":"")
      entry.content(mp.content, :type => 'text')
      entry.author do |author|
        author.name(@user.name)
      end
    end
  end
end