unless File.file? '/usr/local/voltdb-3.0/bin/voltdb'
  package 'openjdk-7-jdk'
  package 'ant'

  bash 'installing voltdb 3.0' do
    cwd 'tmp'
    code <<-EOH
      set -e

      wget http://voltdb.com/downloads/technologies/server/LINUX-voltdb-3.0.tar.gz
      cd /usr/local
      tar -xvzf /tmp/LINUX-voltdb-3.0.tar.gz
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

