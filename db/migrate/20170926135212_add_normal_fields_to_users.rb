class AddNormalFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :email, :string, null: true
    add_column :users, :name, :string, null: true
    add_column :users, :crypted_password, :string, null: true
    add_column :users, :salt, :string, null: true

    add_index :users, :email, unique: true
  end
end
