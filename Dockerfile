# Ubuntu precise build of PostGIS 2.2svn
#
# sudo docker build -t="builder-precise" .

FROM ubuntu:12.04

MAINTAINER Pirmin Kalberer version: 0.1.5

WORKDIR /root
CMD /bin/bash

RUN apt-get -y update

#Ubuntugis PPA
RUN apt-get install -y python-software-properties
RUN add-apt-repository ppa:ubuntugis/ppa
RUN apt-get update

#PostGIS build dependencies

#RUN apt-get build-dep postgis
#The following packages have unmet dependencies:
# libgdal-dev : Depends: libpq-dev but it is not going to be installed
# postgresql-server-dev-9.1 : Depends: libpq-dev (>= 9.1~) but it is not going to be installed

#libssl headers from source tgz
#ADD http://www.openssl.org/source/openssl-1.0.1g.tar.gz /root/
#RUN cd /root && tar xzf openssl-1.0.1g.tar.gz && mv openssl-1.0.1g/include/openssl /usr/local/include/

#libssl-dev dummy package
RUN apt-get install -y equivs
ADD libssl-dev /root/
RUN equivs-build libssl-dev
#RUN dpkg -i /root/libssl-dev-dummy_1.0.1_all.deb

RUN apt-get update
RUN apt-get build-dep -y postgis

#Additional build dependencies
RUN apt-get install -y automake libtool devscripts

RUN apt-get install -y subversion

#PostGIS source checkout
RUN svn checkout http://svn.osgeo.org/postgis/trunk/ /root/postgis-svn

#Patched file
ADD lwout_gml.c /root/postgis-svn/liblwgeom/lwout_gml.c

#Debian packages sources
#http://anonscm.debian.org/gitweb/?p=pkg-grass/postgis.git
RUN mkdir /root/postgis-deb
#RUN cd /root/postgis-deb && apt-get source postgis
RUN apt-get install -y git
RUN git clone git://git.debian.org/git/pkg-grass/postgis.git /root/postgis-deb/postgis-2.0.x
RUN cd /root/postgis-deb/postgis-2.0.x && git checkout -b without_jdbc ddf0f585e
#dpkg-checkbuilddeps: Unmet build dependencies: postgresql-common (>= 148~) postgresql maven-repo-helper openjdk-8-jdk | openjdk-7-jdk                           
#RUN cd /root/postgis-deb/postgis-2.0.x && mk-build-deps -i debian/control
#RUN apt-get install -y autoconf2.13 automake1.4 autopoint dh-autoreconf libnettle4 rdfind

#Build packages
WORKDIR /root/postgis-svn
RUN sh autogen.sh; ./configure
RUN cp -r ../postgis-deb/postgis-2.0.*/debian .; mv debian/patches debian/patches-deb
#Without JDBC
#ADD control /root/postgis-svn/debian/control
ADD rules /root/postgis-svn/debian/rules
RUN dch -v 2.2.0pre-r$(svn info | grep Revision: | awk '{print $2}')~precise1 "Build for Precise of upstream 2.2.0 SVN prerelase (unpatched)"
RUN dpkg-buildpackage -b -nc -uc -us -d

WORKDIR /root
VOLUME ["/pkg"]
