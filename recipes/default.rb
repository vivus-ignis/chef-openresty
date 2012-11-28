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

remote_file "#{Chef::Config[:file_cache_path]}/openresty-#{node['openresty']['version']}.tar.gz)" do
  source "http://agentzh.org/misc/nginx/ngx_openresty-#{node['openresty']['version']}.tar.gz"

  not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/openresty-#{node['openresty']['version']}.tar.gz" }
end

execute "tar xzf #{Chef::Config[:file_cache_path]}/openresty-#{node['openresty']['version']}.tar.gz" do
  
  not_if { ::File.directory? "#{Chef::Config[:file_cache_path]}/ngx_openresty-#{node['openresty']['version']}" }
end

# TODO: make --enable-64bit optional

bash "Compile openresty" do
  cwd "#{Chef::Config[:file_cache_path]}/ngx_openresty-#{node['openresty']['version']}"

  code<<-EOH
    set -x
    exec >  /var/tmp/chef-openresty-compile.log
    exec 2> /var/tmp/chef-openresty-compile.log
    ./configure --prefix=#{node['openresty']['install_prefix']}/openresty \
      --with-http-flv-module \
      --with-debug \
      --with-http_ssl_module \
      --with-http_stub_status_module
    make
    make install
  EOH
end
