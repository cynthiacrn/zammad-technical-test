# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

module Gql::Mutations
  class User::Current::TwoFactor::RemoveMethod < BaseMutation
    include Gql::Concerns::HandlesPasswordRevalidationToken

    description 'Removes given two factor authentication method'

    argument :method_name, String, description: 'Name of the method to remove'

    field :success, Boolean, description: 'This indicates if removing authentication method was successful'

    def self.authorize(_obj, ctx)
      ctx.current_user.permissions?('user_preferences.two_factor_authentication')
    end

    def resolve(method_name:, token:)
      token_object = verify_token!(token)

      Service::User::TwoFactor::RemoveMethod
        .new(user: context.current_user, method_name:)
        .execute

      token_object.destroy

      { success: true }
    end
  end
end
