class Event < ActiveRecord::Base
  belongs_to :user

  def city_slug
    self.city.split.join("-").downcase
  end

  def self.find_by_city_slug(slug_name)
    Event.all.each do |event|
      if event.city_slug == slug_name
        return event
      end
    end
  end

  def state_slug
    self.city.split.join("-").downcase
  end

  def self.find_by_state_slug(slug_name)
    Event.all.each do |event|
      if event.state_slug == slug_name
        return event
      end
    end
  end

end
