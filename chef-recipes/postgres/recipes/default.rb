# followed instructions from www.postgresql.org/download/linux/ubuntu/
unless File.file? '/usr/bin/psql'
  cookbook_file '/etc/apt/sources.list.d/pgdg.list' do
    source 'pgdg.list'
    mode '0644'
  end

  cookbook_file '/etc/apt/preferences.d/pgdg.pref' do
    source 'pgdg.pref'
    mode '0644'
  end

  bash "installing pgdg repository (postgres official)" do
    code <<-EOH
      set -e
      wget -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -

      sudo apt-get update
      sudo apt-get install pgdg-keyring postgresql-9.2 postgresql-server-dev-9.2 -y
    EOH
  end

  cookbook_file '/etc/postgresql/9.2/main/pg_hba.conf' do
    source 'pg_hba.conf'
    mode '0644'
  end

  bash "restarting postgres (so custom config can be loaded)" do
    code <<-EOH
      set -e
      sudo service postgresql restart
    EOH
  end

  package 'libv8-dev'
  bash "installing plv8" do
    cwd '/tmp'
    code <<-EOH
      set -e
      git clone https://code.google.com/p/plv8js/
      cd plv8js
      make
      make install
    EOH
  end
end
