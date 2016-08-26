require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title signup" do
    assert_equal full_title, "Wishlist"
    assert_equal full_title("Sign up"), "Sign up | Wishlist"
  end
end
