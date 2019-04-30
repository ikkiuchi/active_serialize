# frozen_string_literal: true

module ActiveSerialize
  module ClassMethods
    def _active_serialize
      ActiveSerialize.configs[name] ||= {
          **ActiveSerialize.configs[:default].deep_dup,
          final: nil, groups: { }, recursive: [ ], map: { }, pluck: [ ]
      }
    end

    def to_ha(*args)
      all.to_ha(*args)
    end

    def active_serialize_rmv *attrs
      _active_serialize[:rmv].concat attrs.map(&:to_sym)
    end

    # to: `recursive` or `pluck`
    def active_serialize_add *attrs, named: nil, to: nil, group: nil
      active_serialize_map attrs[0] => named if named
      return _active_serialize[:groups][group] = attrs.map(&:to_sym) if group
      _active_serialize[to || :add].concat attrs.map(&:to_sym)
    end

    def active_serialize_map **settings
      _active_serialize[:map].merge! settings
    end

    def active_serialize_keys(*groups, rmv: [ ], add: [ ], only: nil, **opts)
      return only if only
      _active_serialize[:final] ||= column_names.map(&:to_sym) - _active_serialize[:rmv] + _active_serialize[:add]
      result = _active_serialize[:final] - Array(rmv) + Array(add) +
          _active_serialize[:groups].values_at(*groups).flatten.compact.uniq
      opts[:if] ? { normal: result, if: opts[:if] } : result
    end
  end
end
