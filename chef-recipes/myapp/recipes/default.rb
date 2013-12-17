
unless File.file? '/etc/APT_GET_INITIAL_UPDATE_COMPLETED'
  bash 'apt-get update' do
    code <<-EOH
      apt-get update
      touch /etc/APT_GET_INITIAL_UPDATE_COMPLETED
    EOH
  end
end

user 'pb' do
  shell '/bin/false'
  home '/pb'
  supports :manage_home => true
end

# other stuff...
include_recipe 'nodejs'
include_recipe 'varnish'
include_recipe 'haproxy'
include_recipe 'postgres'
include_recipe 'redis'
#include_recipe 'phantomjs'
include_recipe 'selenium'
include_recipe 'mon'
include_recipe 'elasticsearch'

# XXX this should perhaps go somewhere else, but for now, i like having this always
package 'ack-grep'
package 'tmux'
package 'vim'
package 'figlet'
package 'tree'
package 'zsh'
package 'git'
package 'tig'
#package 'git-extras'
package 'libgeoip-dev'
package 'libgeoip1'
package 'postfix'
package 'graphicsmagick'

# lets install a few extra packages globally from npm (lets not get carried away kids)
unless File.file? '/etc/NPM_GLOBAL_PACKAGES_COMPLETED'
  bash 'install grunt, LiveScript' do
    code <<-EOH
      set -e
      npm install -g git://github.com/gruntjs/grunt-cli.git
      npm install -g LiveScript
      npm install -g contextify
      touch /etc/NPM_GLOBAL_PACKAGES_COMPLETED
    EOH
  end
end

# copy our editing settings
cookbook_file '/root/.vimrc' do
  source 'vim/.vimrc'
  mode '0644'
end
remote_directory '/root/.vim' do
  source 'vim/.vim'
  files_owner 'root'
  files_group 'root'
  files_mode 00644
  owner 'root'
  group 'root'
  mode 00755
end

#tmux config
cookbook_file '/root/.tmux.conf' do
  source 'dotfiles/_tmux.conf'
  mode '0644'
end

# SYMLINK CITY! these settings differ between prod and dev
if ENV['NODE_ENV'] == 'production'
  project_dir = '/pb'
  # more setup symlinks for plv8
  link "/pb" do
    to "/vagrant"
  end
else
  project_dir = '/vagrant'
end

# setup symlinks for plv8
link "/usr/local/plv8/plv8_modules" do
  to "#{project_dir}/plv8_modules"
end

# setup symlinks for elasticsearch
link "/opt/elasticsearch/config" do
  to "#{project_dir}/config/elasticsearch"
end
