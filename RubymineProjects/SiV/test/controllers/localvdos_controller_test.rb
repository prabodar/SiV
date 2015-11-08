require "test_helper"

class LocalvdosControllerTest < ActionController::TestCase

  before do
    @localvdo = localvdos(:one)
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:localvdos)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference('Localvdo.count') do
      post :create, localvdo: {  }
    end

    assert_redirected_to localvdo_path(assigns(:localvdo))
  end

  def test_show
    get :show, id: @localvdo
    assert_response :success
  end

  def test_edit
    get :edit, id: @localvdo
    assert_response :success
  end

  def test_update
    put :update, id: @localvdo, localvdo: {  }
    assert_redirected_to localvdo_path(assigns(:localvdo))
  end

  def test_destroy
    assert_difference('Localvdo.count', -1) do
      delete :destroy, id: @localvdo
    end

    assert_redirected_to localvdos_path
  end
end
