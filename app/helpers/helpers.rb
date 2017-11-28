module Helpers

  def current_user
    user = User.find_by(id: session_hash[:user_id])
    user
  end

  def is_logged_in?
    !!current_user
  end

end
