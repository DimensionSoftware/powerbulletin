
unless File.file? '/usr/local/bin/node'
  package 'build-essential'
  package 'systemtap'
  package 'systemtap-sdt-dev'

  bash "build & install nodejs" do
    cwd '/tmp'
    code <<-EOH
      set -e
      wget http://nodejs.org/dist/v0.10.16/node-v0.10.16.tar.gz
      tar -xzf node-v0.10.16.tar.gz
      cd node-v0.10.16
      ./configure --with-dtrace
      make
      make install
    EOH
  end
end
