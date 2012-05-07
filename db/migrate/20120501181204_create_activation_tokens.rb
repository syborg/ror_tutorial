class CreateActivationTokens < ActiveRecord::Migration
  def change
    create_table :activation_tokens do |t|
      t.references :user
      t.string :token
    end
    add_index :activation_tokens, :user_id, :unique => true
    add_index :activation_tokens, :token, :unique => true
  end
end
