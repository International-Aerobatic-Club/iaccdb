require "test_helper"

class FreeProgramKsControllerTest < ActionDispatch::IntegrationTest
  def free_program_k
    @free_program_k ||= free_program_ks :one
  end

  def test_index
    get free_program_ks_url
    assert_response :success
  end

  def test_new
    get new_free_program_k_url
    assert_response :success
  end

  def test_create
    assert_difference "FreeProgramK.count" do
      post free_program_ks_url, params: { free_program_k: { category_id: free_program_k.category_id, max_k: free_program_k.max_k, year: free_program_k.year } }
    end

    assert_redirected_to free_program_k_path(FreeProgramK.last)
  end

  def test_show
    get free_program_k_url(free_program_k)
    assert_response :success
  end

  def test_edit
    get edit_free_program_k_url(free_program_k)
    assert_response :success
  end

  def test_update
    patch free_program_k_url(free_program_k), params: { free_program_k: { category_id: free_program_k.category_id, max_k: free_program_k.max_k, year: free_program_k.year } }
    assert_redirected_to free_program_k_path(free_program_k)
  end

  def test_destroy
    assert_difference "FreeProgramK.count", -1  do
      delete free_program_k_url(free_program_k)
    end

    assert_redirected_to free_program_ks_path
  end
end
