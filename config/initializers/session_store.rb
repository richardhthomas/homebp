# Be sure to restart your server when you modify this file.

#Homebp::Application.config.session_store :cookie_store, key: '_homebp_session'

Homebp::Application.config.session_store :active_record_store, {
  expire_after: 12.hours,
}