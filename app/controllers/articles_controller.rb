class ArticlesController < ApplicationController
  def new
    redirect_to new_user_session_path unless user_signed_in?
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article
    else
      redirect_to new_article_path
    end
  end

  def show
    @article = Article.find(params[:id])
  end

  def index
    @articles = Article.all.with_rich_text_content.order(id: "DESC")
  end

  def edit
    redirect_to new_user_session_path unless user_signed_in?
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update(article_params)
      redirect_to @article
    else
      redirect_to edit_article_path(article)
    end
  end

  def destroy
    @article = Article.find(params[:id])
    if @article.delete
      redirect_to articles_path
    else
      redirect_to @article
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :content)
  end
end
