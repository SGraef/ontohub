class Repository < ActiveRecord::Base
  include Permissionable
  include Repository::Access
  include Repository::Destroying
  include Repository::GitRepositories
  include Repository::Importing
  include Repository::Ontologies
  include Repository::Scopes
  include Repository::Symlink
  include Repository::Validations

  DEFAULT_CLONE_TYPE = 'git'

  class Error < ::StandardError; end
  class DeleteError < Error; end

  has_many :ontologies, dependent: :destroy
  has_many :url_maps, dependent: :destroy
  has_many :commits, dependent: :destroy

  attr_accessible :name,
                  :description,
                  :source_type,
                  :source_address,
                  :is_destroying,
                  :remote_type,
                  :access
  attr_accessor :user

  after_save :clear_readers

  scope :latest, order('updated_at DESC')

  def to_s
    name
  end

  def to_param
    path
  end

  def blank?
    !self
  end
end
