class PullRequestHandler
  def initialize(hook_payload:)
    self.hook = hook_payload
  end

  def handle!
    return unless hook.action == "closed" && hook.pull_request.merged
    return unless hook.pull_request.base.ref == hook.pull_request.base.repo.default_branch
    draft_release.append_to_body(new_content_for_pr).save
  end

  private

  attr_accessor :hook

  def new_content_for_pr
    "- #{hook.pull_request.title} \##{hook.pull_request.number}"
  end

  def user_name
    hook.repository.full_name.split('/').first
  end

  def repo_name
    hook.repository.full_name.split('/').second
  end

  def draft_release
    @draft_release ||= DraftRelease.new(user_name: user_name, repo_name: repo_name)
  end
end
