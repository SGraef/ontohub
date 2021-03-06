namespace :git do
  def reconfigure_cp_keys(source_file)
    data_root = Ontohub::Application.config.data_root
    git_home = ENV['GIT_HOME']

    reconfigured_source = File.read(source_file).
      sub(/^#define DATA_ROOT .*$/, "#define DATA_ROOT \"#{data_root}\"").
      sub(/^#define GIT_HOME .*$/, "#define GIT_HOME \"#{git_home}\"")

    reconfigured_source_file = Tempfile.new(%w(cp_keys .c))
    reconfigured_source_file.write(reconfigured_source)
    reconfigured_source_file.close
    puts "Copying #{source_file} to tempfile #{reconfigured_source_file.path}"
    puts "Reconfiguring DATA_ROOT in this tempfile to #{data_root}"
    puts "Reconfiguring GIT_HOME in this tempfile to #{git_home}"

    reconfigured_source_file
  end

  def compile_gcc(source_path, target_path)
    command = ['gcc', source_path, '-o', target_path]
    puts "Compiling #{target_path.split('/').last} with"
    puts command.map { |c| c.match(/\s/) ? "'#{c}'" : c }.join(' ')
    system(*command)
  end

  def remove_symbols(target_path)
    command = ['strip', target_path]
    puts 'Removing symbols with'
    puts command.map { |c| c.match(/\s/) ? "'#{c}'" : c }.join(' ')
    system(*command)
  end

  def set_permissions(mode, path, owner_group)
    command_chmod = ['chmod', mode, path]
    puts 'Changing owner with'
    puts command_chmod.map { |c| c.match(/\s/) ? "'#{c}'" : c }.join(' ')
    system(*command_chmod)
    puts "You need to manually set the owner/group of '#{path}' to #{owner_group}"
  end

  desc 'Compile cp_keys binary'
  task :compile_cp_keys => :environment do
    unless ENV['GIT_HOME']
      $stderr.puts 'Please specify the environment variable GIT_HOME.'
      $stderr.puts "It must contain the absolute path to the git user's home."
      $stderr.puts 'Exiting.'
      exit 1
    end

    target_dir = AuthorizedKeysManager.ssh_dir
    target_dir.mkpath

    source_file = Rails.root.join('script', 'cp_keys.c')
    target_path = target_dir.join('cp_keys').to_s

    reconfigured_source_tempfile = reconfigure_cp_keys(source_file)
    compile_gcc(reconfigured_source_tempfile.path, target_path)
    remove_symbols(target_path)
    set_permissions('4500', target_path,
                    'the git user and the webserver-running group. Also, add '\
                    'execute-permissions for the webserver-running user with '\
                    "ACLs, e.g.: setfacl -m u:ontohub:--x,m::rwx #{target_path}")
    reconfigured_source_tempfile.unlink
  end

  desc 'Create authorized_keys file and set its permissions'
  task :prepare_authorized_keys => :environment do
    AuthorizedKeysManager.ssh_dir.mkpath
    if !File.exists?(AuthorizedKeysManager.authorized_keys)
      puts "Creating the file #{AuthorizedKeysManager.authorized_keys}."
      FileUtils.touch(AuthorizedKeysManager.authorized_keys)
      set_permissions('0640', AuthorizedKeysManager.authorized_keys.to_s,
                      'the webserver-running user.')
    end
  end
end
