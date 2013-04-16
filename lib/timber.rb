require "timber/engine"
require "timber/link_helpers"
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
      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
        event = Timber::NotificationPayloadProcessor.new(payload)
        block.call(event) if event.processed?(controller_action) && event.payload[:exception].blank?
      end
    end
  end

  # `patient_lookup` is handy when dealing with actions where the object in
  # question may not be persisted when the `subscribe` is executed. For
  # example, say you've just created a post and would like to log a
  # corresponding activity. This can be tricky since the post might not
  # actually have been created yet. Using `patient_lookup` you can stall
  # execution based on an arbitrary condition (e.g. Keep trying  post exist with a
  # given title?).
  #
  # Examples
  #
  #   subscribe "posts#create" do |event|
  #     wait_until { Post.exists?(title: params[:post][:title]) }
  #     post = Post.find_by_title(event.params[:post][:title]) }
  #
  #     event.log(
  #       trackable: post,
  #       owner: current_user,
  #       parameters: {
  #         link_to_post: link_to(post.title, post),
  #       }
  #     )
  #   end
  #
  # Returns the result of block if successful. Else raises `Timeout::Error`.
  #
  def self.patient_lookup
    require "timeout"
    Timeout.timeout(Timber.default_wait_time) { sleep(0.1) until yield }
    yield
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

end
