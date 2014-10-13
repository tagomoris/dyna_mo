require "dyna_mo/version"

require "dyna_mo/module"

module DynaMo
  # constants or ...
end

require "dyna_mo/contexts"
# DynaMo::Contexts
#   #def_instance_method(method_name, context_name=default_context_name, &block)
#   #def_singleton_method(method_name, context_name=default_context_name, &block)
#   #def_method -> #def_instance_method

require "dyna_mo/environment"
# Kernel.dynamo_define(target_name_or_instance, default_context_name_sym, &block)
# Kernel.dynamo_context(context_name, &block)
# Kernel.dynamo_super(*args)
