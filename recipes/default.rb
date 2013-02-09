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

include_recipe "openresty::third_party_modules"

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

directory "/var/log/openresty" do
  owner "nobody"
  mode  "0755"
end

runit_service "openresty" do
  default_logger true
  options({
            :nginx_bin  => "#{node['openresty']['install_prefix']}/nginx/sbin/nginx"
          })
end

include_recipe "openresty::luarocks"
