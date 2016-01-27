mysql_connection_info = {
	:host     => '127.0.0.1',
	:username => 'root',
	:password => 'vagrant'
}

mysql2_chef_gem 'default' do
	action :install
end

mysql_client 'default' do
	action :create
end

mysql_database 'farcryless_test' do
	connection mysql_connection_info
	action :create
end

# restore expoconsolec database
execute "restore farcryless_test" do
	command "mysql -S /var/run/mysql-default/mysqld.sock --user=root --password=vagrant farcryless_test < /vagrant/chef/sql/farcryless_test.sql"
	action :run
end

# grant root full access from all hosts
mysql_database_user 'root' do
	connection mysql_connection_info
	password 'vagrant'
	host '%'
	action :grant
end

# create vagrant user
mysql_database_user 'vagrant' do
	connection mysql_connection_info
	password 'vagrant'
	action :create
end

# grant vagrant full access from all hosts
mysql_database_user 'vagrant' do
	connection mysql_connection_info
	password 'vagrant'
	host '%'
	action :grant
end

mysql_database_user 'vagrant' do
	connection mysql_connection_info
	password 'vagrant'
	host 'localhost'
	action :grant
end
