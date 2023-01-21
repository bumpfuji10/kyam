class IssuesController < ApplicationController
  def new
    return if user_signed_in?

    redirect_to new_user_session_path
  end

  def create
    @issue = Issue.new(issue_params)
    if @issue.save
      redirect_to issues_path
    else
      redirect_to new_issue_path
    end
  end

  def edit
    redirect_to new_user_session_path unless user_signed_in?
    @issue = Issue.find(params[:id])
  end

  def update
    @issue = Issue.find(params[:id])
    if @issue.update(issue_params)
      redirect_to @issue
    else
      redirect_to edit_issue_path(issue)
    end
  end

  def show
    @issue = Issue.find(params[:id])
  end

  def index
    @issues = Issue.all
  end

  def destroy
    @issue = Issue.find(params[:id])
    return unless @issue.destroy

    redirect_to issues_path
  end

  private

  def issue_params
    params.require(:issue).permit(:title, :content, :status)
  end
end
