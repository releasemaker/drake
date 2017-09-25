class DraftRelease
  def self.for_repository(user_name:, repo_name:)
    new(user_name: user_name, repo_name: repo_name)
  end

  def initialize(user_name:, repo_name:)
    self.user_name = user_name
    self.repo_name = repo_name
    self.draft_release = existing_draft_release || empty_draft_release
  end

  def append_to_body(new_content)
    self.body = body.sub(/(\r?\n)*\Z/, "\r\n#{new_content}\r\n")
    self
  end

  delegate :tag_name, :name, :body, :body=, :target_commitish, to: :draft_release

  def save
    if draft_release.id
      github.repos.releases.edit(user_name, repo_name, draft_release.id, draft_release)
    else
      github.repos.releases.create(user_name, repo_name, draft_release)
    end
  end

  def next_release_version
    @next_release_version ||= Versionomy.parse(latest_release_version).bump(:minor).to_s
  end

  private

  attr_accessor :user_name
  attr_accessor :repo_name
  attr_accessor :draft_release

  def github
    @github ||= Github.new do |config|
      config.oauth_token = ENV['GITHUB_AUTH_TOKEN']
    end
  end

  def existing_draft_release
    github.repos.releases.list(user_name, repo_name).each_page do |page|
      page.each do |release|
        return release if release.draft
      end
    end
    nil
  rescue Github::Error::NotFound
    nil
  end

  def empty_draft_release
    Hashie::Mash.new(
      tag_name: next_release_version,
      target_commitish: 'master',
      name: next_release_version,
      body: '',
      draft: true, # TOOD: force this on save
    )
  end

  def latest_release
    github.repos.releases.latest(user_name, repo_name)
  rescue Github::Error::NotFound
    nil
  end

  def latest_release_version
    @latest_release_version ||= latest_release&.tag_name || 'v0.0.0'
  end
end
