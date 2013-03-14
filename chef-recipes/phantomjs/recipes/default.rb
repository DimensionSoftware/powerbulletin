unless File.file? '/usr/local/bin/phantomjs'
  package 'build-essential'
  package 'libfontconfig1-dev'

  bash "build & install phantomjs" do
    cwd '/tmp'
    code <<-EOH
      set -e
      wget http://phantomjs.googlecode.com/files/phantomjs-1.8.2-linux-x86_64.tar.bz2
      tar -xvjf phantomjs-1.8.2-linux-x86_64.tar.bz2
      mv phantomjs-1.8.2-linux-x86_64/bin/phantomjs /usr/local/bin
    EOH
  end
end
