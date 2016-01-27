mysql_service 'default' do
  port '3306'
  version '5.6'
  initial_root_password 'vagrant'
  action [:create, :start]
end