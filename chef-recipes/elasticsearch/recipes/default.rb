unless File.file? '/opt/elasticsearch-0.90.3/bin/elasticsearch'
  package 'openjdk-7-jdk'

  bash "installing elasticsearch" do
    cwd 'tmp'
    code <<-EOH
      set -e

      wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.tar.gz
      cd /opt
      tar -xvzf /tmp/elasticsearch-0.90.3.tar.gz
      rm -f elasticsearch
      ln -s elasticsearch-0.90.3 elasticsearch &> /dev/null
      mv elasticsearch/config elasticsearch/config-stock
    EOH
  end
end
