default['openresty']['version'] = '1.2.3.8'
default['openresty']['install_prefix'] = '/opt'
default['openresty']['config_dir'] = "#{node['openresty']['install_prefix']}/openresty/nginx/conf"
default['openresty']['vhost_dir']  = "#{node['openresty']['install_prefix']}/openresty/nginx/conf/vhost.d"

default['openresty']['vhosts'] = {}

default['openresty']['luarocks_version'] = '2.0.12'

default['openresty']['num_workers'] = 64


case platform
when "centos", "amazon"
  default['openresty']['required_pkgs'] = %w{ readline-devel pcre-devel openssl-devel }
  default['openresty']['luarocks_required_pkgs'] = %w{ unzip }
else
  raise "Unsupported platform"
end

default['openresty']['third_party_modules'] = {}

# default['openresty']['third_party_modules'] = {
#   "nginx_mod_h264_streaming" => {
#     "source_url" => "https://github.com/vivus-ignis/nginx_mod_h264_streaming/archive/master.zip",
#     "source_dir" => "nginx_mod_h264_streaming-master"
#   }
# }

default['openresty']['configure_opts'] = [
                                          "--prefix=#{node['openresty']['install_prefix']}/openresty",
                                          "--with-http_mp4_module",
                                          "--with-http_flv_module",
                                          "--with-debug",
                                          "--with-http_ssl_module",
                                          "--with-http_stub_status_module",
                                          "--with-luajit"
                                          ]
