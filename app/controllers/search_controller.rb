class SearchController < ApplicationController
  def index
    @page = Page.new
    search_term = params[:search_term]
    if search_term and not search_term.empty?
      nodes = Node.search(params[:search_term])
      @results = nodes.map {|node| node.head}
    end
  end

end
