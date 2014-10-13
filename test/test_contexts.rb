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

  class Baz < Bar
    def text
      (super) + "baz"
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

    cxt.apply

    assert { Foo::Bar.new.text == "foobar" }
    virtual_dynamo_context(:test_i0) do
      assert { Foo::Bar.new.text == "foobar0" }
    end
    virtual_dynamo_context(:test_i1) do
      assert { Foo::Bar.new.text == "foobar1" }
    end
    virtual_dynamo_context(:test_i2) do
      assert { Foo::Bar.new.text("z") == "foobar2:z" }
    end

    cxt.def_method(:text, :test_i0) do
      "foobar_zero"
    end

    cxt.apply

    assert { Foo::Bar.new.text == "foobar" }
    virtual_dynamo_context(:test_i0) do
      assert { Foo::Bar.new.text == "foobar_zero" }
    end
    virtual_dynamo_context(:test_i1) do
      assert { Foo::Bar.new.text == "foobar1" }
    end
    virtual_dynamo_context(:test_i2) do
      assert { Foo::Bar.new.text("z") == "foobar2:z" }
    end

    # 2 or more dynamo contexts work well: last defined method is prior
    virtual_dynamo_context(:test_i0) do
      virtual_dynamo_context(:test_i1) do
        assert { Foo::Bar.new.text == "foobar_zero" }
      end
    end
  end

  def test_for_subclass
    cxt1 = DynaMo::Contexts.new('Foo::Bar', :test_s0)
    cxt1.def_instance_method(:text, :test_s1) do
      "foobar1"
    end
    cxt1.def_instance_method(:text) do # default context name
      "foobar0"
    end
    # test_s0 is prior for Foo::Bar

    cxt1.apply

    # subclass methods are prior, and prepended methods, original methods
    assert { Foo::Baz.new.text == "foobarbaz" }
    virtual_dynamo_context(:test_s0) do
      assert { Foo::Baz.new.text == "foobar0baz" }
    end
    virtual_dynamo_context(:test_s1) do
      assert { Foo::Baz.new.text == "foobar1baz" }
    end
  end

  def test_multi_context_and_threads
    cxt1 = DynaMo::Contexts.new('Foo::Bar', :test_m0)
    cxt1.def_instance_method(:text, :test_m1) do
      "foobar1"
    end
    cxt1.def_instance_method(:text) do # default context name
      "foobar0"
    end
    # test_m0 is prior for Foo::Bar

    cxt1.apply

    cxt2 = DynaMo::Contexts.new('Foo::Baz', :test_m0)
    cxt2.def_method(:text) do
      virtual_dynamo_super() + " baz0"
    end
    cxt2.def_method(:text, :test_m1) do
      virtual_dynamo_super() + " baz1"
    end
    # test_m1 is prior for Foo:Baz

    cxt2.apply

    virtual_dynamo_context(:test_m0) do
      virtual_dynamo_context(:test_m1) do
        # Baz/test_m1 -> Baz/test_m0 -> Baz/origin -> Bar/test_m0
        assert { Foo::Baz.new.text == "foobar0baz baz0 baz1" }

        # Other thread does NOT accept any effects
        val1 = Thread.new { Foo::Baz.new.text }.value
        assert { val1 == "foobarbaz" }

        # Other thread can apply other context
        # Baz/test_m1 -> Baz/origin -> Bar/test_m1 (without test_m0)
        val2 = Thread.new { virtual_dynamo_context(:test_m1) { Foo::Baz.new.text } }.value
        assert { val2 == "foobar1baz baz1" }
      end
    end
  end
end
