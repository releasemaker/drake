json.id @repo.id
json.enabled @repo.enabled
json.name @repo.name
json.provider_uid @repo.provider_uid_or_url
json.url friendly_repo_url(@repo)
