default['openresty']['version'] = '1.2.3.8'
default['openresty']['install_prefix'] = '/opt'

case platform
when "centos", "amazon"
  set['openresty']['required_pkgs'] = %w{ readline-devel pcre-devel openssl-devel }
end
