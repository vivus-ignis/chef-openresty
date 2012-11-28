default['openresty']['version'] = '1.2.3.8'
default['openresty']['install_prefix'] = '/opt'
default['openresty']['luarocks_version'] = '2.0.12'

case platform
when "centos", "amazon"
  set['openresty']['required_pkgs'] = %w{ readline-devel pcre-devel openssl-devel }
  set['openresty']['luarocks_required_pkgs'] = %w{ unzip }
end
