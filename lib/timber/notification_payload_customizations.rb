module Timber
  module NotificationPayloadCustomizations
    extend ActiveSupport::Concern

    protected

    module ClassMethods
      def log_process_action(payload)
        messages, current_user_id = super, payload[:current_user_id]
        messages << current_user_id if current_user_id
        messages
      end
    end
  end
end