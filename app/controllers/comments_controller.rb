# frozen_string_literal: true

class CommentsController < ApplicationController
  skip_before_action :authorize, only: :index
  before_action :ensure_article, only: %i[index create]

  def index
    render json: @article.comments.page(params[:page]).per(params[:per_page])
  end

  def create
    @comment = @article.comments.build(comment_params)

    if @comment.save
      render json: @comment, status: :created, location: @article
    else
      render json: @comment, adapter: :json_api,
             serializer: ErrorSerializer,
             status: :unprocessable_entity
    end
  end

  private

  def ensure_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:data).require(:attributes).permit(:content).tap do |hash|
      hash[:user] = current_user
    end ||
      ActionController::Parameters.new
  end
end
