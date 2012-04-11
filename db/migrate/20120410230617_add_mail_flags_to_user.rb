class AddMailFlagsToUser < ActiveRecord::Migration
  def change
    add_column :users, :notify_followers, :boolean, :default=>true
  end
end
