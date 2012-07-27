module Timber
  class Activity < ActiveRecord::Base
    self.table_name_prefix = 'timber_'

    belongs_to :trackable, :polymorphic => true
    belongs_to :owner, :polymorphic => true
    serialize :parameters, Hash
    attr_accessible :key, :owner, :parameters, :trackable

    # Give a shorthand for referencing parameters. This is helpful especially in the yaml template, where
    # writing <tt>parameters[:some_custom_attribute]</tt> over and over can be annoying. So instead you
    # can write <tt>p[:some_custom_attribute]</tt>.
    #
    alias_attribute :p, :parameters

    def self.template
      YAML.load_file("#{Rails.root}/config/locales/timber.en.yml")
    end

    def text(params = {})
      begin
        erb_template = resolve_template(key)
        if erb_template.nil?
          "Could not locate template"
        else
          parameters.merge!(params)
          renderer = ERB.new(erb_template)
          renderer.result(binding)
        end
      rescue => error
        Rails.logger.warn error.message
        puts error.message
        puts error.backtrace
        "There was a problem rendering activity message"
      end
    end

    private

    def resolve_template(key)
      snippet = nil
      unless Activity.template.nil?
        key.split(".").each do |k|
          snippet = snippet.nil? ? Activity.template[k] : snippet[k]
        end
      end
      snippet
    end

  end
end
