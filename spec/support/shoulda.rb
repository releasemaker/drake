# frozen_string_literal: true

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include Shoulda::Matchers::ActionController, type: :request
end

module Shoulda
  module Matchers
    RailsShim.class_eval do
      def self.serialized_attributes_for(model)
        if defined?(::ActiveRecord::Type::Serialized)
          # Rails 5+
          model.columns.select do |column|
            model.type_for_attribute(column.name).is_a?(::ActiveRecord::Type::Serialized)
          end.each_with_object({}) do |column, hash|
            hash[column.name.to_s] = model.type_for_attribute(column.name).coder
          end
        else
          model.serialized_attributes
        end
      end
    end
  end
end
