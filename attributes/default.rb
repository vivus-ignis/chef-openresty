default['openresty']['version'] = '1.2.3.8'
default['openresty']['install_prefix'] = '/opt'
default['openresty']['config_dir'] = "#{node['openresty']['install_prefix']}/openresty/nginx/conf"

default['openresty']['vhosts'] = {}

default['openresty']['luarocks_version'] = '2.0.12'

default['openresty']['num_workers'] = 64


case platform
when "centos", "amazon"
  set['openresty']['required_pkgs'] = %w{ readline-devel pcre-devel openssl-devel }
  set['openresty']['luarocks_required_pkgs'] = %w{ unzip }
end

default['openresty']['third_party_modules'] = {
  "nginx_mod_h264_streaming" => {
    "source_url" => "http://h264.code-shop.com/download/nginx_mod_h264_streaming-2.2.7.tar.gz",
    "source_dir" => "nginx_mod_h264_streaming-2.2.7"
  }
}

# "--with-http_mp4_module",

default['openresty']['configure_opts'] = [
                                          "--prefix=#{node['openresty']['install_prefix']}/openresty",
                                          "--with-http_flv_module",
                                          "--with-debug",
                                          "--with-http_ssl_module",
                                          "--with-http_stub_status_module",
                                          "--with-luajit"
                                          ]
