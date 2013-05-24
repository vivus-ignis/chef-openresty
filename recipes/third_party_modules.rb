Chef::Log.debug("// openresty: 3rd-party modules configuration: #{node['openresty']['third_party_modules'].inspect}")

node['openresty']['third_party_modules'].each do |mod_name, mod_params|
  if mod_params['source_url']

    Chef::Log.debug("// openresty : going to prepare 3rd-party module #{mod_name}")

    remote_file "nginx 3rd-party module: #{mod_name}" do
      path   "#{Chef::Config[:file_cache_path]}/#{::File.basename mod_params['source_url']}"
      source mod_params['source_url']
      
      not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/#{::File.basename mod_params['source_url']}" }
    end

    f_ext = ::File.basename(mod_params['source_url']).scan(/\.(zip|tar|gz|xz|bz2)/).join('.')

    extract_command = case f_ext
                      when "zip"
                        "unzip"
                      when "tar.gz"
                        "tar xzf"
                      end
      

    execute "Unpack #{mod_name} distribution" do
      cwd     Chef::Config[:file_cache_path]
      command "#{extract_command} #{Chef::Config[:file_cache_path]}/#{::File.basename mod_params['source_url']}"
      
      not_if  { ::File.directory? "#{Chef::Config[:file_cache_path]}/#{mod_params['source_dir']}" }
    end

    set['openresty']['configure_opts'] = node['openresty']['configure_opts'] + "--add-module=#{Chef::Config[:file_cache_path]}/#{mod_params['source_dir']}"
  end
end
