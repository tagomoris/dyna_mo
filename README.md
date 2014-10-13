# DynaMo: Testing module to provide dynamic scope method overriding

Dynamic scope implementation for Method Overriding: override methods by specified context, only in current thread.

**DON'T USE THIS GEM IN PRODUCTION CODE.**

## What's this?

To modify methods' behavior with its dynamic contexts, like this:

```ruby
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
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dyna_mo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dyna_mo

## Usage

Require this module in `helper.rb` or anywhere you want in test code.

```ruby
require "dyna_mo"
```

### Kernel.dynamo_define(name_or_module_instance, default_context_name, &block)

Create context to define instance methods and class methods of specified Module/Class.

* `name_or_module_instance` accepts both of String or Module/Class instance. But string specification must be name from top-level, like `Net::HTTP` (or `::Net::HTTP`).

Given block is evaluated with a receiver instance of `DynaMo::Contexts`.

```ruby
dynamo_define(MyClass, :test_awesome_situation) do
  # ...
end
```

### DynaMo::Contexts#def_instance_method(method_name, context_name = default_context_name, &block)

Define instance method to override existing instance method, only in specified context. Instance variable reference like `@data` is handled correctly for each objects.

`super` cannot be used in this block. Use `dynamo_super()` instead.

Given block is to be method body, and prepended on specified Module/Class, not rewrite method itself. So we can call original method definition by `dynamo_super()`.

```ruby
 # in dynamo_define
dynamo_instance_method(:data, :my_test_context) do |num|
  @data * num
end
obj.instance_eval{ @data = "abc" }
obj.data(3) #=> "abcabcabc"
```

The most recently called `#def_instance_method` have highest priority. It's for ad-hoc definition in test code.

With `def_instance_method`, given block can have arguments of arbitrary number, not same with original definition. But it brings very confusing behavior (especially for `dynamo_super`), so it is not recommended for many cases.

This method also can add method which does NOT exists in original Module/Class definition.

### DynaMo::Contexts#def_method(...)

Alias of `def_instance_method`.

### DynaMo::Contexts#def_class_method(method_name, context_name = default_context_name, &block)

Define class method. All other things are same with `define_instance_method`.

### Kernel.dynamo_context(context_name, &block)

Create dynamic scope in current thread for specified context name. Given block and lower stack calls run with overridden methods.

```ruby
require "dyna_mo"
 
class A1; def self.label; "A"; end; end
class A2 < A1; def self.label; (super) * 2; end; end
 
dynamo_define(A1, :test) do
  def_class_method(:label) do
    "AB"
  end
end
 
dynamo_context(:test) do
  A2.label #=> "ABAB"
  Thread.new { A2.label }.value #=> "AA"
end
```

We can apply 2 or more contexts at the same time. If these contexts have definition for same method, the recent defined one is called at first.

```ruby
dynamo_define(A1, :test1) do
  def_class_method(:label) do
    "AB"
  end
  def_class_method(:label, :test2) do
    "AC"
  end
  def_class_method(:label, :test3) do
    "BC"
  end
end
 
dynamo_context(:test2) do
  dynamo_context(:test3) do
    dynamo_context(:test1) do
      A2.label #=> "BC"
    end
  end
end
```

### Kernel.dynamo_super(*args)

Use to call original method definition in overriding method body (block). `dyna_mo` method overriding is implemented with `Module.prepend`, so `dynamo_super()` calls original definition, not parent class's definition.

With `dynamo_super`, all arguments must be specified explicitly.

```ruby
dynamo_define(A1, :test_default) do
  def_method(:name) do |prefix|
    prefix + dynamo_super()
  end
end
```

If you use this method with applying multi contexts, `dynamo_super()` calls each overriding method bodies, like this:

```ruby
dynamo_define(A1, :test1) do
  def_class_method(:label) do
    "1" + dynamo_super()
  end
  def_class_method(:label, :test2) do
    "2" + dynamo_super()
  end
  def_class_method(:label, :test3) do
    "3" + dynamo_super()
  end
end

dynamo_context(:test1) do
  dynamo_context(:test2) do
    dynamo_context(:test3) do
      # A1.label/test3 -> A1.label/test2 -> A1.label/test1 -> A1.label/(original)
      A1.label  #=> "321A"
    end
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dyna_mo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

* License
 * MIT
* Author
 * @tagomoris

