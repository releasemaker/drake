# frozen_string_literal: true

json.is_enabled (repo.persisted? && repo.enabled?)
json.repo_type repo.short_type
json.provider_uid repo.provider_uid_or_url
json.name repo.name
json.path repo.friendly_path
