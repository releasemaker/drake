# frozen_string_literal: true

class AddNormalFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :users, :email, :string, null: true
    add_column :users, :name, :string, null: true
    add_column :users, :crypted_password, :string, null: true
    add_column :users, :salt, :string, null: true
    # rubocop:enable Rails/BulkChangeTable

    add_index :users, :email, unique: true
  end
end
