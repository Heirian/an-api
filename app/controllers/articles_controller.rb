# frozen_string_literal: true

class ArticlesController < ApplicationController
  skip_before_action :authorize, only: %i[index show]
  before_action :ensure_article, only: %i[update destroy]

  def index
    articles = Article.recent
                      .page(params[:page])
                      .per(params[:per_page])
    render json: articles
  end

  def show
    article = Article.find(params[:id])
    render json: article
  end

  def create
    @article = current_user.articles.build(articles_params)
    return render json: @article, status: :created if @article.save

    unprocessable_entity_error
  end

  def update
    if @article.update(articles_params)
      return render json: @article, status: :ok
    end

    unprocessable_entity_error
  end

  def destroy
    @article.destroy
  end

  private

  def articles_params
    params.require(:data)
          .require(:attributes)
          .permit(:title, :content, :slug) ||
      ActionController::Parameters.new
  end

  def ensure_article
    @article = current_user.articles.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    authorization_error
  end

  def unprocessable_entity_error
    render json: @article, adapter: :json_api,
           serializer: ErrorSerializer,
           status: :unprocessable_entity
  end
end
