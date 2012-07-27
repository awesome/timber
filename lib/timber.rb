require "timber/engine"
require "timber/notification_payload_customizations"
require "timber/notification_payload_processor"

module Timber

  class << self
    alias_method :register, :instance_eval
  end

  def self.subscribe(controller_action, &block)

    ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
      event = Timber::NotificationPayloadProcessor.new(payload)
      if event.processed?(controller_action)
        block.call(event)
      end
    end

  end

end
