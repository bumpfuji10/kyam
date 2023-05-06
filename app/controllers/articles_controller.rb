class ArticlesController < ApplicationController
  def new
    redirect_to new_user_session_path unless user_signed_in?
  end

  def create
    @article = Article.new(article_params)

    if params[:draft]
      @article.is_draft = true
      @article.is_published = false
    end

    if @article.save
      redirect_to @article
    else
      redirect_to new_article_path
    end
  end

  def show
    @article = Article.find(params[:id])
  end

  def draft
    @articles = Article.where(is_draft: true)
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

    # TODO: 公開中の記事はDRAFTボタンは表示させない
    if params[:draft]
      @article.is_draft = true
      @article.is_published = false
    end

    if params[:publish]
      @article.is_draft = false
      @article.is_published = true
    end

    if @article.update(article_params)
      @article.is_draft = false
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
    params.require(:article).permit(:title, :content, :image)
  end
end
