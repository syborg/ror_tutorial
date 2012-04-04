class AddPrivateToMicropost < ActiveRecord::Migration
  def change
    add_column :microposts, :private, :boolean
  end
end
