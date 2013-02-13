action :create do

  template    "#{node['openresty']['vhost_dir']}/#{new_resource.name}.conf" do
    source    new_resource.template
    variables new_resource.options
    mode      0644
  end

  new_resource.updated_by_last_action(true) 
end

action :delete do

  file "#{node['openresty']['vhost_dir']}/#{new_resource.name}.conf" do
    action :delete
  end

  new_resource.updated_by_last_action(true) 
end
