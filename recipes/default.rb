#
# Cookbook Name:: openresty
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# TODO:
# install devel packages: pcre, openssl
#

remote_file "openresty distribution, v. #{node['openresty']['version']}" do
  path   "#{Chef::Config[:file_cache_path]}/openresty-#{node['openresty']['version']}.tar.gz"
  source "http://agentzh.org/misc/nginx/ngx_openresty-#{node['openresty']['version']}.tar.gz"

  not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/openresty-#{node['openresty']['version']}.tar.gz" }
end

execute "Unpack openresty distribution" do
  command "tar xzf #{Chef::Config[:file_cache_path]}/openresty-#{node['openresty']['version']}.tar.gz"
  
  not_if  { ::File.directory? "#{Chef::Config[:file_cache_path]}/ngx_openresty-#{node['openresty']['version']}" }
end

bash "Compile openresty" do
  cwd "#{Chef::Config[:file_cache_path]}/ngx_openresty-#{node['openresty']['version']}"

  code<<-EOH
    set -x
    exec >  /var/tmp/chef-openresty-compile.log
    exec 2> /var/tmp/chef-openresty-compile.log
    ./configure --prefix=#{node['openresty']['install_prefix']}/openresty \
      --with-http_flv_module \
      --with-http_mp4_module \
      --with-debug \
      --with-http_ssl_module \
      --with-http_stub_status_module
    make
    make install
  EOH
end
