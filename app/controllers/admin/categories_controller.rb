class Admin::CategoriesController < InheritedResources::Base
  
  before_filter :authenticate_admin!
  
  actions :all, :execpt => :show
  respond_to :json, :xml

  has_pagination

  def create
    create! { admin_categories_path }
  end

  def update
    update! do |success, failure|
      success.html { redirect_to collection_path }
    end
  end
  
end
