
unless File.file? '/usr/local/bin/mon'
  package 'git'
  package 'build-essential'

  bash "install mon" do
    cwd '/tmp'
    code <<-EOH
      set -e
      git clone http://github.com/visionmedia/mon.git
      cd mon
      make install
    EOH
  end
end
