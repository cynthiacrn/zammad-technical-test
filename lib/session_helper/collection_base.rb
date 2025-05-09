# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

module SessionHelper::CollectionBase

  module_function

  def session(collections, assets, user)

    # all base stuff
    collections[ Locale.to_app_model ]                = Locale.where(active: true)
    collections[ User::OverviewSorting.to_app_model ] = User::OverviewSorting.where(user: user)

    collections[ Taskbar.to_app_model ] = Taskbar.where(user_id: user.id, app: :desktop)
    collections[ Taskbar.to_app_model ].each do |item|
      assets = item.assets(assets)
    end

    collections[ OnlineNotification.to_app_model ] = []
    OnlineNotification.list(user).each do |item|
      assets = item.assets(assets)
    end

    collections[ RecentView.to_app_model ] = []
    RecentView.list(user, 10).each do |item|
      assets = item.assets(assets)
    end

    collections[ Permission.to_app_model ] = []
    Permission.all.each do |item|
      assets = item.assets(assets)
    end

    collections[ Role.to_app_model ] = []
    Role.all.each do |item|
      assets = item.assets(assets)
    end

    collections[ Group.to_app_model ] = []
    GroupPolicy::Scope.new(user, Group).resolve.each do |item|
      assets = item.assets(assets)
    end

    collections[ Organization.to_app_model ] = []
    if user.organization_id
      Organization.where(id: user.organization_id).each do |item|
        assets = item.assets(assets)
      end
    end

    if user.permissions?('admin.core_workflow')
      collections['CoreWorkflowCustomModule'] = CoreWorkflow::Custom.list.map { |m| { name: m } }
    end

    [collections, assets]
  end
end
