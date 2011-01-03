require 'test_helper'

class PilotFlightsControllerTest < ActionController::TestCase
  setup do
    @pilot_flight = pilot_flights(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pilot_flights)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pilot_flight" do
    assert_difference('PilotFlight.count') do
      post :create, :pilot_flight => @pilot_flight.attributes
    end

    assert_redirected_to pilot_flight_path(assigns(:pilot_flight))
  end

  test "should show pilot_flight" do
    get :show, :id => @pilot_flight.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @pilot_flight.to_param
    assert_response :success
  end

  test "should update pilot_flight" do
    put :update, :id => @pilot_flight.to_param, :pilot_flight => @pilot_flight.attributes
    assert_redirected_to pilot_flight_path(assigns(:pilot_flight))
  end

  test "should destroy pilot_flight" do
    assert_difference('PilotFlight.count', -1) do
      delete :destroy, :id => @pilot_flight.to_param
    end

    assert_redirected_to pilot_flights_path
  end
end
