require 'helper'
require 'dyna_mo'

module MyModule
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

dynamo_define('MyModule::MyClass', default_context = :mytest_case_default) do
  def_method(:initialize) do
    @num = 1
  end

  def_method(:name) do
    "dummyname"
  end

  def_instance_method(:name, :mytest_case1) do
    "dummyname1"
  end

  def_method(:sum) do |numbers|
    @num + numbers.reduce(:+)
  end

  def_singleton_method(:create) do |init_num=0|
    obj = self.new
    obj.num = init_num
    obj
  end
end

class SynopsisTest < Test::Unit::TestCase
  def test_synopsis
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
