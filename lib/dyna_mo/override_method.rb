module DynaMo
  class OverrideMethod
    def initialize(context, name, class_method = nil, &block)
      @context = context.to_sym
      @name = name.to_sym
      @override = block
    end

    def apply(mod)
      mod.__send__(:define_method, @name, self.to_proc)
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
