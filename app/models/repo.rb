# Base repository object used for single-table inheritance by Repo classes used for different
# SVM providers.
class Repo < ActiveRecord::Base
  has_many :repo_memberships
end
