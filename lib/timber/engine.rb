module Timber
  class Engine < ::Rails::Engine

    initializer 'scholastica_billing.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        include Timber::NotificationPayloadCustomizations
      end
    end

  end
end
