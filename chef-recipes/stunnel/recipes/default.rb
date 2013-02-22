ver = '4.54'

unless File.file? '/usr/local/bin/stunnel'
  package 'build-essential'

  bash "installing stunnel #{ver}" do
    cwd '/tmp'
    code <<-EOH
      set -e

      wget http://www.stunnel.org/downloads/stunnel-4.54.tar.gz
      tar -xvzf stunnel-4.54.tar.gz
      cd stunnel-4.54
      ./configure
      make
      make install-exec
      make install-data
      mkdir -p /usr/local/var/run/stunnel
      chown nobody:nogroup /usr/local/var/run/stunnel
    EOH
  end
end

