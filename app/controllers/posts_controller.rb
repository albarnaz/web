# encoding: UTF-8
class PostsController < ApplicationController
  load_permissions_and_authorize_resource
  load_and_authorize_resource :council, parent: true, find_by: :url
  before_action :set_councils, only: [:new, :edit, :update, :create]
  before_action :set_user, only: [:remove_user, :add_user]

  def remove_user
    user = User.find_by_id(params[:user_id])
    @post.users.delete(user)
    flash[:notice] = I18n.t('post.user_removed', u: user.to_s, p: @post.to_s)
    redirect_to council_posts_path(@council)
  end

  def add_user
    if @post.add_user(@user)
      flash[:notice] = I18n.t('post.added', u: @user.to_s, p: @post.to_s)
    else
      flash[:alert] = I18n.t('post.add_error', errors: @post.errors.full_messages)
    end
    redirect_to back
  end

  def index
    @posts = (@council.present?) ? @council.posts : Post.all
    @post_grid = initialize_grid(@posts)
  end

  def new
    @post = @council.posts.build
  end

  def edit
    @councils = Council.order(title: :asc)
  end

  def create
    @post = @council.posts.build(post_params)
    if @post.save
      redirect_to council_posts_path(@council), notice: alert_create(Post)
    else
      render action: :new
    end
  end

  def update
    if @post.update(post_params)
      redirect_to edit_council_post_path(@post.council, @post),
                  notice: alert_update(Post)
    else
      render action: :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to council_posts_path(@council)
  end

  def display
  end

  def collapse
  end

  private

  def post_params
    params.require(:post).permit(:title, :limit, :recLimit,
                                 :description, :elected_by, :elected_at,
                                 :styrelse, :car_rent, :council_id)
  end

  def set_councils
    @councils = Council.order(title: :asc)
  end

  def set_user
    if @post.nil?
      @post = Post.find_by_id(params[:post_id])
    end
    @user = User.find_by_id(params[:user_id])
  end

  def back
    @council.present? ? council_posts_path(@council) : posts_path
  end
end
