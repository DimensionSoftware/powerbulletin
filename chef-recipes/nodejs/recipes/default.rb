
ver = '0.8.22'

unless File.file? '/usr/local/bin/node'
  package 'build-essential'

  remote_file '/tmp/node-v0.8.22.tar.gz' do
    source 'http://nodejs.org/dist/v0.8.22/node-v0.8.22.tar.gz'
    checksum '703207d7b394bd3d4035dc3c94b417ee441fd3ea66aa90cd3d7c9bb28e5f9df4'
  end

  bash "build & install nodejs #{ver}" do
    cwd '/tmp'
    code <<-EOH
      set -e
      tar -xzf node-v0.8.22.tar.gz
      cd node-v0.8.22
      ./configure
      make
      make install
    EOH
  end
end
