require 'builder_support/version'

module BuilderSupport
  def self.included(base)
    base.class_eval do
      def self.builder_support rmv: [ ], add: [ ]
        extend ClassMethods
        delegate :show_attrs, :flatten_attrs, to: self
        include InstanceMethods

        builder_rmv *rmv
        # %i[ a, b, c d ]
        # %i[ flatten: a b, other_declare: c d ]
        # 'a b and c'
        # 'flatten: a and b, other_declare: c and d'
        add = add.split(/ and | /) if add.is_a? String
        add.map { |item| item[','] ? [item.to_s.delete(','), ','] : item }
            .flatten.map(&:to_sym).split(:',').each do |attrs|
          builder_add *attrs
        end
      end
    end
  end

  module InstanceMethods
    def to_builder(rmv: [ ], add: [ ], merge: { }, flt_add: [ ], flt_rmv: [ ])
      res = Jbuilder.new do |json|
        dynamic_attrs = self.class.instance_variable_get(:@builder_add_dynamically)
        dynamic_attrs&.each { |attr, proc| add << attr if instance_exec(&proc) }
        json.(self, *self.show_attrs(rmv: rmv, add: add))

        self.flatten_attrs(rmv: flt_rmv, add: flt_add).each do |flatten_attr|
          json.merge! flatten_attr => self.send(flatten_attr)
        end
        instance_exec(json, &json_addition)
        json.merge! merge
      end.attributes!

      mapping = self.class.instance_variable_get(:@builder_map) || { }
      res.transform_keys! { |key| (mapping[key.to_sym] || key).to_s }
    end

    def json_addition
      proc { }
    end
  end

  module ClassMethods
    # FIXME: 很奇怪的 scope 影响，尽量用转成 arr 的 to_bd 而不是直接调
    def to_builder(rmv: [ ], add: [ ], merge: { })
      all.to_a.to_builder(rmv: rmv, add: add, merge: merge)
    end

    def builder_rmv *attrs
      (@builder_rmv ||= [ ]).concat attrs
    end

    def builder_add *attrs, when: nil, name: nil, &block
      define_method(attrs.first) { instance_eval(&block) } if block_given?
      builder_map attrs[0] => name if name

      if (w = binding.local_variable_get(:when))
        builder_add_with_when attrs[0], when: w
      elsif attrs.delete(:flatten)
        (@flatten_attrs ||= [ ]).concat attrs
      else
        (@builder_add ||= [ ]).concat attrs
        generate_assoc_info_method attrs
      end
    end

    def builder_map settings = { }
      (@builder_map ||= { }).merge! settings
    end

    def show_attrs(rmv: [ ], add: [ ])
      self.column_names.map(&:to_sym) \
          - (@builder_rmv || [ ]) - rmv \
          + (@builder_add || [ ]) + add
    end

    def flatten_attrs(rmv: [ ], add: [ ])
      (@flatten_attrs ||= [ ]) - rmv + add
    end

    def builder_add_with_when(attr, when:)
      w = binding.local_variable_get(:when)
      # 生成 when 设置的同名函数
      # 用以设置状态
      if w.is_a? Symbol
        define_singleton_method w do
          all.to_a.to_builder(add: [attr])
        end
      else # is proc
        (@builder_add_dynamically ||= { })[attr] = w
      end

      generate_assoc_info_method attr
    end

    def generate_assoc_info_method(attrs)
      # 匹配关联模型 `name_info` 形式的 attr，并自动生成该方法
      # 方法调用模型的 to_builder 方法并取得最终渲染结果
      # unscoped 主要是为了支持去除软删除的默认 scope
      Array(attrs).each do |attr|
        next unless attr.to_s.match?(/_info/)
        assoc_method = attr.to_s.gsub('_info', '')
        next unless new.respond_to?(assoc_method) rescue next

        define_method attr do
          send(assoc_method)&.to_builder || nil
        end

        assoc_model = assoc_method.to_s.singularize
        builder_rmv "#{assoc_model}_id".to_sym
      end
    end
  end
end
