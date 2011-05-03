require File.dirname(__FILE__) + '/../spec_helper'

describe User, 'authenticate' do
  fixtures :users
  it 'should return user for valid username and password' do
    # expected = users(:the_bob)
    # User.authenticate("bob", "test").should == expected
  end
end

describe User, 'more authenticate' do
  fixtures :users

  it 'should return nil when username is wrong' do
    User.authenticate("nonbob", "test").should be_nil
  end

  it 'should return nil when password is wrong' do
    User.authenticate("bob", "wrongpass").should be_nil
  end

  it 'should return nil when username and password is wrong' do
    User.authenticate("nonbob", "wrongpass").should be_nil
  end
=begin
  it 'should find user after password has been changed' do
    original_password = "longtest"
    new_password = "nonbobpasswd"
    user = users(:long_bob)

    User.authenticate("longbob", original_password).should == user

    user.password = user.password_confirmation = new_password
    user.save.should be_true

    User.authenticate("longbob", new_password).should == user
    User.authenticate("longbob", original_password).should be_nil

    user.password = user.password_confirmation = original_password
    user.save.should be_true

    User.authenticate("longbob", original_password).should == user
    User.authenticate("longbob", new_password).should be_nil
  end
=end
end

describe User, 'authenticate after new' do
  fixtures :users

  it 'should find newly created user' do
    user = User.new(:login => "newbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com" )
    user.salt.should_not be_nil
    user.password.should_not be_nil
    user.hashed_password.should_not be_nil
    user.save.should be_true
    User.authenticate(user.login, user.password).should == user
    user.destroy
  end

end

describe User, "password" do
  fixtures :users

  def new_user password
    User.new :login => "nonbob",
        :email => "nonbob@mcbob.com",
        :password => password,
        :password_confirmation => password
  end

  def assert_password_invalid password
    user = new_user password
    user.save.should be_false
    user.errors.invalid?('password').should be_true
    user.destroy
  end

  it 'should be invalid if too short (< 5 chars)' do
    assert_password_invalid "tiny"
  end

  it 'should be invalid if too long (> 40 chars)' do
    assert_password_invalid "hugehugehugehugehugehugehugehugehugehugehuge"
  end

  it 'should be invalid if empty' do
    assert_password_invalid ""
  end

  it 'should be valid if right length' do
    user = new_user "bobs_secure_password"
    user.save.should be_true
    user.errors.should be_empty
    user.destroy
  end

end

describe User, "login" do
  fixtures :users

  def new_user login
    User.new :login => login,
        :email => login+"@mcbob.com",
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
  end

  def assert_login_invalid login
    user = new_user login
    user.save.should be_false
    user.errors.invalid?('login').should be_true
    user.destroy
  end

  it 'should be invalid if too short (< 3 chars)' do
    assert_login_invalid 'x'
  end

  it 'should be invalid if too long (> 40 chars)' do
    assert_login_invalid 'hugehugehugehugehugehugehugehugehugehugehuge'
  end

  it 'should be invalid if empty' do
    assert_login_invalid ''
  end

  it 'should be invalid if it contains non ascii letters' do
    assert_login_invalid 'mārama'
  end

  it 'should be invalid if it contains upper case letters' do
    assert_login_invalid 'Maker'
    assert_login_invalid 'mAker'
    assert_login_invalid 'makeR'
  end

  it 'should be invalid if it contains non letter symbols' do
    assert_login_invalid 'red$'
    assert_login_invalid 'red-setter'
    assert_login_invalid 'red@hot'
    assert_login_invalid '(black)'
  end

  it 'should be valid if it contains underscore at start' do
    assert_login_invalid '_bobby'
  end

  it 'should be valid if it contains underscore at end' do
    assert_login_invalid 'bobby_'
  end

  it 'should be valid if it contains underscore at start and end' do
    assert_login_invalid '_bobby_'
  end

  it 'should be valid if it contains two underscores next to each other' do
    assert_login_invalid 'bob__by'
  end

  it 'should be valid if it contains underscore between letters' do
    user = new_user 'big_bobby'
    user.save.should be_true
    user.errors.invalid?('login').should be_false
    user.destroy
  end

  it 'should be valid if correct length' do
    user = new_user 'bigbob'
    user.save.should be_true
    user.errors.invalid?('login').should be_false
    user.destroy
  end

=begin
  it 'should be invalid if login already exists' do
    existing_login = users(:existing_bob).login
    assert_login_invalid existing_login
  end
=end
end

describe User, "email" do
  fixtures :users

  def new_user email
    User.new :login => 'bobby',
        :email => email,
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
  end

  def assert_email_invalid email
    user = new_user email
    user.save.should be_false
    user.errors.invalid?('email').should be_true
    user.destroy
  end

  it 'should be invalid if missing @ symbol' do
    assert_email_invalid 'bobity.com'
  end

  it 'should be invalid if missing root domain' do
    assert_email_invalid 'bob@ity'
  end

  it 'should be invalid if root domain too small' do
    assert_email_invalid 'bob@ity.c'
  end

  it 'should be invalid if missing user name' do
    assert_email_invalid '@ity.com'
  end

  it 'should be invalid if missing user name and domain' do
    assert_email_invalid '@'
  end

  it 'should be invalid if empty' do
    assert_email_invalid ''
  end

  it 'should be valid if correct format' do
    user = new_user 'bob@ity.com'
    user.save.should be_true
    user.errors.invalid?('email').should be_false
    user.destroy
  end

end

describe User, "blog_url" do
  fixtures :users

  def new_user blog_url
    User.new :login => 'blogbob',
        :email => 'blogbob@ity.com',
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password",
        :blog_url => blog_url
  end

  def assert_blog_url_invalid blog_url
    user = new_user blog_url
    user.save.should be_false
    user.errors.invalid?('blog_url').should be_true
    user.destroy
  end

  it 'should be invalid if missing root domain' do
    assert_blog_url_invalid 'blogitycom'
  end

  it 'should be invalid if root domain too small' do
    assert_blog_url_invalid 'blog.ity.c'
  end

  it 'should be invalid if missing root domain after dot' do
    assert_blog_url_invalid 'blog.'
  end

  it 'should be valid if not set' do
    user = User.new :login => 'blogbob',
        :email => 'blogbob@ity.com',
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
    user.save.should be_true
    user.errors.invalid?('blog_url').should be_false
    user.destroy
  end

  it 'should be valid if empty' do
    user = User.new :login => 'blogbob',
        :email => 'blogbob@ity.com',
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password",
        :blog_url => ""
    user.save.should be_true
    user.errors.invalid?('blog_url').should be_false
    user.destroy
  end

  it 'should be valid if correct format' do
    user = new_user 'blog.ity.com'
    user.save.should be_true
    user.errors.invalid?('blog_url').should be_false
    user.destroy
  end

  it 'should be invalid if not unique' do
    user = new_user 'blog.ity.com'
    user.save.should be_true
    user.errors.invalid?('blog_url').should be_false

    user = User.new :login => 'a'+user.login,
        :email => 'a'+user.email,
        :password => 'magic1',
        :password_confirmation => 'magic1',
        :blog_url => user.blog_url
    user.save.should be_false
    user.errors.invalid?('blog_url').should be_true
    user.destroy
  end
end

describe User, 'after sending new password' do
  fixtures :users
=begin
  it 'should not allow authentication against old password' do
    user = User.authenticate('bob', 'test')
    user.should == users(:the_bob)
    User.should_receive(:deliver_forgot_password).with(user.email, user.login, an_instance_of(String))
    user.send_new_password
    User.authenticate('bob', 'test').should be_nil
    user.destroy
  end
=end
end

describe User, 'on creation' do

  it 'should encrypt password' do
    user = User.new :login => "nonexistingbob",
        :email => "nonexistingbob@mcbob.com"

    user.salt = "1000"
    user.password = user.password_confirmation = "bobs_secure_password"
    user.save.should be_true
    user.hashed_password.should == 'b1d27036d59f9499d403f90e0bcf43281adaa844'
    User.encrypt("bobs_secure_password", "1000").should == 'b1d27036d59f9499d403f90e0bcf43281adaa844'
    user.destroy
  end

  it 'should not allow access to id or salt' do
    user = User.new :login => "badbob",
        :email => "badbob@mcbob.com",
        :salt => "I-want-to-set-my-salt",
        :id => 999999,
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
    user.save.should be_true
    user.salt.should_not == "I-want-to-set-my-salt"
    user.id.should_not == 999999
    user.destroy
  end

  it 'should set created_at' do
    user = User.new :login => "nonexistingbob",
        :email => "nonexistingbob@mcbob.com"
    user.password = user.password_confirmation = "bobs_secure_password"
    user.save.should be_true
    user.created_at.should_not be_nil
    user.destroy
  end

  it 'should set updated_at' do
    user = User.new :login => "nonexistingbob",
        :email => "nonexistingbob@mcbob.com"
    user.password = user.password_confirmation = "bobs_secure_password"
    user.save.should be_true
    user.updated_at.should_not be_nil
    user.destroy
  end

end

describe User, 'on update_attributes' do

  it 'should not allow access to id or salt' do
    user = User.new :login => "badbob",
        :email => "nonexistingbob@mcbob.com",
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
    user.save.should be_true

    user.update_attributes(:id=>999999, :salt=>"I-want-to-set-my-salt", :login => "verybadbob")

    user.salt.should_not == "I-want-to-set-my-salt"
    user.id.should_not == 999999
    user.destroy
  end

end
