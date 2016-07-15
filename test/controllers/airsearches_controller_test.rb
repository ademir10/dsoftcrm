require 'test_helper'

class AirsearchesControllerTest < ActionController::TestCase
  setup do
    @airsearch = airsearches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:airsearches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create airsearch" do
    assert_difference('Airsearch.count') do
      post :create, airsearch: { client: @airsearch.client, phone: @airsearch.phone, q1: @airsearch.q1, q2: @airsearch.q2, q3: @airsearch.q3 }
    end

    assert_redirected_to airsearch_path(assigns(:airsearch))
  end

  test "should show airsearch" do
    get :show, id: @airsearch
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @airsearch
    assert_response :success
  end

  test "should update airsearch" do
    patch :update, id: @airsearch, airsearch: { client: @airsearch.client, phone: @airsearch.phone, q1: @airsearch.q1, q2: @airsearch.q2, q3: @airsearch.q3 }
    assert_redirected_to airsearch_path(assigns(:airsearch))
  end

  test "should destroy airsearch" do
    assert_difference('Airsearch.count', -1) do
      delete :destroy, id: @airsearch
    end

    assert_redirected_to airsearches_path
  end
end
