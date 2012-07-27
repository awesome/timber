module Timber
  module NotificationPayloadCustomizations
    extend ActiveSupport::Concern

    protected

    def append_info_to_payload(payload)
      super
      payload[:current_user_id] = current_user.try(:id)
    end

    module ClassMethods
      def log_process_action(payload)
        messages, current_user_id = super, payload[:current_user_id]
        messages << current_user_id if current_user_id
        messages
      end
    end
  end
end