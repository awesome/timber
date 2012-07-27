class User < ActiveRecord::Base
  attr_accessible :name
  has_many :activities, foreign_key: :owner_id, class_name: 'Timber::Activity'
end
