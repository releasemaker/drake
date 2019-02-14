%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
  Gemfile.lock
].each { |path| Spring.watch(path) }
