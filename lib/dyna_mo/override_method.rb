module DynaMo
  class OverrideMethod
    attr_reader :context, :name

    def initialize(context, name, &block)
      @context = context.to_sym
      @name = name.to_sym
      @override = block

      @mod = nil
    end

    def applied_module
      return @mod if @mod

      mod = Module.new
      mod.__send__(:define_method, @name, self.to_proc)
      @mod = mod
    end

    def to_proc
      context = @context
      override = @override

      -> (*args) {
        Thread.current[:dynamo_contexts] ||= {}
        if Thread.current[:dynamo_contexts][context]
          instance_exec(*args, &override)
        else
          super(*args)
        end
      }
    end
  end
end
