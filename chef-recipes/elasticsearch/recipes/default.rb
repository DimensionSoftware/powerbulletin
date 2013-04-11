#unless File.file? '/usr/local/jars/jackson-core-2.1.1.jar'
  package 'openjdk-7-jdk'

  bash "installing elasticsearch" do
    cwd 'tmp'
    code <<-EOH
      set -e

      wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.6.tar.gz
      cd /opt
      tar -xvzf /tmp/elasticsearch-0.20.6.tar.gz
      ln -s elasticsearch-0.20.6 elasticsearch
    EOH
  end
#end
