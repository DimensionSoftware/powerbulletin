unless File.file? '/usr/local/jars/jackson-core-2.1.1.jar'
  package 'openjdk-7-jdk'

  bash "installing jackson (java json processing library)" do
    cwd 'tmp'
    code <<-EOH
      set -e

      mkdir -p /usr/local/jars
      cd /usr/local/jars
      wget http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.1.1/jackson-core-2.1.1.jar
      wget http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.1.1/jackson-databind-2.1.1.jar
      wget http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.1.1/jackson-annotations-2.1.1.jar
    EOH
  end
end
