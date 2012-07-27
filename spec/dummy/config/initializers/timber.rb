Timber.register do

  subscribe "posts#create" do |event|
    post = Post.find_by_title(event.params[:post][:title])
    Timber::Activity.create(
      trackable: post,
      owner: event.current_user,
      key: "timber.post.create",
      parameters: { user_name: event.current_user.name }
    )
  end

end
