node['openresty']['required_pkgs'].each do |r_pkg|
  package r_pkg
end

remote_file "openresty distribution, v. #{node['openresty']['version']}" do
  path   "#{Chef::Config[:file_cache_path]}/openresty-#{node['openresty']['version']}.tar.gz"
  source "http://agentzh.org/misc/nginx/ngx_openresty-#{node['openresty']['version']}.tar.gz"

  not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/openresty-#{node['openresty']['version']}.tar.gz" }
end

execute "Unpack openresty distribution" do
  cwd     Chef::Config[:file_cache_path]
  command "tar xzf #{Chef::Config[:file_cache_path]}/openresty-#{node['openresty']['version']}.tar.gz"
  
  not_if  { ::File.directory? "#{Chef::Config[:file_cache_path]}/ngx_openresty-#{node['openresty']['version']}" }
end

node['openresty']['third_party_modules'].each do |mod_name, mod_params|
  if mod_params['source']

    Chef::Log.debug("// openresty : going to prepare 3rd-party module #{mod_name}")

    remote_file "nginx 3rd-party module: #{mod_name}" do
      path   "#{Chef::Config[:file_cache_path]}/#{::File.basename mod_params['source_url']}"
      source mod_params['source']
      
      not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/#{::File.basename mod_params['source_url']}" }
    end

    execute "Unpack #{mod_name} distribution" do
      cwd     Chef::Config[:file_cache_path]
      command "tar xzf #{Chef::Config[:file_cache_path]}/#{::File.basename mod_params['source_url']}"
      
      not_if  { ::File.directory? "#{Chef::Config[:file_cache_path]}/#{mod_params['source_dir']}" }
    end

    node['openresty']['configure_opts'].push "--add-module=#{Chef::Config[:file_cache_path]}/#{mod_params['source_dir']}"
  end
end

bash "Compile openresty" do
  cwd "#{Chef::Config[:file_cache_path]}/ngx_openresty-#{node['openresty']['version']}"

  code <<-EOH
    set -x
    exec >  /var/tmp/chef-openresty-compile.log
    exec 2> /var/tmp/chef-openresty-compile.log
    ./configure #{node['openresty']['configure_opts'].join(" ")}
    make
    make install
  EOH

  not_if { ::File.exists? "#{node['openresty']['install_prefix']}/openresty/nginx/sbin/nginx" }
end

directory "#{node['openresty']['config_dir']}/vhost.d" do
  owner "nobody"
  mode  "0755"
end

template "#{node['openresty']['config_dir']}/openresty.conf" do
  source "openresty.conf.erb"
  mode   "0644"
  variables({
    :workers    => node['openresty']['num_workers'],
    :config_dir => node['openresty']['config_dir'],
    :vhosts     => node['openresty']['vhosts']
  })
end

directory "/var/log/openresty" do
  owner "nobody"
  mode  "0755"
end

#include_recipe "openresty::luarocks"
