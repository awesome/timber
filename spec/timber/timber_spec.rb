require 'spec_helper'

describe Timber do
  before(:all) { @current_user = User.create(name: "Willa Cather")}
  after(:all) { [Post, User].map(&:destroy_all) }

  describe "posts#create" do
    before(:all) do
      @post = Post.create(title: "Neighbour Rosicky", text: "When Doctor Burleigh...", author: "Willa Cather")
      @activity = publish_notification(
        controller: "posts",
        action: "create",
        current_user: @current_user,
        params: {
          post: { title: "Neighbour Rosicky" }
        }
      )
    end
    it "should set the owner association" do
      @activity.owner.should == @current_user
    end
    it "should set the trackable association" do
      @activity.trackable.should == @post
    end
    it "should set the params hash" do
      @activity.parameters[:user_name].should == "Willa Cather"
    end
    it "should set the activity text" do
      @activity.text.should == "Willa Cather created a post: &ldquo;Neighbour Rosicky&rdquo;"
    end
  end

  describe "posts#update" do
    before(:all) do
      @post = Post.create(title: "My Antonia", text: "Last summer...", author: "Willa Cather")
      @activity = publish_notification(
        controller: "posts",
        action: "update",
        current_user: @current_user,
        params: { id: @post.id }
      )
    end
    it "should set the owner association" do
      @activity.owner.should == @current_user
    end
    it "should set the trackable association" do
      @activity.trackable.should == @post
    end
    it "should set the params hash" do
      @activity.parameters[:user_name].should == "Willa Cather"
    end
    it "should set the activity text" do
      @activity.text.should == "Willa Cather updated a post: &ldquo;My Antonia&rdquo;"
    end
  end

end
