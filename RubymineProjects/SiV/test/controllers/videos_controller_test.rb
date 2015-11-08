require "test_helper"

class VideosControllerTest < ActionController::TestCase

  before do
    @video = videos(:one)
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:videos)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference('Video.count') do
      post :create, video: { inLocal: @video.inLocal, name: @video.name, uid: @video.uid, link: @video.link }
    end

    assert_redirected_to video_path(assigns(:video))
  end

  def test_show
    get :show, id: @video
    assert_response :success
  end

  def test_edit
    get :edit, id: @video
    assert_response :success
  end

  def test_update
    put :update, id: @video, video: { inLocal: @video.inLocal, name: @video.name, uid: @video.uid, link: @video.link }
    assert_redirected_to video_path(assigns(:video))
  end

  def test_destroy
    assert_difference('Video.count', -1) do
      delete :destroy, id: @video
    end

    assert_redirected_to videos_path
  end
end
