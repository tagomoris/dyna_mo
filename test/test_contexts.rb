require 'helper'
require 'dyna_mo/contexts'

module Foo
  class Bar
    def self.label
      "baz"
    end
    def text
      "foobar"
    end
    def concat(a, b, separator=".")
      a + separator + b
    end
  end
end

class ContextsTest < Test::Unit::TestCase
  def test_instance_method_contexts
    cxt = DynaMo::Contexts.new('Foo::Bar', :test_i0)
    cxt.def_instance_method(:text) do # default context name
      "foobar0"
    end
    cxt.def_instance_method(:text, :test_i1) do
      "foobar1"
    end
    cxt.def_instance_method(:text, :test_i2) do |x| # special argument for test
      "foobar2:" + x
    end

    assert { Foo::Bar.new.text == "foobar" }
    virtual_dynamo_context(:test_i0) do
      assert { Foo::Bar.new.text == "foobar0" }
    end
  end
end
