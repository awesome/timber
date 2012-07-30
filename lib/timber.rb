require "timber/engine"
require "timber/notification_payload_customizations"
require "timber/notification_payload_processor"
require "timber/rspec/notification_helpers"
require 'pry'

module Timber

  class << self
    alias_method :register, :instance_eval
  end

  def self.subscribe(*controller_actions, &block)
    controller_actions.each do |controller_action|
      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
        event = Timber::NotificationPayloadProcessor.new(payload)
        if event.processed?(controller_action)
          block.call(event)
        end
      end
    end
  end

  # Allow client apps to use +link_to+ within a +subscribe+ block.
  #
  def self.link_to(*args, &block)
    ActionController::Base.helpers.link_to(*args, &block)
  end

  # Allow client apps to use their custom url helpers within a +subscribe+ block.
  #
  def self.method_missing(method, *args, &blk)
    if method =~ /_path$/
      Rails.application.routes.url_helpers.send(method, *args, &blk)
    else
      super
    end
  end

end
