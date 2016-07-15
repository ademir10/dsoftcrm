require 'test_helper'

class RodosearchesControllerTest < ActionController::TestCase
  setup do
    @rodosearch = rodosearches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rodosearches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rodosearch" do
    assert_difference('Rodosearch.count') do
      post :create, rodosearch: {  }
    end

    assert_redirected_to rodosearch_path(assigns(:rodosearch))
  end

  test "should show rodosearch" do
    get :show, id: @rodosearch
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rodosearch
    assert_response :success
  end

  test "should update rodosearch" do
    patch :update, id: @rodosearch, rodosearch: {  }
    assert_redirected_to rodosearch_path(assigns(:rodosearch))
  end

  test "should destroy rodosearch" do
    assert_difference('Rodosearch.count', -1) do
      delete :destroy, id: @rodosearch
    end

    assert_redirected_to rodosearches_path
  end
end
