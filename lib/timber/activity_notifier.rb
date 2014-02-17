module Timber
  module ActivityNotifier
    extend ActiveSupport::Concern

    included do
      append_after_filter :trigger_activity_logging
    end

    def trigger_activity_logging
      if status == 200 || status == 201
        payload = { params: {controller: controller_name, action: action_name} }
        payload[:params].merge!(collect_controller_data)
        payload = payload.with_indifferent_access
        trigger_activity("#{controller_name}##{action_name}", payload)
      end
    end

    def collect_controller_data
      payload = {}
      instance_variables.map do |name|
        ivar = instance_variable_get(name)
        if ivar.class < ActiveRecord::Base
          payload[name.to_s[1..-1]] = instance_variable_get(name)
        end
      end
      payload
    end

    def trigger_activity(activity_name, payload)
      ActiveSupport::Notifications.instrument activity_name, payload
    end

  end
end