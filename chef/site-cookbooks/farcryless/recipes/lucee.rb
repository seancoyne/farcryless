directory "/vagrant/chef/cache" do
	action :create
end

remote_file "/vagrant/chef/cache/lucee.run" do
	source 'https://www.dropbox.com/s/rj97zaae5sfhhc9/lucee-4.5.1.022-pl1-linux-x64-installer.run?dl=1'
	mode '0755'
	action :create_if_missing
end

execute 'install-lucee' do
	cwd '/vagrant/chef/cache'
	command <<-EOF
		./lucee.run --mode unattended --railopass "vagrant" --tomcatajpport 8009 --installconn true --bittype 64 --startatboot true --apachecontrolloc "/usr/sbin/apache2ctl"
		EOF
	not_if { File.exists?('/opt/lucee/lucee_ctl') }
end

file '/opt/lucee/tomcat/bin/setenv.sh' do
	action :delete
end

# increase the RAM allocation
file '/opt/lucee/tomcat/bin/setenv.sh' do
	content IO.read('/vagrant/chef/lucee/setenv.sh')
	mode '777'
	owner 'root'
	group 'root'
	action :create
end

execute "restart-lucee" do
	command "service lucee_ctl restart"
end

directory "/var/www/farcry/projects/chelsea/www/config" do
	action :create
end

file '/var/www/farcry/projects/chelsea/www/config/Application.cfc' do
	content IO.read('/vagrant/chef/lucee/Application.cfc')
	mode '777'
	owner 'root'
	group 'root'
	action :create
end

file '/var/www/farcry/projects/chelsea/www/config/dsn.cfm' do
	content IO.read('/vagrant/chef/lucee/dsn.cfm')
	mode '777'
	owner 'root'
	group 'root'
	action :create
end

http_request "configure_lucee" do
	url 'http://local.farcrylesstest.com/config/dsn.cfm'
	action :get
end
