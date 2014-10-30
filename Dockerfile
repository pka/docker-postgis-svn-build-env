# Ubuntu trusty build of PostGIS 2.1.x with added GML curve support

FROM ubuntu:14.04

MAINTAINER Pirmin Kalberer version: 0.1.5

WORKDIR /root
CMD /bin/bash

# Packages for add-apt-repository
RUN apt-get update && apt-get install -y python-software-properties software-properties-common

#Ubuntugis PPA
#RUN add-apt-repository ppa:ubuntugis/ppa

#PostGIS build dependencies
RUN apt-get build-dep -y postgis

#Additional build dependencies
RUN apt-get install -y devscripts

#Debian packages sources
WORKDIR /root/postgis-deb
RUN apt-get source postgis

#Add patch
COPY gml-curves /root/postgis-deb/
RUN cd postgis-2.1* && mv ../gml-curves debian/patches/
RUN cd postgis-2.1* && echo gml-curves >>debian/patches/series
RUN cd postgis-2.1* && dch -v 2.1.x+gmlcurves "Build for Trusty with gml curve support patches"

#Build packages
#Build without tests. They need running PG server.
RUN cd postgis-2.1* && DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -b -uc -us

VOLUME ["/pkg"]
