require "helper"
require "dyna_mo/override_method"

class Target1
  def self.label
    "target1"
  end

  def initialize
    @n = 1
  end

  def name
    "target#{@n}"
  end
end

class Target2 < Target1
  def self.label
    super
  end

  def initialize
    @n = 2
  end
end

class OverrideMethodTest < Test::Unit::TestCase
  def test_instance_methods
    t1 = Target1.new
    assert { t1.name == "target1" }

    m1 = DynaMo::OverrideMethod.new(:test_instance_methods, :name) do
      "p#{@n}:target#{@n}"
    end

    mod1 = Module.new
    m1.apply(mod1)
    Target1.send(:prepend, mod1)

    assert { t1.name == "target1" }
    Thread.current[:dynamo_contexts] = { test_instance_methods: true }
    begin
      assert { t1.name == "p1:target1" }
    ensure
      Thread.current[:dynamo_contexts] = {}
    end
    assert { t1.name == "target1" }

    m2 = DynaMo::OverrideMethod.new(:test_instance_methods, :initialize) do
      @n = 1111
    end
    m2.apply(mod1)

    assert { t1.name == "target1" }
    Thread.current[:dynamo_contexts] = { test_instance_methods: true }
    begin
      assert { t1.name == "p1:target1" }
      assert { Target2.new.name == "p2:target2" }
    ensure
      Thread.current[:dynamo_contexts] = {}
    end
    assert { t1.name == "target1" }

    Thread.current[:dynamo_contexts] = { test_instance_methods: true }
    begin
      assert { Target1.new.name == "p1111:target1111" }
      assert { Target2.new.name == "p2:target2" }
    ensure
      Thread.current[:dynamo_contexts] = {}
    end
  end

  def test_singleton_methods
    assert { Target1.label == "target1" }

    m1 = DynaMo::OverrideMethod.new(:test_singleton_methods, :label) do
      "p1:target1"
    end

    mod1 = Module.new
    m1.apply(mod1)
    (class << Target1; self; end).send(:prepend, mod1)

    assert { Target1.label == "target1" }
    Thread.current[:dynamo_contexts] = { test_singleton_methods: true }
    begin
      assert { Target1.label == "p1:target1" }
    ensure
      Thread.current[:dynamo_contexts] = {}
    end
    assert { Target1.label == "target1" }

    # Target2.label is equal to Target1.self
    assert { Target2.label == "target1" }
    Thread.current[:dynamo_contexts] = { test_singleton_methods: true }
    begin
      assert { Target2.label == "p1:target1" }
    ensure
      Thread.current[:dynamo_contexts] = {}
    end
    assert { Target2.label == "target1" }
  end
end
