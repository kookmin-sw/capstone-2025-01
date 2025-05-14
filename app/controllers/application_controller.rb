class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Pagination
  include Pagy::Backend

  # Current User
  def current_user
    Current.session&.user
  end
end
