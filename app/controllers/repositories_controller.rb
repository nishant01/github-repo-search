class RepositoriesController < ApplicationController
  before_action :set_default_params

  def index
  end

  def search
    search_result = ::GithubApi::Repositories.new(create_search_params).call
    @total_count = search_result["total_count"]
    @data = Kaminari.paginate_array(search_result["items"], total_count: @total_count).page(params[:page]).per(30)
    rescue
      @data = {}
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def set_default_params
    params[:search_term] = params[:search_term].present? ? params[:search_term] : ''
    params[:language] = params[:language].present? ? params[:language] : ''
    params[:sort] = params[:sort].present? ? params[:sort] : 'stars'
    params[:order] = params[:order].present? ? params[:order] : 'desc'
    params[:page] = params[:page].present? ? params[:page] : 1
  end

  def create_search_params
    {
        search_term: params[:search_term],
        language: params[:language],
        sort: params[:sort],
        order: params[:order],
        page: params[:page]
    }
  end

  def search_params
    params.permit(:search_term, :language, :sort, :order, :page)
  end
end
