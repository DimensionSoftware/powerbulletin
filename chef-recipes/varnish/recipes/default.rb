ver = '3.0.3'

unless File.file? '/usr/local/sbin/varnishd'
  package 'build-essential'
  package 'pkg-config'
  package 'libpcre3-dev'

  bash "installing varnish #{ver}" do
    cwd '/tmp'
    code <<-EOH
      set -e

      wget http://repo.varnish-cache.org/source/varnish-3.0.3.tar.gz
      tar -xvzf varnish-3.0.3.tar.gz
      cd varnish-3.0.3
      ./configure
      make
      make install
    EOH
  end
end

