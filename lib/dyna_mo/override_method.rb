module DynaMo
  class OverrideMethod
    def initialize(context, name, type, &block)
      if type != :instance && type != :singleton
        raise ArgumentError, "method type must be :instance or :singleton"
      end

      @context = context.to_sym
      @name = name
      @type = type
      @override = block

      @module = nil
    end

    def define(mod)
      if type == :instance
        mod.__send__(:define_method, @name, self.to_proc)
      else
        #TODO Mmmmmm........
        mod.instance_eval do
          def #{name}
            Thread.current[:dynamo_contexts] ||= []
            Thread.current[:dynamo_contexts][context] ? instance_exec(*args, &override) : super
          end
        end
      end
    end

    def to_proc
      raise "DynaMo::OverrideMethod#to_proc is not allowed for singleton methods" if @type == :singleton

      context = @context
      override = @override

      -> (*args) {
        Thread.current[:dynamo_contexts] ||= []
        Thread.current[:dynamo_contexts][context] ? instance_exec(*args, &override) : super
      }
    end
  end
end
