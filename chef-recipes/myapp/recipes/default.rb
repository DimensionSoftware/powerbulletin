
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
include_recipe 'phantomjs'
include_recipe 'selenium'
include_recipe 'elasticsearch'

# XXX this should perhaps go somewhere else, but for now, i like having this always
package 'tmux'
package 'vim'
package 'tree'
package 'zsh'
package 'git'
package 'libgeoip-dev'
package 'libgeoip1'
package 'postfix'

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
