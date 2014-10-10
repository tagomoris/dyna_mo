module DynaMo
  module Environment
    # dummy.
  end
end

module Kernel
  # define class A -> A.prepend(X) -> overwrite defs of A
  #   => A.ancestors: [X, A, ...] (correct)

  # define A -> A.prepend(X) -> define B < A
  #   => B.ancestors: [B, X, A, ...] (correct)

  def dynamo_define(target_name_or_instance, default_context_name, &block)
    raise "block is not given for dynamo_define" unless block_given?
    ::DynaMo.synchronize do
      # get/create context object and evaluate block with it
    end
  end

  def dynamo_context(context_name, &block)
    raise "block is not given for dynamo_context" unless block_given?
    # get context, apply context and yield block

    yield
  end
end
