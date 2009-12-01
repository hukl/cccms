class SearchController < ApplicationController
  def index
    @page = Page.new
    search_term = params[:search_term]
    if search_term and not search_term.empty?
      @results = Node.search(params[:search_term], :include => :head)
    end
  end

end
