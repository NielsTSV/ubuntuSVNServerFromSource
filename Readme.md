# SVN server from source code Docker deployment
This repo shows you how to deploy an svn server on a ubuntu image, installed from source code. This test case simulates the environment of an SVN server deployed on a Linux server. This tutorial is based on the following documentation.

First the steps will be given to install svn from source code, thereafter the docker file and other files will be explained.

## Steps Server Setup

1. Start up docker container
    - Run *`sh run_docker_server.sh`*
    - Or run lines in *`sh run_docker_server.sh`* manually
2. Install dependencies
    - dependencies are installed in DockerFile
    - apt-get update
3. Install SVN from source code
    - run /home/deployment_files/svn_source_install.sh
4. Configure apache server
    - Remove old apache-svn modules
        - `sudo rm /etc/apache2/mods-enabled/dav_svn.load`
        - `sudo rm /etc/apache2/mods-enabled/authz_svn.load`
    - Add following lines to load correct apache-svn modules, as well as expose the svn repo on http://localhost/svn/. The order is important as explained here: https://serverfault.com/questions/540873/problems-after-updating-svn-to-1-8-3-on-ubuntu-12-10-using-wandisco-package
```
LoadModule dav_module /usr/lib/apache2/modules/mod_dav.so
LoadModule dav_svn_module /usr/local/libexec/mod_dav_svn.so
LoadModule authz_svn_module /usr/local/libexec/mod_authz_svn.so
<Location /svn/repos>
    DAV svn
    SVNPath /home/svn/svnrepo
</Location> 
```
5. Create basic hello-world file in repo for testing purposes
    - `bash home/deployment_files/subversion_project_setup.sh`
6. Restart the webserver (if failure: https://stackoverflow.com/questions/21479504/service-apache2-restart-fail)
    - `etc/init.d/apache2 restart`


## Docker Image
Get a ubuntu image for amd64. Since upgrade binaries are only available for amd64, add --platform=linux/amd64 when trying to upgrade svn version on an arm64 architecture.
```
FROM --platform=linux/amd64 ubuntu:20.04 
```

Set non-interactive package installation, as some installation may user require input, halting the docker container creation.
```
ENV DEBIAN_FRONTEND noninteractive
```

Install standard Ubuntu packages
```
RUN apt-get update && \
    apt-get install -y vim && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
```

Copy in deployment files containing *dav_svn.conf* and *dav_svn.conf* (explained below).
```
COPY deployment_files /home/deployment_files
```

Install subversion dependencies and apache2 packages
```
RUN apt-get install -y --no-install-recommends libsqlite3-0 ca-certificates libserf-1-1 && \
    apt-get install -y --no-install-recommends bzip2 gcc libpcre++-dev && \
    apt-get install -y --no-install-recommends libssl-dev make libsqlite3-dev zlib1g-dev && \
    apt-get install -y --no-install-recommends libneon27-dev libserf-dev
```

Get SVN source files and unpack in src/svn, also install packages needed for installation
```
RUN wget https://archive.apache.org/dist/subversion/subversion-1.10.8.tar.bz2 && \
    mkdir -p src/svn && \
    tar -xvf subversion-1.10.8.tar.bz2 -C src/svn --strip-components=1 && \
    apt-get install -y --no-install-recommends libutf8proc-dev apache2 apache2-dev && \
    cd src/svn
```


Expose port for means of connection. Port 80 is used for regular webdav protocol (http://localhost/svn), port 3690 can be used for the custom protocol (svn://localhost:3690)
```
EXPOSE 80
```

## subversion_project_setup.sh
This script setups a basic svn repo with hello-world.py. It creates a repo in /home/svn/svnrepo, checks out a working copy in /home/workingcopy/, adds a helloworld.py to the repo and commits it. It also gives the apache user (through which you connect to the server), the permission to write to the repo.


## run/stop_docker_server.sh
These files automate the docker process (build/expose/run), as well as remove all images and container after finishing the test.

## Configuring https
now configure httpS following this tutorial: https://linuxhint.com/enable-https-apache-web-server/

create certificates
```
sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out apache.crt -keyout apache.key
```

add following to /etc/apache2/sites-enabled/000-default.conf
```
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    SSLEngine on
    SSLCertificateFile /etc/apache2/certs/apache.crt
    SSLCertificateKeyFile /etc/apache2/certs/apache.key
</VirtualHost>
```