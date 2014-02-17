module Timber
  module NotificationHelpers

    def publish_notification(opts = {})
      event_name = "#{opts[:controller]}##{opts[:action]}"
      ActiveSupport::Notifications.publish(event_name,
        event_name,                                   # name
        Time.now,                                     # start time
        5.seconds.from_now,                           # finish time
        {                                             # payload
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
