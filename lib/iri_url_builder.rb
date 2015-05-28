module IRIUrlBuilder
  module Includeable
    def versioned_iri
      IRIUrlBuilder::Builder.new(self).versioned_iri
    end
  end

  class Builder
    attr_accessor :resource

    def initialize(resource)
      self.resource = resource
    end

    def versioned_iri
      paths.ontology_iri_versioned_url(
        host: Ontohub::Application.config.fqdn,
        path: path,
        locid: file,
        reference: ontology_version.number,
        repository_id: repository)
    end

    # return path unless the basepath only consists of the filename
    def path
      path = File.dirname(ontology_version.basepath)
      path if path != '.'
    end

    def file
      File.basename(ontology_version.basepath)
    end

    def ontology_version
      resource.try(:current_version) || resource
    end

    def ontology
      ontology_version.ontology
    end

    def repository
      ontology_version.ontology.repository
    end

    def paths
      Rails.application.routes.url_helpers
    end
  end
end
