class AddRepliesToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :in_reply_to, :integer
    add_index :microposts, :in_reply_to
  end
end
