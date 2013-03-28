require "timber/engine"
require "timber/notification_payload_customizations"
require "timber/notification_payload_processor"
require "timber/rspec/notification_helpers"

module Timber

  class << self
    alias_method :register, :instance_eval
  end

  def self.subscribe(*controller_actions, &block)
    controller_actions.each do |controller_action|
      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
        event = Timber::NotificationPayloadProcessor.new(payload)
        block.call(event) if event.processed?(controller_action) && event.payload[:exception].blank?
      end
    end
  end

  def self.wait_until
    require "timeout"
    Timeout.timeout(10) { sleep(0.1) until yield }
  end

  # Allows you to trigger a subscribe method without having to actually move
  # through the controller. Can help avoid duplicating the logic used to create
  # a given timber activity.
  #
  # controller_action - Shorthand controller/action notation (e.g. 'posts#new')
  # current_user      - Current user instance (an object) or id (an integer)
  # params            - Any additional params you'd like added to the payload
  #
  # Examples
  #
  #   Timber.trigger("article#create", @user, { publication_id: 88 })
  #
  def self.trigger(controller_action, current_user, params)
    controller, action = controller_action.split('#')
    full_params = { controller: controller, action: action }.merge(params)
    current_user_id = current_user.respond_to?(:id) ? current_user.id : current_user

    ActiveSupport::Notifications.instrument("process_action.action_controller", {
      current_user_id: current_user_id, params: full_params
    })
  end

  # Allow client applications to use `link_to` within a `subscribe` block.
  #
  def self.link_to(*args, &block)
    ActionController::Base.helpers.link_to(*args, &block)
  end

  # Allow client applications to use their custom URL helpers within a
  # `subscribe` block.
  #
  def self.method_missing(method, *args, &blk)
    if method =~ /_path$/
      Rails.application.routes.url_helpers.send(method, *args, &blk)
    else
      super
    end
  end

end
