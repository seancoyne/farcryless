
directory "/var/www/farcry" do
	action :create
end

directory "/var/www/farcry/plugins" do
	action :create
end

directory "/var/www/farcry/projects" do
	action :create
end

git "/var/www/farcry/core" do
	
	repository "https://github.com/farcrycore/core.git"
	revision "p720"
	action :checkout
	
end

git "/var/www/farcry/plugins/farcrycms" do
	
	repository "https://github.com/farcrycore/plugin-farcrycms.git"
	action :checkout
	
end

git "/var/www/farcry/plugins/testMXUnit" do
	
	repository "https://github.com/farcrycore/plugin-testMXUnit.git"
	action :checkout
	
end

git "/var/www/farcry/projects/chelsea" do
	
	repository "https://github.com/farcrycore/project-chelsea.git"
	action :checkout
	
end

ruby_block "add testMXUnit and farcryless plugins to farcryConstructor" do
  block do
    fe = Chef::Util::FileEdit.new("/var/www/farcry/projects/chelsea/www/farcryConstructor.cfm")
    fe.search_file_replace(/<cfset THIS.plugins = "farcrycms">/,'<cfset THIS.plugins = "farcrycms,testMXUnit,farcryless">')
    fe.write_file
  end
end