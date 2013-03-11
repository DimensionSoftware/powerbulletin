
unless File.file? '/usr/local/bin/redis-server'
  package 'build-essential'

  bash "build & install redis" do
    cwd '/tmp'
    code <<-EOH
      set -e
      wget http://redis.googlecode.com/files/redis-2.6.11.tar.gz
      tar -xvzf redis-2.6.11.tar.gz
      cd redis-2.6.11
      make
      make install
    EOH
  end
end
