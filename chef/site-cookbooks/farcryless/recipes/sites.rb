web_app "localhost" do
  server_name "localhost"
  server_aliases [ "local.farcrylesstest.com" ]
  docroot "/var/www/farcry/projects/chelsea/www"
  directory_index  [ "index.cfm" ]
  cookbook 'farcryless'
end