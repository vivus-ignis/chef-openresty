directory "#{node['openresty']['config_dir']}/vhost.d" do
  owner "nobody"
  mode  "0755"
end


### lookup vhosts in databags by this host ips

my_ips = []

node['network']['interfaces'].each do |iface| 
  iface[1]['addresses'].each do |addr, params|
    my_ips.push addr if params['family'] == 'inet'
  end
end

my_ips.delete "127.0.0.1"

my_vhost_names = []

my_ips.each do |ipaddr|
  search(:vhosts, "ip_address:#{ipaddr}").each do |vhost|
    my_vhost_names.push vhost['name']
  end
end

Chef::Log.debug("// openresty : my_ips         = #{p my_ips}")
Chef::Log.debug("// openresty : my_vhost_names = #{p my_vhost_names}")

template "#{node['openresty']['config_dir']}/nginx.conf" do
  source "nginx.conf.erb"
  mode   "0644"
  variables({
              :workers     => node['openresty']['num_workers'],
              :config_dir  => node['openresty']['config_dir'],
              :vhost_names => my_vhost_names
            })
end

my_ips.each do |ipaddr|

  search(:vhosts, "ip_address:#{ipaddr}").each do |vhost|
    template "#{node['openresty']['config_dir']}/vhost.d/#{vhost['name']}.conf" do
      source "vhost.conf.erb"
      mode   "0644"
      variables({
                  :name          => vhost['name'],
                  :document_root => vhost['document_root']
                })
    end
  end

end
