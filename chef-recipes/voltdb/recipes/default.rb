ver = '2.8.4.1'
src = "voltdb-#{ver}"
tarball = "LINUX-#{src}.tar.gz"
tarball = "LINUX-voltdb-2.8.4.1.tar.gz"

unless File.file? '/usr/local/voltdb-2.8.4.1/bin/voltdb'
  package 'openjdk-7-jdk'
  package 'ant'

  bash "installing voltdb #{ver}" do
    cwd 'tmp'
    code <<-EOH
      set -e

      wget http://voltdb.com/downloads/technologies/server/LINUX-voltdb-2.8.4.1.tar.gz
      cd /usr/local
      tar -xvzf /tmp/#{tarball}
    EOH
  end
end

