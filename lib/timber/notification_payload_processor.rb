module Timber
  class NotificationPayloadProcessor

    attr_reader :params, :payload

    def initialize(payload)
      @payload = payload.with_indifferent_access
      @params = @payload[:params]
    end

    def current_user
      User.find(payload[:current_user_id]) if payload[:current_user_id]
    end

    def processed?(controller_action)
      controller_action == "#{controller}##{action}"
    end

    private

    def controller
      params[:controller]
    end

    def action
      params[:action]
    end
  end
end