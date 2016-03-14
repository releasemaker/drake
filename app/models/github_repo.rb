# A {Repo} record that is associated with a Github repository.
class GithubRepo < Repo
  def self.new_from_api(data)
    new do |repo|
      repo.name = data.full_name
      repo.provider_uid_or_url = data.id
      repo.provider_data = data
    end
  end

  def owner_name
    name.split('/').first
  end

  def repo_name
    name.split('/').last
  end

  def github_client
    admin_user.github_client
  end
end
