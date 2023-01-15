class ArticlesController < ApplicationController
  def new
    if !user_signed_in?
      redirect_to new_user_session_path
    end
  end
end
