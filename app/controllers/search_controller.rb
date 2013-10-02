# 
# Permissions list administration of a team, only accessible by ontology owners
# 
class SearchController < ApplicationController

  def index
    @content_kind = :symbols
    @query        = params[:q]
    @max_groups   = 100

    if @query.blank?
      @query = nil
    else
      @search = Entity.search_with_ontologies(@query, @max_groups)
      @group  = @search.group(:ontology_id_str)
      @groups = @group.groups
    end
  end
  
end
