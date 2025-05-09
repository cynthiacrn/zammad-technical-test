# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

module Gql::Mutations::Concerns::Logout::HandlesOidcAuthorization
  extend ActiveSupport::Concern

  included do
    def oidc_session?
      session[:oidc_id_token].present?
    end

    def oidc_destroy
      { success: true, external_logout_url: oidc_logout_url }
    rescue => e
      Rails.logger.error "OpenID Connect RP-initiated logout failed: #{e.message}"
    end

    def oidc_logout_url
      oidc = OmniAuth::Strategies::OidcDatabase.new(OmniAuth::Strategies::OidcDatabase.setup)

      options = oidc.config

      logout_url = Addressable::URI.parse(options.end_session_endpoint)
      logout_url.query_values = {
        id_token_hint:            session[:oidc_id_token],
        post_logout_redirect_uri: "#{Setting.get('http_type')}://#{Setting.get('fqdn')}/desktop/login"
      }

      OmniAuth::Strategies::OidcDatabase.destroy_session(context[:controller].request.env, session)

      logout_url
    end
  end
end
