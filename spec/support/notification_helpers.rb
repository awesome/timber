module Timber
  module NotificationHelpers

    def publish_notification(opts = {})
      ActiveSupport::Notifications.publish('process_action.action_controller',
        'process_action.action_controller', # name
        Time.now,                           # start time
        5.seconds.from_now,                 # finish time
        {                                   # payload
          current_user_id: opts[:current_user].id,
          params: {
            controller: opts[:controller],
            action: opts[:action]
          }.merge!(opts[:params])
        }
      )
      Timber::Activity.last
    end

  end
end
