require "timber/engine"
require "timber/link_helpers"
require "timber/activity_notifier"
require "timber/notification_payload_customizations"
require "timber/notification_payload_processor"
require "timber/rspec/notification_helpers"

module Timber
  include LinkHelpers

  mattr_accessor :default_wait_time
  @@default_wait_time = 10

  class << self
    alias_method :register, :instance_eval
  end

  def self.subscribe(*controller_actions, &block)
    controller_actions.each do |controller_action|
      ActiveSupport::Notifications.subscribe controller_action do |name, start, finish, id, payload|
        event = Timber::NotificationPayloadProcessor.new(payload)
        block.call(event) if event.processed?(controller_action) && event.payload[:exception].blank?
      end
    end
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
    ActiveSupport::Notifications.instrument(controller_action, {
      current_user_id: current_user_id, params: full_params
    })
  end

end
