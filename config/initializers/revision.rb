##
# Gets the current version of the application.
class RevisionFinder
  class << self
    def revision
      detect_release_from_capistrano
    end

    private

    def test_revision
      "test" if Rails.env.test?
    end

    def detect_release_from_capistrano
      File.read(Rails.root.join('REVISION')).strip
    rescue
      nil
    end
  end
end

APPLICATION_REVISION = RevisionFinder.revision
