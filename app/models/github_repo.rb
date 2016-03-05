class GithubRepo < Repo
  def self.new_from_api(data)
    new do |repo|
      repo.name = data.full_name
      repo.provider_data = data
    end
  end
end
