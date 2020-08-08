class DraftRelease
  def initialize(repo:)
    self.repo = repo
  end

  def append_to_body(new_content)
    self.body = body
      .sub(/(\r\n)*\Z/, "\r\n") # Get rid of duplicate newlines at the end.
      .sub(/\A\r\n\Z/, "") # If the entire body is just a newline, get rid of it.
    self.body += "#{new_content}\r\n" # Add the content to the end.
    self
  end

  delegate :tag_name, :name, :body, :body=, :target_commitish, to: :draft_release

  def save
    # We only want a single process looking up the release list. We don't want to accidentally create two release
    # with the same version number.
    RedisMutex.with_lock("DraftRelease::#{repo.owner_name}::#{repo.name}", expire: 30, block: 15) do
      if draft_release.id
        github.repos.releases.edit(repo.owner_name, repo.repo_name, draft_release.id, draft_release)
      else
        github.repos.releases.create(repo.owner_name, repo.repo_name, draft_release)
      end
    end
  end

  def next_release_version
    @next_release_version ||= Versionomy.parse(latest_release_version).bump(:minor).to_s
  end

  private

  attr_accessor :repo
  attr_accessor :draft_release

  def github
    repo.github_client
  end

  def draft_release
    @draft_release ||= (existing_draft_release || empty_draft_release)
  end

  def existing_draft_release
    github.repos.releases.list(repo.owner_name, repo.repo_name).each_page do |page|
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
    github.repos.releases.latest(repo.owner_name, repo.repo_name)
  rescue Github::Error::NotFound
    nil
  end

  def latest_release_version
    @latest_release_version ||= latest_release&.tag_name || 'v0.0.0'
  end
end
