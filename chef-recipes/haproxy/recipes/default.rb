unless File.file? '/usr/local/sbin/haproxy'
  package 'build-essential'
  package 'libssl-dev'

  remote_file '/tmp/haproxy.tar.gz' do
    source 'http://haproxy.1wt.eu/download/1.5/src/snapshot/haproxy-ss-20130221.tar.gz'
    #checksum ''
  end

  bash "installing haproxy" do
    cwd '/tmp'
    code <<-EOH
      set -e

      tar -xvzf haproxy.tar.gz
      cd haproxy-ss-20130221
      make TARGET=linux2628 USE_OPENSSL=1
      make install
    EOH
  end
end
