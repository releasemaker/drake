# frozen_string_literal: true

class CreateRepoMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :repo_memberships do |t|
      t.references :user
      t.references :repo
      t.boolean :write
      t.boolean :admin

      t.timestamps null: false
    end
    add_foreign_key :repo_memberships, :users
    add_foreign_key :repo_memberships, :repos
    add_index :repo_memberships, [:user_id, :repo_id], unique: true
  end
end
