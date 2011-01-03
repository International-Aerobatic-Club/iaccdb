require 'test_helper'

class PilotFlightTest < ActiveSupport::TestCase
  test "pilot one flights one and two" do
    one = members(:one)
    af = one.flights
    assert_equal(2, af.length)
    fk = af.detect { |f| f.name == 'Known' }
    assert_equal('Advanced', fk.category)
    ff = af.detect { |f| f.name == 'Free' }
    assert_equal('Advanced', ff.category)
    assert_not_equal(fk, ff, "Two different flights")
  end

  test "flight one pilots one and four" do
    one = flights(:one)
    ap = one.pilots
    assert_not_nil ap
    assert_equal(2, ap.length)
    pa = ap.detect { |p| p.iac_id == 909091 }
    assert_equal('Julia', pa.given_name)
    pb = ap.detect { |p| p.iac_id == 19517 }
    assert_equal('Michael', pb.given_name)
    assert_not_equal(pa, pb, "Two different pilots")
  end
end
