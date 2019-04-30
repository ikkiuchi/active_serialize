# frozen_string_literal: true

require 'active_record'

require 'active_serialize/version'
require 'active_serialize/key_formatter'
require 'active_serialize/class_methods'
require 'active_serialize/relation'

module ActiveSerialize
  extend ActiveSupport::Concern
  cattr_accessor :configs, default: { default: { rmv: [ ], add: [ ], key_format: nil } }

  class_methods do
    def active_serialize rmv: [ ], add: [ ], recursive: [ ], pluck: [ ], **configs
      extend   ClassMethods
      include  ToH
      ::ActiveRecord::Relation.include Relation
      delegate :active_serialize_keys, :_active_serialize, to: self

      _active_serialize.merge!(configs)
      active_serialize_rmv *Array(rmv)
      active_serialize_add *Array(add)
      active_serialize_add *Array(recursive), to: :recursive
      active_serialize_add *Array(pluck), to: :pluck
    end

    def active_serialize_default **args
      ActiveSerialize.configs[:default].merge!(args)
    end
  end

  module ToH
    def to_h(*groups, rmv: [ ], add: [ ], flat_add: [ ], recursive: [ ], plucked: { }, merge: { }, **opts)
      recursion = (_active_serialize[:recursive] + recursive).map { |k| [ k, public_send(k)&.to_ha(*groups) ] }.to_h
      merge.merge!(flat_add.map(&method(:public_send)).reduce({ }, :merge)) if flat_add.present?
      keys = active_serialize_keys(*groups, rmv: rmv, add: add, **opts)
      keys = instance_exec(&keys[:if].first) \
          ? keys[:if].last[:only] || keys[:normal] + (keys[:if].last[:add] || [ ]) - (keys[:if].last[:rmv] || [ ])
          : keys[:normal] \
        if keys.is_a?(Hash)

      KeyFormatter.(_active_serialize[:key_format],
          keys.map { |key| [ key, public_send(key) ] }.to_h
              .merge(plucked).merge(recursion).merge(merge)
              .transform_keys { |key| _active_serialize[:map][key] || key }
              .deep_stringify_keys!
      )
    end

    alias to_ha to_h
  end
end

ActiveRecord::Base.include ActiveSerialize
