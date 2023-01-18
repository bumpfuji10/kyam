class ArticlesController < ApplicationController
  def new
    if !user_signed_in?
      redirect_to new_user_session_path
    end
  end

  def create
    article = Article.new(article_params)
    if article.save
      redirect_to article
    else
      redirect_to new_article_path
    end
  end

  def show
    @article = Article.find_by(id: params[:id])
  end

  def index
    @articles = Article.all.with_rich_text_content
  end

  def edit
    @articles = Article.find_by(id: params[:id])
  end

  private

  def article_params
    params.permit(:title, :content)
  end

end
