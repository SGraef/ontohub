class LogicViewhelper

  attr_reader :available_tabs, :available_tab_links

  def initialize(resource)
    @resource = resource
    initialize_data
  end

  private
  def initialize_data
    @available_tabs = [
      ['Mappings', :mappings],
      ['Supports', :supports],
      [Settings.OMS.pluralize.capitalize,
         :ontologies, @resource.ontologies.size],
      ["Homogeneous distributed #{Settings.OMS.pluralize}", :distributed,
        Ontology.distributed_in(@resource).size],
      ["Heterogeneous distributed #{Settings.OMS.pluralize}",
         :heterogeneous_distributed,
         Ontology.also_distributed_in(@resource).size],
    ]
    @available_tab_links = [
      ['Graph',
        :graphs]
    ]
    fetcher = GraphDataFetcher.new(center: @resource)
    if fetcher.query_cost > 500
      @available_tab_links = []
    end
  end

end
