# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'

require 'graphql/gql/shared_examples/two_factor_token_validity_check'

RSpec.describe Gql::Mutations::User::Current::TwoFactor::VerifyMethodConfiguration, type: :graphql do
  let(:user)                  { create(:user) }
  let(:method_name)           { 'authenticator_app' }
  let(:token)                 { create(:token, action: 'PasswordCheck', persistent: false, user: user, expires_at: 1.hour.from_now).token }
  let(:recover_codes_enabled) { true }
  let(:payload)               { verification_code }
  let(:verification_code)     { ROTP::TOTP.new(configuration[:secret]).now }
  let(:configuration)         { user.auth_two_factor.authentication_method_object(method_name).initiate_configuration }

  let(:variables) { { methodName: method_name, token:, payload:, configuration: } }
  let(:mutation) do
    <<~MUTATION
      mutation userCurrentTwoFactorVerifyMethodConfiguration(
        $methodName: EnumTwoFactorAuthenticationMethod!
        $token: String!
        $payload: JSON!
        $configuration: JSON!
      ) {
        userCurrentTwoFactorVerifyMethodConfiguration(
          methodName: $methodName
          token: $token
          payload: $payload
          configuration: $configuration
        ) {
          recoveryCodes
          errors {
            message
            field
          }
        }
      }
    MUTATION
  end

  before do
    Setting.set('two_factor_authentication_recovery_codes', recover_codes_enabled)
    Setting.set('two_factor_authentication_method_authenticator_app', true)
  end

  context 'with authorized agent', authenticated_as: :user do
    context 'with wrong verification code' do
      let(:verification_code) { 'wrong' }

      it 'verify failed' do
        gql.execute(mutation, variables: variables)

        expect(gql.result.data[:errors][0]).to eq('message' => 'The verification of the two-factor authentication method configuration failed.', 'field' => nil)
      end

      it_behaves_like 'keeping used token', operation_name: :mutation

    end

    context 'with correct verification code', :aggregate_failures do
      it 'verify succeeded' do
        gql.execute(mutation, variables: variables)

        expect(gql.result.data[:recoveryCodes].length).to eq(10)
      end

      context 'with disabled recovery codes' do
        let(:recover_codes_enabled) { false }

        it 'verify succeeded (but without recovery codes)' do
          gql.execute(mutation, variables: variables)

          expect(gql.result.data[:recoveryCodes]).to be_nil
        end
      end

      it_behaves_like 'cleaning up used token', operation_name: :mutation
    end

    it_behaves_like 'having token validity check', operation_name: :mutation
  end

  context 'with not authorized agent', authenticated_as: :user do
    before do
      user.roles.each { |role| role.permission_revoke('user_preferences.two_factor_authentication') }
    end

    it 'raises an error' do
      gql.execute(mutation, variables: variables)

      expect(gql.result.error_type).to eq(Exceptions::Forbidden)
    end
  end
end
