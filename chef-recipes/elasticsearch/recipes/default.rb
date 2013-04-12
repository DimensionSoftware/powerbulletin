unless File.file? '/opt/elasticsearch/elasticsearch-0.20.6/bin/elasticsearch'
  package 'openjdk-7-jdk'

  bash "installing elasticsearch" do
    cwd 'tmp'
    code <<-EOH
      set -e

      wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.6.tar.gz
      cd /opt
      tar -xvzf /tmp/elasticsearch-0.20.6.tar.gz
      ln -s elasticsearch-0.20.6 elasticsearch &> /dev/null
    EOH
  end
end
