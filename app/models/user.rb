require 'digest/sha1'
require 'rubygems'
require 'has_many_polymorphs'

class User < ActiveRecord::Base

  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 6..40

  validates_presence_of :login, :email, :password, :password_confirmation, :salt
  validates_uniqueness_of :login, :email
  validates_uniqueness_of :blog_url, :allow_nil => true, :if => Proc.new { |u| !u.blog_url.blank? }
  validates_format_of :blog_url, :with => /^((?:[-a-z0-9]+\.)+[a-z]{2,})$/, :allow_nil => true, :if => Proc.new { |u| !u.blog_url.blank? }
  validates_confirmation_of :password

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/,
      :if => Proc.new { |u| !u.email.blank? },
      :message => "format is invalid"

  validates_format_of :login, :with => /^([a-z]+)(_[a-z]+)*$/,
      :if => Proc.new { |u| !u.login.blank? },
      :message => "format is invalid, try lower case letters, with _ in between words"

  attr_protected :id, :salt

  attr_accessor :password, :password_confirmation

  has_many_polymorphs :items, :from => [:bills, :portfolios, :committees], :through => :trackings

  def self.authenticate(login, pass)
    user = find(:first, :conditions=>["login = ?", login])
    if (not(user.nil?) and (User.encrypt(pass, user.salt) == user.hashed_password))
      user
    else
      nil
    end
  end

  def tracked_items
    items(true)
  end

  def password=(pass)
    @password=pass
    self.salt = User.random_string(10) unless self.salt
    self.hashed_password = User.encrypt(@password, self.salt)
  end

  def send_new_password
    new_pass = User.random_string(10)
    self.password = self.password_confirmation = new_pass
    self.save
    User.deliver_forgot_password(self.email, self.login, new_pass)
  end

  def self.deliver_forgot_password(email, login, new_pass)

  end

  protected

    def self.encrypt(pass, salt)
      Digest::SHA1.hexdigest(pass + salt)
    end

    def self.random_string(len)
      # generate a random password consisting of strings and digits
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      return newpass
    end

end
