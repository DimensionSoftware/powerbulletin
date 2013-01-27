unless File.file? '/usr/local/voltdb/bin/voltdb'
  package 'openjdk-7-jdk'
  package 'ant'

##source tarball install, not used now until voltdb integrates clojure patch
#  bash 'installing voltdb 3.0' do
#    cwd 'tmp'
#    code <<-EOH
#      set -e
#
#      wget http://voltdb.com/downloads/technologies/server/LINUX-voltdb-3.0.tar.gz
#      cd /usr/local
#      tar -xvzf /tmp/LINUX-voltdb-3.0.tar.gz
#    EOH
#  end

  package 'git'
  bash 'installing custom voltdb (patched by dimension software)' do
    cwd '/usr/local'
    code <<-EOH
      set -e
      git clone http://github.com/DimensionSoftware/voltdb.git
      cd voltdb
      ant
    EOH
  end

  bash 'installing voltdb tools 3.0' do
    cwd 'tmp'
    code <<-EOH
      set -e

      wget http://voltdb.com/downloads/technologies/other/voltdb-tools-3.0.tar.gz
      cd /usr/local
      tar -xvzf /tmp/voltdb-tools-3.0.tar.gz
    EOH
  end
end
