##
# Load a JSON blob from a fixture.
# Path is relative to the spec/fixtures folder.
def json_fixture(path)
  Hashie::Mash.new JSON.parse File.read(Rails.root.join(*%W[spec fixtures #{path}.json]))
end
