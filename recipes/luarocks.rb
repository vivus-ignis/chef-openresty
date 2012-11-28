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
    ./configure --prefix=#{node['openresty']['install_prefix']}/luarocks \
      --with-lua=#{node['openresty']['install_prefix']}/openresty/lua
    make
    make install
  EOH

#  not_if { ::File.exists? "#{node['openresty']['install_prefix']}/openresty/nginx/sbin/nginx" }
end


