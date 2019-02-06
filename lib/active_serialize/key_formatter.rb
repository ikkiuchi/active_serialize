# frozen_string_literal: true

module ActiveSerialize
  module KeyFormatter
    def self.call(config, hash)
      return hash unless config.present?
      hash.deep_transform_keys! do |k, _|
        case config.to_sym
        when :underscore; k.underscore
        when :camelize; k.camelize
        when :camelize_lower; k.camelize(:lower)
        else k
        end
      end
    end
  end
end
