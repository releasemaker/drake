# Base repository object used for single-table inheritance by Repo classes used for different
# SVM providers.
class Repo < ActiveRecord::Base
  has_many :repo_memberships
  serialize :provider_data, Hashie::Mash

  # This allows the field to be set as a Hash or anything compatible with it.
  def provider_data=(new_value)
    self[:provider_data] = Hashie::Mash.new new_value
  end
end
