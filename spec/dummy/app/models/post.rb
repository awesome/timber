class Post < ActiveRecord::Base
  attr_accessible :title, :author, :text
end
