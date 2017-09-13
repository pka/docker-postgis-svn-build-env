# Ubuntu trusty build of PostGIS 2.2.x from Ubuntugis

FROM ubuntu:14.04

MAINTAINER Pirmin Kalberer version: 0.1.5

WORKDIR /root
CMD /bin/bash

# Packages for add-apt-repository
RUN apt-get update && apt-get install -y python-software-properties software-properties-common

#Ubuntugis PPA
RUN add-apt-repository --enable-source ppa:ubuntugis/ppa

#PostGIS build dependencies
RUN apt-get update && apt-get build-dep -y postgis

#Additional build dependencies
RUN apt-get install -y devscripts

#Debian packages sources
WORKDIR /root/postgis-deb
RUN apt-get source postgis

#Add patch
COPY curve-to-line-backport.patch /root/postgis-deb/
RUN cd postgis-2.2* && mv ../curve-to-line-backport.patch debian/patches/curve-to-line-backport
RUN cd postgis-2.2* && echo curve-to-line-backport >>debian/patches/series
RUN cd postgis-2.2* && dch -v 2.3.3+curve-to-line-backport "Build for Trusty with ST_CurveToLine backport"
#Build packages
#Build without tests. They need running PG server.
RUN cd postgis-2.2* && DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -b -uc -us

VOLUME ["/pkg"]
