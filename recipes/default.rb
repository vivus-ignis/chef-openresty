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

bash "Compile openresty" do
  cwd "#{Chef::Config[:file_cache_path]}/ngx_openresty-#{node['openresty']['version']}"

  code <<-EOH
    set -x
    exec >  /var/tmp/chef-openresty-compile.log
    exec 2> /var/tmp/chef-openresty-compile.log
    ./configure --prefix=#{node['openresty']['install_prefix']}/openresty \
      --with-http_flv_module \
      --with-http_mp4_module \
      --with-debug \
      --with-http_ssl_module \
      --with-http_stub_status_module \
      --with-luajit
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

include_recipe "openresty::luarocks"
