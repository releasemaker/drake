# frozen_string_literal: true

json.availableRepos do
  json.array! @available_repos do |repo|
    json.partial! 'repos/repo.jbuilder', repo: repo
  end
end
json.pagination do
  json.limit_value @paginated_content.limit_value
  json.total_pages @paginated_content.total_pages
  json.current_page_num @paginated_content.current_page
end
