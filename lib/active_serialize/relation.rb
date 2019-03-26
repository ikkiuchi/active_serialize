# frozen_string_literal: true

module ActiveSerialize
  module Relation
    def to_ha(*groups, pluck: [ ], plucked: nil, **args)
      plucked ||=
          if pluck.is_a?(Proc)
            instance_eval(&pluck)
          else
            (_active_serialize[:pluck] + pluck).uniq.map { |key| [ key, instance_eval(&method(key)) ] }.to_h
          end

      if plucked.present?
        each_with_index.map do |record, i|
          record.to_h(*groups, plucked: plucked.each_key.map { |k| [ k, plucked[k][i] ] }.to_h, **args)
        end
      else
        map { |record| record.to_h(*groups, **args) }
      end
    end

    def with_ha(*args)
      return to_ha(*args), self
    end
  end
end
