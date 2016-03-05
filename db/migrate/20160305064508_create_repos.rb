class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :type
      t.string :name
      t.boolean :enabled
      t.string :provider_uid_or_url
      t.json :provider_data

      t.timestamps null: false
    end
  end
end
