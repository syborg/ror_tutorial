class CreatePasswordReminders < ActiveRecord::Migration
  def change
    create_table :password_reminders do |t|
      t.references :user
      t.string :token
    end
    add_index :password_reminders, :user_id, :unique => true
    add_index :password_reminders, :token, :unique => true
  end
end
