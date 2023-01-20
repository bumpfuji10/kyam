require "test_helper"

class IssuesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get issues_new_url
    assert_response :success
  end

  test "should get edit" do
    get issues_edit_url
    assert_response :success
  end

  test "should get show" do
    get issues_show_url
    assert_response :success
  end

  test "should get index" do
    get issues_index_url
    assert_response :success
  end
end
