##
# Gets the current version of the application.
class RevisionFinder
  class << self
    def revision
      release_from_capistrano || revision_from_capistrano || test_revision || "development"
    end

    private

    def test_revision
      "test" if Rails.env.test?
    end

    def revision_from_capistrano
      File.read(Rails.root.join('REVISION')).strip
    rescue
      nil
    end

    def release_from_capistrano
      File.read(Rails.root.join('RELEASE')).strip
    rescue
      nil
    end
  end
end

APPLICATION_REVISION = RevisionFinder.revision
