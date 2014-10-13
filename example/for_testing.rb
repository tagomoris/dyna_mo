require 'dyna_mo'

module MyModule # External module definition (other's gem)
  class MyClass
    attr_accessor :num

    def initialize
      @num = 0
    end

    def name
      "name"
    end

    def sum(numbers)
      @num + numbers.reduce(:+)
    end
  end
end

## DynaMo methods can't call `super` correctly

# in test helper
dynamo_define('MyModule::MyClass', default_context = :mytest_case_default) do
  def_method(:initialize) do # == def_instance_method
    @num = 1
  end

  def_method(:name) do # arity == 0, default context
    "dummyname"
  end

  def_instance_method(:name, :mytest_case1) do
    "dummyname1"
  end

  def_method(:sum) do |numbers|
    @num + numbers.reduce(:+)
  end

  # define method only in :mytest_case_default context
  def_singleton_method(:create) do |init_num=0|
    obj = self.new
    obj.num = init_num
    obj
  end
end

# test code
class MyTestCase < Test::Unit::TestCase
  def test_name
    assert_equal "name", MyModule::MyClass.new.name

    obj = MyModule::MyClass.new

    assert_equal 0, obj.num
    assert_equal "name", obj.name

    dynamo_context(:mytest_case_default) do
      assert_equal 0, obj.num # not overridden

      assert_equal "dummyname", obj.name
      assert_equal "dummyname", MyModule::MyClass.new.name

      assert_equal 1, MyModule::MyClass.new.num

      assert_equal 100, MyModule::MyClass.create(100).num
    end

    dynamo_context(:mytest_case1) do
      assert_equal "dummyname1", obj.name
    end

    dynamo_define(MyModule::MyClass, :onetime_context) do
      def_method(:name) do
        "onetime"
      end
    end

    dynamo_context(:onetime_context) do
      assert_equal "onetime", obj.name
    end
  end
end
