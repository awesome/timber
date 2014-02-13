module Timber
  class NotificationPayloadProcessor

    attr_reader :params, :payload

    def initialize(payload)
      @payload = payload.with_indifferent_access
      @params = @payload[:params]
    end

    def log(attributes)
      Timber::Activity.create(
        trackable: attributes[:trackable],
        owner: attributes[:owner],
        key: attributes[:key] || "timber.#{controller}.#{action}",
        parameters: attributes[:parameters]
      )
    end

    def current_user
      User.find(payload[:current_user_id]) if payload[:current_user_id]
    end

    def processed?(controller_action)
      controller_action == "#{controller}##{action}"
    end

    def controller
      params[:controller]
    end

    def action
      params[:action]
    end

    def method_missing(method, *args, &block)
      params.has_key?(method) ? params[method] : super
    end

  end
end