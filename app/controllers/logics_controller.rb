#
# Controller for Logics
#
class LogicsController < InheritedResources::Base
  actions :index, :show
  defaults finder: :find_by_slug!

  has_pagination
  has_scope :search

  respond_to :html
  respond_to :json, only: %i(index show)
  respond_to :xml, :rdf, only: %i(show)

  load_and_authorize_resource :except => [:index, :show]

  def index
    super do |format|
      format.html do
        @search = params[:search]
        @search = nil if @search.blank?
      end
    end
  end

  def show
    @tab = params[:tab].try(:to_sym)
    super do |format|
      format.html do
        @depth = params[:depth] ? params[:depth].to_i : 3
        @mappings_from = resource.mappings_from
        @mappings_to = resource.mappings_to
        @ontologies = resource.ontologies
        @relation_list ||= RelationList.new [resource, :supports],
          :model       => Support,
          :collection  => resource.supports,
          :association => :language,
          :scope       => [Language]
      end
      format.xml do
        render :show, content_type: 'application/rdf+xml'
      end
      format.rdf do
        render 'show.xml', content_type: 'application/rdf+xml'
      end
    end
  end

  protected
  def collection
    if all_logics?
      super
    else
      logics = Logic.all.select{|l| !l.ontologies.empty?}
      @counter = logics.size
      collection = Kaminari.paginate_array(logics).page(params[:page])
    end
  end

  def authorize_parent
    #not needed
  end

  helper_method :all_logics?
  def all_logics?
    params[:all].present?
  end
end
