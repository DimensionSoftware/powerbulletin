
# target version (no sense of up or down, just forward)
ver = 'v0.10.17'

installed_ver = `which node > /dev/null && node -v`.strip!

unless ver == installed_ver
  bash "install nodejs #{ver}" do
    cwd '/tmp'
    code <<-EOH
      set -e
      wget http://nodejs.org/dist/#{ver}/node-#{ver}-linux-x64.tar.gz

      cd /usr/local
      tar -xzf /tmp/node-#{ver}-linux-x64.tar.gz --strip-components=1
    EOH
  end
end
