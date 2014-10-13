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
  def test_applied_module_returns_unique_instance
    m1 = DynaMo::OverrideMethod.new(:test_applied_module, :foo) do
      "foo"
    end
    obj1 = m1.applied_module
    assert { obj1.object_id == m1.applied_module.object_id }
  end

  def test_instance_methods
    t1 = Target1.new
    assert { t1.name == "target1" }

    m1 = DynaMo::OverrideMethod.new(:test_instance_methods, :name) do
      "p#{@n}:" + virtual_dynamo_super()
    end

    Target1.send(:prepend, m1.applied_module)

    assert { t1.name == "target1" }
    virtual_dynamo_context(:test_instance_methods) do
      assert { t1.name == "p1:target1" }
    end
    assert { t1.name == "target1" }

    m2 = DynaMo::OverrideMethod.new(:test_instance_methods, :initialize) do
      @n = 1111
    end
    Target2.prepend(m2.applied_module)
    t2 = Target2.new

    assert { t1.name == "target1" }
    virtual_dynamo_context(:test_instance_methods) do
      assert { t1.name == "p1:target1" }
      assert { t2.name == "p2:target2" }
    end
    assert { t1.name == "target1" }

    virtual_dynamo_context(:test_instance_methods) do
      assert { Target1.new.name == "p1:target1" }
      assert { Target2.new.name == "p1111:target1111" }
    end
  end

  def test_class_methods
    assert { Target1.label == "target1" }

    m1 = DynaMo::OverrideMethod.new(:test_class_methods, :label) do
      "p1:target1"
    end

    mod1 = m1.applied_module
    (class << Target1; self; end).send(:prepend, mod1)

    assert { Target1.label == "target1" }
    virtual_dynamo_context(:test_class_methods) do
      assert { Target1.label == "p1:target1" }
    end
    assert { Target1.label == "target1" }

    # Target2.label is equal to Target1.self
    assert { Target2.label == "target1" }
    virtual_dynamo_context(:test_class_methods) do
      assert { Target2.label == "p1:target1" }
    end
    assert { Target2.label == "target1" }

    m2 = DynaMo::OverrideMethod.new(:test_class_methods, :label) do
      virtual_dynamo_super().gsub(/1/, '2')
    end
    (class << Target2; self; end).send(:prepend, m2.applied_module)

    assert { Target2.label == "target1" }
    virtual_dynamo_context(:test_class_methods) do
      assert { Target2.label == "p2:target2" }
    end
    assert { Target2.label == "target1" }
  end
end
