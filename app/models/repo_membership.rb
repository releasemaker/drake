# A record representing a specific user's access to a {Repo}.
# If a record exists joining the user to a repo, they have at least read-only access.
# This record can also include {#write} and {#admin} booleans that express additional permission.
class RepoMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :repo
end
