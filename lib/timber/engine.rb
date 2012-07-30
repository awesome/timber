module Timber
  class Engine < ::Rails::Engine

    initializer 'timber.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        include Timber::NotificationPayloadCustomizations
      end
    end

  end
end
