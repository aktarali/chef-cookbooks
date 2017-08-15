# chef-percona

To start a percona cluster you have to bring up 3 nodes with base role attached to them.
The base role is installing chef-client.

Using cloud formations issue the following command:
for host in "$project-db01 $project-db02 $project-db03"; do aws cloudformation --profile aaktar --region eu-west-1 create-stack --stack-name $host --template-body file:~instance$version.json --parameters ParameterKey=DefaultAlarmSNSArn,ParameterValue=IdamPingFed ParameterKey=DefaultChefServerUri,ParameterValue=https://ec2-52-212-63-208.eu-west-1.compute.amazonaws.com/organizations/inmarsat ParameterKey=DefaultChefServerValidatorName,ParameterValue=inmarsat-validator ParameterKey=DefaultCommonSecurityGroup,ParameterValue=sg-0ea36f68 ParameterKey=DefaultDiskType,ParameterValue=standard ParameterKey=DefaultKeypair,ParameterValue=ali-idam ParameterKey=DefaultRootDiskSize,ParameterValue=100 ParameterKey=DefaultVpcId,ParameterValue=vpc-e4a1c680 ParameterKey=Hostname,ParameterValue=$host-eu.aws.inmarsat.com ParameterKey=RoleEC2Ami,ParameterValue=ami-1f27696c ParameterKey=RoleInstanceType,ParameterValue=m4.large ParameterKey=RoleSubnetId,ParameterValue=subnet-dc7027b8 ParameterKey=RoleChefServerIP,ParameterValue=10.214.12.120 ParameterKey=RoleChefServerFQDN,ParameterValue=ec2-52-212-63-208.eu-west-1.compute.amazonaws.com ParameterKey=BU,ParameterValue=OneIT ParameterKey=Project,ParameterValue=idam ParameterKey=Owner,ParameterValue=AliAktar --capabilities CAPABILITY_IAM; done

This will create 3 nodes and attach a 'base' role to them. You now have a choice of either using knife or chef server UI to add the 'percona' role to ONE NODE ONLY.

run chef-client on node1 ONCE.
on the 2nd node, attach the 'percona' role and run chef-client straight away.
repeat on 3rd node.
Node 2/3 should join the first node and sync up the cluster.
if you want to see what is happening tail -f /var/log/mysql/$hostname.err on node1.
for more details you can look at the percona website.

When the cluster is running, chef-client will converge all nodes and add each node IP to the cluser list in /etc/my.cnf.

Any failures, you can debug by stopping all chef-clients from all nodes by 'systemctl stop chef-client'.
Remove all IP's from gcomm:// on NODE 1.
'systemctl start mysql@bootstrap.service'

Once node1 started up, remove all other IP's from gcomm:// from other two nodes and add node1 IP to it. Restart percona process 'systemctl restart mysql'.

Then on each node, run 'chef-client', everything should sync up and run perfectly without any further mods.
