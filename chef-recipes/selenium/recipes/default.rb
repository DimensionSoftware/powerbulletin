
unless File.file? '/opt/selenium-server-standalone-2.31.0.jar'
  package 'build-essential'

  bash "install selenium & soda" do
    cwd '/opt'
    code <<-EOH
      set -e
      wget http://selenium.googlecode.com/files/selenium-server-standalone-2.31.0.jar
      npm install -g soda
    EOH
  end
end
