# frozen_string_literal: true

module ActiveSerialize
  module ClassMethods
    def _active_serialize
      ActiveSerialize.configs[name] ||= { **ActiveSerialize.configs[:default].deep_dup, final: nil, recursive: [ ], map: { } }
    end

    def to_ha(**args)
      all.to_a.map { |record| record.to_h(**args) }
    end

    def active_serialize_rmv *attrs
      _active_serialize[:rmv].concat attrs.map(&:to_sym)
    end

    def active_serialize_add *attrs, named: nil, recursive: false
      active_serialize_map attrs[0] => named if named
      _active_serialize[recursive ? :recursive : :add].concat attrs.map(&:to_sym)
    end

    def active_serialize_map **settings
      _active_serialize[:map].merge! settings
    end

    def active_serialize_keys(rmv: [ ], add: [ ])
      _active_serialize[:final] ||= column_names.map(&:to_sym) - _active_serialize[:rmv] + _active_serialize[:add]
      _active_serialize[:final] - Array(rmv) + Array(add)
    end
  end
end
