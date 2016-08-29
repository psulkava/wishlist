require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "fooBar123", password_confirmation: "fooBar123")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 41
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                          first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                            foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email address should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "abA12"
    assert_not @user.valid?
  end

  test "password validation should accept secure passwords" do
    secure_passwords = %w[abcABC123 ABC!@#123 a1b2c3!@# ABCabc!@# abcABC123!@#]
    secure_passwords.each do |secure_password|
      @user.password = @user.password_confirmation = secure_password
      assert @user.valid?, "#{secure_password.inspect} should be secure"
    end
  end
  
  test "password validation should reject insecure passwords" do
    insecure_passwords = %w[sadklsfjla AKLFJKLJSDLK 12399040931 #*($@#(*&$@(
                          sdlkfSDJFKLS adsfas343029 DLKF1904 #()@$JFSDLJ
                          29304)#($*)( asdjflk#*$#)]
    insecure_passwords.each do |insecure_password|
      @user.password = @user.password_confirmation = insecure_password
      assert_not @user.valid?, "#{insecure_password.inspect} should be insecure"
    end
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end
end
