class User < ActiveRecord::Base
  has_secure_password
  has_many :events
  has_many :comments

  def slug
    self.username.split.join("-").downcase
  end

  def self.find_by_slug(slug_name)
    User.all.each do |user|
      if user.slug == slug_name
        return user
      end
    end
  end

end
