require 'helper'
require 'dyna_mo'

module MyModule
  class MyClass
    attr_accessor :num
    def initialize; @num = 0; end
    def name; "name"; end
    def sum(numbers); @num + numbers.reduce(:+); end
  end
end

dynamo_define('MyModule::MyClass', :mytest_case_default) do
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
    @num + numbers.reduce(:+) + 1
  end

  def_class_method(:create) do |init_num=0|
    obj = self.new
    obj.num = init_num
    obj
  end
end

class SynopsisTest < Test::Unit::TestCase
  def test_synopsis
    assert { MyModule::MyClass.new.name == "name" }

    obj = MyModule::MyClass.new

    assert { obj.num == 0 }
    assert { obj.name == "name" }

    dynamo_context(:mytest_case_default) do
      assert { obj.num == 0 } # #initialize is not overridden

      assert { obj.name == "dummyname" }
      assert { MyModule::MyClass.new.name == "dummyname" }

      assert { MyModule::MyClass.new.num == 1 }

      assert { MyModule::MyClass.new.sum([1,2,3]) == (1+(1+2+3)+1) }

      assert { MyModule::MyClass.create(100).num == 100 }
    end

    dynamo_context(:mytest_case1) do
      assert { obj.name == "dummyname1" }
    end

    dynamo_define(MyModule::MyClass, :onetime_context) do
      def_method(:name) do
        "onetime"
      end
    end

    dynamo_context(:onetime_context) do
      assert { obj.name == "onetime" }
    end
  end
end

module MyModule; class MyClass2 < MyClass; end; end

class Synopsis2Test < Test::Unit::TestCase
  def test_onece_more
    dynamo_define(MyModule::MyClass, :onetime_context) do
      def_method(:name) do
        "onetime"
      end
    end

    dynamo_context(:onetime_context) do
      assert { MyModule::MyClass2.new.name == "onetime" }
    end
  end
end
