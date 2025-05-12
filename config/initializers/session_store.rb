Rails.application.config.session_store :cookie_store, key: "_lawnow_webapp_session", secure: Rails.env.production?, httponly: true, same_site: :lax
