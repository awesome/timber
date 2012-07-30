Timber.register do

  subscribe "posts#create" do |event|
    post = Post.find_by_title(event.params[:post][:title])
    event.log(
      trackable: post,
      owner: event.current_user,
      key: "timber.posts.create",
      parameters: { user_name: event.current_user.name }
    )
  end

  subscribe "posts#update" do |event|
    post = Post.find(event.params[:id])
    event.log(
      trackable: post,
      owner: event.current_user,
      parameters: { user_name: event.current_user.name }
    )
  end

end
