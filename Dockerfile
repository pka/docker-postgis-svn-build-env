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
RUN apt-get install -y devscripts quilt

#Debian packages sources
WORKDIR /root/postgis-deb
RUN apt-get source postgis

#Add patch
COPY *.patch /root/postgis-deb/
RUN cd postgis-2.2* && mv ../*.patch debian/patches/
RUN cd postgis-2.2* && quilt pop -a
RUN cd postgis-2.2* && echo liblwgeom-2.2-5.symbols.patch\\ncurve-to-line-backport.patch\\nchangeset_16553.patch\\nlink-liblwgeom\\nrelax-test-timing-constraints.patch >debian/patches/series
RUN cd postgis-2.2* && quilt push -a -f || true
RUN cd postgis-2.2* && dch -v 2.2.6+curve-to-line-backport2 "Build for Trusty with ST_CurveToLine backport"
RUN mv postgis-2.2.2+dfsg postgis-2.2.6+curve-to-line-backport2
#Build packages
#Build without tests. They need running PG server.
RUN cd postgis-2.2* && DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -b -uc -us

VOLUME ["/pkg"]
