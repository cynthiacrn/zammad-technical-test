# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class HttpLog < ApplicationModel
  store :request
  store :response

  # See https://github.com/zammad/zammad/issues/2100
  before_save :messages_to_utf8

=begin

cleanup old http logs

  HttpLog.cleanup

optional you can put the max oldest chat entries as argument

  HttpLog.cleanup(1.month)

=end

  def self.cleanup(diff = 1.month)
    where(created_at: ...diff.ago)
      .delete_all

    true
  end

  private

  def messages_to_utf8
    request.transform_values! { |v| v.try(:utf8_encode) || v }
    response.transform_values! { |v| v.try(:utf8_encode) || v }
  end
end
