require "dyna_mo/version"

require "dyna_mo/module"

module DynaMo
  # constants or ...
  @@context_store = {}
  @@context_mutex = Mutex.new

  def self.synchronize
    @@context_mutex.synchronize do
      yield
    end
  end
end

require "dyna_mo/context"
# DynaMo::Context
#   #def_instance_method(method_name, context_name=default_context_name, &block)
#   #def_singleton_method(method_name, context_name=default_context_name, &block)
#   #def_method -> #def_instance_method

require "dyna_mo/environment"
# Kernel.dynamo_define(target_name_or_instance, default_context_name_sym, &block)
# Kernel.dynamo_context(context_name, &block)

