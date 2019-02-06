# frozen_string_literal: true

require 'active_record'

require 'active_serialize/version'
require 'active_serialize/key_formatter'
require 'active_serialize/class_methods'

module ActiveSerialize
  extend ActiveSupport::Concern
  cattr_accessor :configs, default: { default: { rmv: [ ], add: [ ], key_format: nil } }

  class_methods do
    def active_serialize rmv: [ ], add: [ ], recursive: [ ], **configs
      extend   ClassMethods
      include  ToH
      delegate :active_serialize_keys, :_active_serialize, to: self

      _active_serialize.merge!(configs)
      active_serialize_rmv *Array(rmv)
      active_serialize_add *Array(add)
      active_serialize_add *Array(recursive), recursive: true
    end

    def active_serialize_default **args
      ActiveSerialize.configs[:default].merge!(args)
    end
  end

  module ToH
    def to_h(rmv: [ ], add: [ ], merge: { })
      tran_key = ->(key) { _active_serialize[:map][key] || key }
      recursion = _active_serialize[:recursive].map { |key| [ tran_key.(key), public_send(key)&.to_ha ] }.to_h
      KeyFormatter.(_active_serialize[:key_format],
          active_serialize_keys(rmv: rmv, add: add)
              .map { |key| [ tran_key.(key), public_send(key) ] }.to_h
              .merge(merge).merge(recursion).deep_stringify_keys!
      )
    end

    alias to_ha to_h
  end
end

ActiveRecord::Base.include ActiveSerialize
