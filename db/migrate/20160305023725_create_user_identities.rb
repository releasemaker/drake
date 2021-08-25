# frozen_string_literal: true

class CreateUserIdentities < ActiveRecord::Migration[5.1]
  def change
    create_table :user_identities do |t|
      t.references :user
      t.string :provider
      t.string :uid
      t.json :data

      t.timestamps null: false
    end
    add_foreign_key :user_identities, :users
    add_index :user_identities, [:user_id, :provider], unique: true
    add_index :user_identities, [:provider, :uid], unique: true
  end
end
