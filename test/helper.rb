require 'test/unit'
require 'test/unit/power_assert'

def virtual_dynamo_context(name)
  Thread.current[:dynamo_contexts] ||= {}
  Thread.current[:dynamo_contexts][name] = true
  begin
    yield
  ensure
    Thread.current[:dynamo_contexts].delete(name)
  end
end
