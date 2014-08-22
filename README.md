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
    # This is needed because virtualbox cannot bind to privileged ports.
    # on mac os x:
    ipfw add 1 fwd 127.0.0.1,3001 tcp from any to me dst-port 80
    ipfw add 1 fwd 127.0.0.1,3002 tcp from any to me dst-port 443 

    # if you would like to run without invoking the caching / layer (also disabling forced ssl + security headers)
    ipfw flush
    ipfw add fwd 127.0.0.1,3000 tcp from any to me dst-port 80

# IDEA: let people upvote or downvote moderation decisions

# varnish how to watch health (and see backend health status)
    # continuous watching of just first backend
    watch 'varnishadm debug.health | head -n 9'

    # one-shot health dump + all backends status
    varnishadm debug.health

# Notes on how to rebuild postgresql with en_US.UTF8 locale forced :\
    sudo service postgres stop
    sudo su - postgres
    rm -rf /var/lib/postgresql/9.2/main/*
    /usr/lib/postgresql/9.2/bin/initdb --locale=en_US.utf8 --encoding=UTF8 /var/lib/postgresql/9.2/main
    exit
    sudo service postgres start
# Crontab for remote backups
    7 *  *   *   *     cd /pb; time bin/remote-backup >> /pb/backup.log 2>&1
