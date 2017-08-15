# Setup the Percona XtraDB Cluster
#
cluster_ips = []
search(:node, 'roles:percona_dgb').sort.map do |n|
    cluster_ips << n['ipaddress']
end

unless Chef::Config[:solo]
  search(:node, 'role:percona_dgb').each do |other_node|
    next if other_node['private_ipaddress'] == node['private_ipaddress']
    Chef::Log.info "Found Percona XtraDB cluster peer: #{other_node['private_ipaddress']}"
    cluster_ips << other_node['private_ipaddress']
  end
end

cluster_address = "gcomm://#{cluster_ips.join(',')}"
Chef::Log.info "Using Percona XtraDB cluster address of: #{cluster_address}"
node.override["percona"]["cluster"]["wsrep_cluster_address"] = cluster_address
node.override["percona"]["cluster"]["wsrep_node_name"] = node['ipaddress']

include_recipe 'percona::cluster'
include_recipe 'percona::backup'
include_recipe 'percona::toolkit'
