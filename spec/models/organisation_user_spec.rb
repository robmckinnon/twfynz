require File.dirname(__FILE__) + '/../spec_helper'

describe OrganisationUser, 'authenticate' do
  fixtures :users
  after(:all) {|| User.delete_all }

  it 'should return user for valid username and password' do
    # User.authenticate("internetnz_net_nz", "test").should == users(:internet_nz)
  end
end

describe OrganisationUser, "login" do
  after(:all) {|| User.delete_all }

  it 'should be created based on site_url' do
    organisation_user = OrganisationUser.new :email => 'bob@nzoss.org.nz',
        :site_url => 'nzoss.org.nz',
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
    organisation_user.save.should be_true
    organisation_user.login.should == 'nzoss_org_nz'
  end
end

describe OrganisationUser, 'on creation' do
  after {|| User.delete_all }

  def new_organisation_user
    OrganisationUser.new :email => 'bob@nzoss.org.nz',
        :site_url => 'nzoss.org.nz',
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
  end

  it 'should default email_confirmed to false' do
    organisation_user = new_organisation_user
    organisation_user.save.should be_true
    organisation_user.email_confirmed.should_not be_nil
    organisation_user.email_confirmed.should be_false
  end

  it 'should not allow access to email_confirmed' do
    organisation_user = OrganisationUser.new :email => 'bob@nzoss.org.nz',
        :site_url => 'nzoss.org.nz',
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password",
        :email_confirmed => true
    organisation_user.save.should be_true
    organisation_user.email_confirmed.should_not be_nil
    organisation_user.email_confirmed.should be_false
  end
end

describe OrganisationUser, 'on update_attributes' do
  after {|| User.delete_all }

  it 'should not allow access to email_confirmed' do
    organisation_user = OrganisationUser.new :email => 'bob@nzoss.org.nz',
        :site_url => 'nzoss.org.nz',
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
    organisation_user.save.should be_true

    organisation_user.update_attributes(:email_confirmed => true)
    organisation_user.email_confirmed.should_not be_true
  end

  it 'should not allow access to login' do
    organisation_user = OrganisationUser.new :email => 'bob@nzoss.org.nz',
        :site_url => 'nzoss.org.nz',
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
    organisation_user.save.should be_true

    organisation_user.update_attributes(:login => "verybadbob")
    organisation_user.login.should_not == "verybadbob"
  end
end

describe OrganisationUser, "email" do
  after(:all) {|| User.delete_all }

  it 'should be invalid if domain different from site_url' do
    organisation_user = OrganisationUser.new :email => 'bob@nzoss.co.nz',
        :site_url => 'nzoss.org.nz',
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password"
    organisation_user.save.should be_false
    organisation_user.errors.invalid?('email').should be_true
  end
end

describe OrganisationUser, "site_url" do
  fixtures :users
  after do
    OrganisationUser.delete_all
  end

  def new_organisation_user site_url, domain=nil
    domain = site_url unless domain
    OrganisationUser.new :email => 'blogbob@'+domain,
        :password => "bobs_secure_password",
        :password_confirmation => "bobs_secure_password",
        :site_url => site_url
  end

  def assert_site_url_invalid site_url
    organisation_user = new_organisation_user site_url
    organisation_user.save.should be_false
    organisation_user.errors.invalid?('site_url').should be_true
  end

  it 'should have protocol removed before being stored' do
    organisation_user = new_organisation_user 'http://nzoss.org.nz', 'nzoss.org.nz'
    organisation_user.save.should be_true
    organisation_user.site_url.should == 'nzoss.org.nz'
  end

  it 'should have trailing slash removed before being stored' do
    organisation_user = new_organisation_user 'nzoss.org.nz/', 'nzoss.org.nz'
    organisation_user.save.should be_true
    organisation_user.site_url.should == 'nzoss.org.nz'
  end

  it 'should be invalid if missing root domain' do
    assert_site_url_invalid 'blogitycom'
  end

  it 'should be invalid if root domain too small' do
    assert_site_url_invalid 'blog.ity.c'
  end

  it 'should be invalid if missing root domain after dot' do
    assert_site_url_invalid 'blog.'
  end

  it 'should be valid if empty' do
    organisation_user = new_organisation_user 'blog.ity.com'
    organisation_user.save.should be_true
    organisation_user.errors.invalid?('site_url').should be_false
  end

  it 'should be valid if correct format' do
    organisation_user = new_organisation_user 'blog.ity.com'
    organisation_user.save.should be_true
    organisation_user.errors.invalid?('site_url').should be_false
  end

  it 'should be invalid if not unique' do
    organisation_user = new_organisation_user 'blog.ity.com'
    organisation_user.save.should be_true
    organisation_user.errors.invalid?('site_url').should be_false

    organisation_user = OrganisationUser.new :login => 'a'+organisation_user.login,
        :email => 'a'+organisation_user.email,
        :password => 'magic1',
        :password_confirmation => 'magic1',
        :site_url => organisation_user.site_url
    organisation_user.save.should be_false
    organisation_user.errors.invalid?('site_url').should be_true
  end
end
