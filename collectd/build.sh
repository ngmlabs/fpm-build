#!/bin/bash


NAME=collectd
VERSION=5.4.1

TOPDIR=`dirname $( readlink -f $0 )`
BUILDDIR=${TOPDIR}/build
PREPAREDIR=${BUILDDIR}/prepare
FPM=/var/lib/gems/1.8/bin/fpm


# clean buildroot
[ -n "${BUILDDIR}" -a "${BUILDDIR}" != / ] && rm -rf ${BUILDDIR}
mkdir -p ${BUILDDIR} ${PREPAREDIR}


# build collectd
pushd ${BUILDDIR}
wget http://collectd.org/files/${NAME}-${VERSION}.tar.gz
tar xvzf ${NAME}-${VERSION}.tar.gz

cd ${NAME}-${VERSION}
./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc && make -j && make install DESTDIR=${PREPAREDIR}
popd


# install init script
install -D -m0775 ${TOPDIR}/collectd-init ${PREPAREDIR}/etc/init.d/collectd
install -D -m0644 ${TOPDIR}/collectd-default ${PREPAREDIR}/etc/default/collectd


# remove unnecessary files and strip binaries
rm -rf ${PREPAREDIR}/usr/man ${PREPAREDIR}/usr/include
find ${PREPAREDIR} -name '*.la' -or -name '*.a' | xargs rm -f
strip ${PREPAREDIR}/usr/sbin/* ${PREPAREDIR}/usr/bin/* ${PREPAREDIR}/usr/lib/collectd/*


# create package
${FPM} -s dir -t deb -f -n ${NAME} -v ${VERSION} -a amd64 -C ${PREPAREDIR} ./etc ./usr ./var
