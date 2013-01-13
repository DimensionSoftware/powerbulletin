unless File.directory? '/usr/local/clojure-1.4.0'
  package 'openjdk-7-jdk'
  package 'unzip'

  bash 'installing clojure' do
    cwd 'tmp'
    code <<-EOH
      set -e

      wget http://repo1.maven.org/maven2/org/clojure/clojure/1.4.0/clojure-1.4.0.zip
      cd /usr/local
      unzip /tmp/clojure-1.4.0.zip
      chmod a+r clojure-1.4.0 -R
      rm -rf clojure
      ln -s clojure-1.4.0 clojure
    EOH
  end
end
