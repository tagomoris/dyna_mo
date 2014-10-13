module DynaMo
  module Environment
    # dummy.
  end
end

module Kernel
  def dynamo_define(target_name_or_instance, default_context_name, &block)
    raise "block is not given for dynamo_define" unless block_given?
    # target_name_or_instance accepts module instance, to help programmer to avoid typo
    ::DynaMo.synchronize do
      # get/create context object and evaluate block with it
    end
  end

  def dynamo_context(context_name, &block)
    raise "block is not given for dynamo_context" unless block_given?
    # get context, apply context and yield block

    yield
  end

  def dynamo_super(*args)
    Thread.current[:dynamo_stack].last.call(*args)
  end
end
