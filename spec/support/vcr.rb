VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { record: :none }
  c.configure_rspec_metadata!

  c.filter_sensitive_data('<GITHUB_AUTH_TOKEN>') { Rails.configuration.x.github.test_auth_token }
end
