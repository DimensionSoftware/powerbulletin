file_cache_path "/tmp/chef-solo"
cookbook_path File.expand_path('./chef-recipes')
run_list ["recipe[myapp]"]

