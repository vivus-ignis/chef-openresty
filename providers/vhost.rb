action :create do

  config_name = new_resource.name.tr('^a-z', '_') + ".conf"

  template    "#{node['openresty']['vhost_dir']}/#{config_name}" do
    source    new_resource.template
    variables new_resource.options
    mode      0644
  end

  new_resource.updated_by_last_action(true) 
end

action :delete do

  config_name = new_resource.name.tr('^a-z', '_') + ".conf"

  file "#{node['openresty']['vhost_dir']}/#{config_name}" do
    action :delete
  end

  new_resource.updated_by_last_action(true) 
end
