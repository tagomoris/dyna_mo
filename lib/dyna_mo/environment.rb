require "dyna_mo/contexts"

module DynaMo
  module Environment
    @@contexts_store = {}
    @@contexts_mutex = Mutex.new

    def self.synchronize
      @@contexts_mutex.synchronize do
        yield
      end
    end

    def self.contexts(name, default_context_name)
      context = ( @@contexts_store[name] ||= DynaMo::Contexts.new(name, default_context_name) )
      context.default_context_name = default_context_name
      context
    end

    def self.apply_environment
      @@contexts_store.each do |name, contexts|
        contexts.apply
      end
      true
    end
  end
end

module Kernel
  def dynamo_define(target_name_or_instance, default_context_name, &block)
    raise "block is not given for dynamo_define" unless block_given?
    # target_name_or_instance accepts module instance, to help programmer to avoid typo
    target = target_name_or_instance.is_a?(Module) ? target_name_or_instance.name : target_name_or_instance.to_s
    ::DynaMo::Environment.synchronize do
      # get/create context object and evaluate block with it
      context = ::DynaMo::Environment.contexts(target, default_context_name)
      context.instance_exec(&block)
    end
  end

  def dynamo_context(context_name, &block)
    raise "block is not given for dynamo_context" unless block_given?
    # get context, apply context and yield block
    ::DynaMo::Environment.synchronize do
      ::DynaMo::Environment.apply_environment
    end
    Thread.current[:dynamo_contexts] ||= {}
    Thread.current[:dynamo_contexts][context_name] = true
    begin
      yield
    ensure
      Thread.current[:dynamo_contexts].delete(context_name)
    end
  end

  def dynamo_super(*args)
    Thread.current[:dynamo_stack].last.call(*args)
  end

  ## This method is to call `super` just like in original definition,
  ## without calls of any other contexts' definition and original method definition
  # def dynamo_ultra_super(*args)
  #   # But, we need Method#super_method and something to get Method object now running...
  #   raise NotImplementedError, "We need Kernel.current_method"
  # end
end
