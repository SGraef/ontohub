module RepositoriesHelper

  def clone_methods(visible: Repository::DEFAULT_CLONE_TYPE)
    methods = %w{git ssh-git}
    methods.map! { |method| [method, method == visible]} if visible
    methods
  end

# def clone_method_links
#   clone_methods.map do |clone_method|
#     clone_method_link clone_method
#   end.join(', ')
# end

  def clone_method_link(method, text)
    link_to(text, "##{method}", class: 'clone_method_link', data: {clone: method})
  end

  def clone_type
    params[:clone_type] || Repository::DEFAULT_CLONE_TYPE
  end

  def repository_clone_url(repository, clone_type: 'git', port: nil)
    case clone_type
    when 'git'
      repository_tree_url(repository, protocol: 'git', port: nil) << '.git'
    when 'ssh-git'
      "git@#{Ontohub::Application.config.fqdn}:#{repository.path}.git"
    end
  end

  def access_change_hint
    t 'repository.access.change_hint' if resource.is_private
  end

  def access_options
    t('repository.access.options').invert
  end

  def access_options_mirror
    t('repository.access.options_mirror').invert
  end

  def repository_modal_body
    modal_body(t('delete_repository'), t('delete_repository_desc'),
      reource_repository, t('repository.delete'))
  end

  def repository_undelete_modal_body
    modal_body(t('repository.undelete.headline'),
      t('repository.undelete.description'), [reource_repository, :undestroy],
      t('repository.undelete.button'), method: :post, btn_class: 'btn-primary')
  end

  def reource_repository
    controller_name == 'repositories' ? resource : parent
  end
end
