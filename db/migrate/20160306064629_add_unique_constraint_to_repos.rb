class AddUniqueConstraintToRepos < ActiveRecord::Migration[5.1]
  def change
    add_index :repos, [:type, :provider_uid_or_url], unique: true
  end
end
