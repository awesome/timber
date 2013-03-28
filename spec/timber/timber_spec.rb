require 'spec_helper'

describe Timber do
  before(:all) { @current_user = User.create(name: "Willa Cather")}
  after(:all) { [Post, User].map(&:destroy_all) }

  describe "integration tests" do
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

  describe "class methods" do

    describe "trigger" do
      it "should trigger the underlining timber activity" do
        ActiveSupport::Notifications.should_receive(:instrument).with(
          "process_action.action_controller",
          current_user_id: @current_user.id,
          params: { controller: 'posts', action: 'create', post_id: 88 }
        )
        Timber.trigger("posts#create", @current_user, { post_id: 88 })
      end
    end

    describe "link_to" do
      it "should delegate to the standard Rails `link_to` method" do
        ActionController::Base.should_receive(:helpers).and_return(helpers = mock)
        helpers.should_receive(:link_to).with("My Antonia", "http://test.com")
        Timber.link_to("My Antonia", "http://test.com")
      end
    end

    describe "patient_lookup" do
      it "should raise a timeout error if the code fails to execute" do
        lambda {
          Timber.patient_lookup { true }
        }.should_not raise_error
      end
      it "should not raise a timeout error if the code succeeds" do
        lambda {
          Timber.patient_lookup { false }
        }.should raise_error(Timeout::Error)
      end
      it "should return the result of the yielded block" do
        Timber.patient_lookup { 1 }.should == 1
      end
    end
  end

end
