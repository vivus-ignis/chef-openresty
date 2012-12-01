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

my_vhosts = []

my_ips.each do |ipaddr|
  search(:vhosts, "ip_address:#{ipaddr}").each do |vhost|
    my_vhosts.push vhost
  end
end

Chef::Log.debug("// openresty : my_ips    = #{p my_ips}")
Chef::Log.debug("// openresty : my_vhosts = #{p my_vhosts}")

template "#{node['openresty']['config_dir']}/nginx.conf" do
  source "nginx.conf.erb"
  mode   "0644"
  variables({
              :workers    => node['openresty']['num_workers'],
              :config_dir => node['openresty']['config_dir'],
              :vhosts     => my_vhosts
            })
end

my_vhosts.each do |vhost|
  template "#{node['openresty']['config_dir']}/vhost.d/#{vhost['name']}.conf" do
    source "vhost.conf.erb"
    mode   "0644"
    variables({
                :name          => vhost['name'],
                :document_root => vhost['document_root']
              })
  end
end
