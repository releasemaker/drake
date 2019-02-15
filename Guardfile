# rubocop:disable Style/RegexpLiteral
require 'active_support/inflector'

notification :terminal_notifier

ignore %r{^(tmp|log|run)/}

guard 'bundler' do
  watch('Gemfile')
  watch('Gemfile.lock')
end

# Runs rubocop only after the specs have passed.
# https://github.com/yujinakayama/guard-rubocop#advanced-tips
group :red_green_refactor, halt_on_fail: true do
  rspec_options = {
    all_on_start: false,
    run_all: false,
    failed_mode: :none,
  }
  rspec_format = "--format documentation"

  if ENV['RSPEC_OPEN_BROWSER']
    rspec_options = rspec_options.merge(
      launchy: './tmp/spec_results.html',
    )
    rspec_format += " --format html --out ./tmp/spec_results.html"
  end

  rspec_options[:cmd] = "bin/rspec #{rspec_format}"

  guard 'rspec', rspec_options do
    watch(%r{spec/(rails|spec)_helper.rb})              { "spec" }
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/admin/(.*)\.rb$})                     { |m| "spec/request/#{m[1]}_spec.rb" }
    watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  end

  rubocop_options = {
    cli: %w(-D --format fuubar),
    all_on_start: false,
    keep_failed: false,
  }

  if ENV['RUBOCOP_OPEN_BROWSER']
    rubocop_options[:launchy] = './tmp/rubocop_results.html'
    rubocop_options[:cli] += %w(--format html -o ./tmp/rubocop_results.html)
  end

  guard :rubocop, rubocop_options do
    watch('Guardfile')
    watch('config.ru')
    watch('Rakefile')
    watch(%r{.+\.rb$})
    watch(%r{.+\.rake$})
    # Rerun rubocop on everything in the folder or below a .rubocop.yml file
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end

guard 'pow', restart_on_start: false, restart_on_reload: false do
  # Restart the application in Pow when these files change.
  watch('.powrc')
  watch('.powenv')
  watch('.ruby-version')
  watch('Gemfile.lock')
  watch(%r{^config})
end
