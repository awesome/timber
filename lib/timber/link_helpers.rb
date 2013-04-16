module Timber
  module LinkHelpers
    extend ActiveSupport::Concern

    included do

      # Allow client applications to use `link_to` within a `subscribe` block.
      #
      def self.link_to(*args, &block)
        ActionController::Base.helpers.link_to(*args, &block)
      end

      # Allow client applications to use their custom URL helpers within a
      # `subscribe` block.
      #
      def self.method_missing(method, *args, &blk)
        if method =~ /_path$/ || method =~ /_url$/
          Rails.application.routes.url_helpers.send(method, *args, &blk)
        else
          super
        end
      end

    end
  end
end