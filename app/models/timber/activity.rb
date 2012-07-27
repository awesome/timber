module Timber
  class Activity < ActiveRecord::Base
    set_table_name :timber_activities

    belongs_to :trackable, :polymorphic => true
    belongs_to :owner, :polymorphic => true
    serialize :parameters, Hash
    attr_accessible :key, :owner, :parameters, :trackable

    def self.template
      YAML.load_file("#{Rails.root}/config/locales/activity_logger.en.yml")
    end

    def text(params = {})
      begin
        erb_template = resolveTemplate(key)
        if !erb_template.nil?
          parameters.merge! params
          renderer = ERB.new(erb_template)
          renderer.result(binding)
        else
          "Template not defined"
        end
      rescue
        "Template not defined"
      end
    end

    private

    def resolveTemplate(key)
      res = nil
      if !self.template.nil?
        key.split(".").each do |k|
          if res.nil?
            res = self.template[k]
          else
            res = res[k]
          end
        end
      end
      res
    end

  end
end
