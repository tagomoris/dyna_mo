module DynaMo
  class Context
    def initialize(mod_name, default_context_name)
      # mod_name accepts module instance, to help programmer to avoid typo
      @module_name = mod_name.is_a?(String) ? mod_name : mod_name.name
      @default_context_name = default_context_name

      # TODO: context storage
      @instance_methods = {}
      @instance_methods[@default_context_name] = []
    end

    def prepend_module
      # TODO: writing
      return @mod if @mod

      name = @name
      context = @context
      override = @override

      mod = Module.new
      # TODO: apply OverrideMethods
      @mod = mod
    end

    def apply
      eval(@module_name).__send__(:prepend, self.module)
    end

    def def_instance_method(method_name, context_name = @default_context_name, &block)
      raise "block is not given for def_instance_method" unless block_given?
      # TODO: store context-block pair to context storage
    end
    alias :def_method :def_instance_method

    def def_singleton_method(method_name, context_name = @default_context_name, &block)
      raise "block is not given for def_singleton_method" unless block_given?
      # TODO: store context-block pair to context storage
    end
  end
end
