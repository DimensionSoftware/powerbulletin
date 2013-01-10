PowerBulletin
=============

Post-Modern, Realtime, FREE (as in freedom) Community

# Getting Started

1. add the following to /etc/hosts:

    127.0.0.1 pb.com www.pb.com muscache.pb.com muscache2.pb.com muscache3.pb.com muscache4.pb.com muscache5.pb.com

2. ./bin/powerbulletin
3. browse to http://www.pb.com:3000

# Vagrant Getting Started

1. install virtualbox
2. install vagrant (ruby + gems prerequisites)
3. 'vagrant up' in project dir (if you don't have the precise64 box it will be fetched)
4. vagrant ssh
5. cd /vagrant
6. grunt

# Hosts

  127.0.0.1 pb.com www.pb.com
  127.0.0.1 muscache.pb.com muscache2.pb.com muscache3.pb.com muscache4.pb.com muscache5.pb.com165.225.132.161 pbstage.com www.pbstage.com
  165.225.132.161 pbstage.com www.pbstage.com
  165.225.132.161 muscache.pbstage.com muscache2.pbstage.com muscache3.pbstage.com muscache4.pbstage.com muscache5.pbstage.com

# Mac OS X Firewall Tricks to Forward Ports 3001, 3002 to 80 and 443 respectively
  This is needed because virtualbox cannot bind to privileged ports.

  # on mac os x:
  ipfw add fwd 127.0.0.1,3001 tcp from any to me dst-port 80
  ipfw add fwd 127.0.0.1,3002 tcp from any to me dst-port 443 
