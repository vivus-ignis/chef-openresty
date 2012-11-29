node['openresty']['luarocks_required_pkgs'].each do |r_pkg|
  package r_pkg
end

remote_file "luarocks distribution, v. #{node['openresty']['luarocks_version']}" do
  path   "#{Chef::Config[:file_cache_path]}/luarocks-#{node['openresty']['luarocks_version']}.tar.gz"
  source "http://luarocks.org/releases/luarocks-#{node['openresty']['luarocks_version']}.tar.gz"

  not_if { ::File.exists? "#{Chef::Config[:file_cache_path]}/luarocks-#{node['openresty']['luarocks_version']}.tar.gz" }
end

execute "Unpack luarocks distribution" do
  cwd     Chef::Config[:file_cache_path]
  command "tar xzf #{Chef::Config[:file_cache_path]}/luarocks-#{node['openresty']['luarocks_version']}.tar.gz"
  
  not_if  { ::File.directory? "#{Chef::Config[:file_cache_path]}/luarocks-#{node['openresty']['luarocks_version']}" }
end

bash "Compile luarocks" do
  cwd "#{Chef::Config[:file_cache_path]}/luarocks-#{node['openresty']['luarocks_version']}"

  code <<-EOH
    set -x
    exec >  /var/tmp/chef-luarocks-compile.log
    exec 2> /var/tmp/chef-luarocks-compile.log
    ./configure --with-lua-include=#{node['openresty']['install_prefix']}/openresty/luajit/include/luajit-2.0 \
                --with-lua-lib=#{node['openresty']['install_prefix']}/openresty/luajit/lib
    make
    make install
  EOH

  not_if { ::File.exists? "/usr/local/bin/luarocks" }
end


