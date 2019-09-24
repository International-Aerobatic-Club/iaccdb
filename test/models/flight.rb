require 'test_helper'

class FlightTest < ActiveSupport::TestCase
  setup do
    cat = Category.first
    @flight = create(:flight, category_id: cat.id)
  end

  test "setup" do
    assert(@flight.valid?)
  end

  test "can destroy flight" do
    assert(@flight.destroy)
  end

  test "can destroy flight with multiple categories" do
    cat = Category.last
    @flight.categories << cat
    @flight.save!
    assert(@flight.destroy)
  end

  test "can destroy flight through contest relation" do
    cat = Category.last
    @flight.categories << cat
    @flight.save!
    contest = @flight.contest
    assert(contest.flights.destroy_all)
  end
end
