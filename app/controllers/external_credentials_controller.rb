# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

class ExternalCredentialsController < ApplicationController
  prepend_before_action :authenticate_and_authorize!

  def index
    model_index_render(ExternalCredential, params)
  end

  def show
    model_show_render(ExternalCredential, params)
  end

  def create
    model_create_render(ExternalCredential, params)
  end

  def update
    model_update_render(ExternalCredential, params)
  end

  def destroy
    model_destroy_render(ExternalCredential, params)
  end

  def app_verify
    render json: { attributes: ExternalCredential.app_verify(params.permit!.to_h) }, status: :ok
  rescue => e
    logger.error e
    render json: { error: e.message }, status: :ok
  end

  def link_account
    provider = params[:provider].downcase
    attributes = ExternalCredential.request_account_to_link(provider, params)
    session[:request_token] = attributes[:request_token]
    session[:channel_id] = params[:channel_id]
    session[:shared_mailbox] = params[:shared_mailbox]
    redirect_to attributes[:authorize_url], allow_other_host: true
  end

  def callback
    provider = params[:provider].downcase
    channel = ExternalCredential.link_account(provider, session[:request_token], link_params)
    return redirect_to(channel), allow_other_host: true if channel.instance_of?(String)

    session[:request_token] = nil
    session[:channel_id] = nil
    session[:shared_mailbox] = nil
    redirect_to app_url(provider, channel.id), allow_other_host: true
  end

  private

  def link_params
    params.permit!.to_h.merge(channel_id: session[:channel_id], shared_mailbox: session[:shared_mailbox])
  end

  def callback_url(provider)
    ExternalCredential.callback_url(provider)
  end

  def app_url(provider, channel_id)
    ExternalCredential.app_url(provider, channel_id)
  end
end
