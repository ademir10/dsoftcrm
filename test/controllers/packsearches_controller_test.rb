require 'test_helper'

class PacksearchesControllerTest < ActionController::TestCase
  setup do
    @packsearch = packsearches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:packsearches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create packsearch" do
    assert_difference('Packsearch.count') do
      post :create, packsearch: {  }
    end

    assert_redirected_to packsearch_path(assigns(:packsearch))
  end

  test "should show packsearch" do
    get :show, id: @packsearch
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @packsearch
    assert_response :success
  end

  test "should update packsearch" do
    patch :update, id: @packsearch, packsearch: {  }
    assert_redirected_to packsearch_path(assigns(:packsearch))
  end

  test "should destroy packsearch" do
    assert_difference('Packsearch.count', -1) do
      delete :destroy, id: @packsearch
    end

    assert_redirected_to packsearches_path
  end
end
