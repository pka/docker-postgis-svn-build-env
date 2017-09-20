Ubuntu trusty build of PostGIS 2.2.x with ST_CurveToLine backport
=================================================================

ST_CurveToLine
--------------

Create patch from https://github.com/strk/postgis/tree/svn-2.2-curve-to-line-extended:

	git diff f37bb5d >curve-to-line-backport.patch

Usage
-----

	docker build -t build-postgis .

	#Copy resulting deb files to /tmp
	docker run -v /tmp:/pkg build-postgis sh -c 'cp /root/postgis-deb/*.deb /pkg'


Interactive shell
-----------------

	docker run -t -i build-postgis

	cd postgis-svn

	#Manual build:
	./configure
	make

	#Debian package:
	EDITOR=vi
	dch -i
	dpkg-buildpackage -b -uc -us
