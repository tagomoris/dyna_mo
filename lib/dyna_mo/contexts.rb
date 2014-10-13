require "dyna_mo/override_method"

module DynaMo
  class Contexts
    attr_reader :module_name
    attr_accessor :default_context_name

    def initialize(mod_name, default_context_name)
      # mod_name MUST be string here to assure target module_name consistency
      @module_name = mod_name
      @default_context_name = default_context_name.to_sym

      @instance_method_mods = []
      @class_method_mods = []
    end

    def apply
      target = eval(@module_name)

      # reverse: Last defined context's method priority is highest
      target.prepend( *(@instance_method_mods.reverse.map(&:applied_module)) )
      (class << target; self; end).prepend( *(@class_method_mods.reverse.map(&:applied_module)) )

      # prepending twice has no effects
    end

    def def_instance_method(method_name, context_name = @default_context_name, &block)
      raise "block is not given for def_instance_method" unless block_given?

      @instance_method_mods.push OverrideMethod.new(context_name.to_sym, method_name, &block)
      method_name
    end
    alias :def_method :def_instance_method

    def def_class_method(method_name, context_name = @default_context_name, &block)
      raise "block is not given for def_singleton_method" unless block_given?

      @class_method_mods.push OverrideMethod.new(context_name.to_sym, method_name, &block)
      method_name
    end
  end
end
