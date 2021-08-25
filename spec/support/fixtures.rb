# frozen_string_literal: true

##
# Load a JSON blob from a fixture.
# Path is relative to the spec/fixtures folder.
def json_fixture(path)
  File.read(Rails.root.join(*%W[spec fixtures #{path}.json]))
end

##
# Load a JSON blob from a fixture and parse it (presumably into a hash).
# Path is relative to the spec/fixtures folder.
def parsed_json_fixture(path)
  JSON.parse json_fixture(path)
end
