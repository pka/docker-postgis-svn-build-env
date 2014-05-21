Ubuntu precise build of PostGIS 2.2svn
======================================


docker build -t build-postgis .

#Copy resulting deb files to /tmp
docker run -v /tmp:/pkg build-postgis sh -c 'cp /root/*postgis*.deb /pkg'


Interactive shell
-----------------

docker run -t -i build-postgis /bin/bash

cd postgis-svn

#Manual build:
./configure
make

#Debian package:
EDITOR=vi
dch -i
dpkg-buildpackage -b -uc -us
