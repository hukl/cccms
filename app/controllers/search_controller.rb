class SearchController < ApplicationController
  #def index
  #  @page = Page.new
  #  search_term = params[:search_term]
  #  if search_term and not search_term.empty?
  #    @results = Node.search(params[:search_term], :include => :head)
  #  end
  #end

  def index
    @page = Page.new
    search_term           = params.delete(:search_term)
    safe_search_term      = search_term.match(/[\w\s]+/)[0] rescue ""
    params[:search_term]  = safe_search_term

    unless safe_search_term.empty?
      @results = Node.search(params[:search_term], :include => :head)
    else
      @results = []
    end
  end

end
