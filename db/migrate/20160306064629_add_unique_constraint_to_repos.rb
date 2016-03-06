class AddUniqueConstraintToRepos < ActiveRecord::Migration
  def change
    add_index :repos, [:type, :provider_uid_or_url], unique: true
  end
end
