# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class GitLab
  class Credentials

    QUERY = <<-GRAPHQL.freeze
      query {
        currentUser {
          username
        }
      }
    GRAPHQL

    attr_reader :client

    def initialize(client)
      @client = client
    end

    def verify!
      response = client.perform(
        query: GitLab::Credentials::QUERY,
      )
      return if response.dig('data', 'currentUser', 'username').present?

      raise __('Invalid GitLab GraphQL API token')
    end
  end
end
