require 'helper'
require 'dyna_mo/module'

class ModulePrependTest < Test::Unit::TestCase
  module P1
    def name
      val = super
      "p1:" + val
    end
  end

  module P2
    def name
      val = super
      "p2:" + val
    end
  end

  class X
    def name
      "x"
    end
  end

  class Y < X
    def name
      "y"
    end
  end

  def test_base
    assert { X.new.name == "x" }
    assert { Y.new.name == "y" }
  end

  def test_normal_prepend
    X.send(:prepend, P1)

    assert { X.new.name == "p1:x" }
    assert X.include?(P1)
    assert X.prepend?(P1)

    assert { Y.new.name == "y" } # not prepend
    assert Y.include?(P1)
    assert (not Y.prepend?(P1))

    Y.send(:prepend, P2)

    assert { Y.new.name == "p2:y" }
    assert Y.include?(P2)
    assert Y.prepend?(P2)
  end

  def test_prepend_duplicated_module
    assert X.prepend?(P1)
    assert (not Y.prepend?(P1))
    assert Y.prepend?(P2)

    assert { Y.new.name == "p2:y" }
    dup_mod = P1.dup

    Y.send(:prepend, dup_mod)

    assert Y.prepend?(dup_mod)
    assert { Y.new.name == "p1:p2:y" }
  end
end


