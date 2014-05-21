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
RUN dpkg -i /root/libssl-dev-dummy_1.0.1_all.deb

RUN apt-get build-dep -y postgis

#Additional build dependencies
RUN apt-get install -y automake libtool devscripts

RUN apt-get install -y subversion

#PostGIS source checkout
RUN svn checkout http://svn.osgeo.org/postgis/trunk/ /root/postgis-svn

#Debian packages sources
RUN mkdir /root/postgis-deb; cd /root/postgis-deb && apt-get source postgis

#Build packages
WORKDIR /root/postgis-svn
RUN sh autogen.sh; ./configure
RUN cp -r ../postgis-deb/postgis-2.0.1/debian .; mv debian/patches debian/patches-deb
RUN dch -v 2.2.0pre-r$(svn info | grep Revision: | awk '{print $2}')~precise1 "Build for Precise of upstream 2.2.0 SVN prerelase (unpatched)"
RUN dpkg-buildpackage -b -uc -us

WORKDIR /root
VOLUME ["/pkg"]
