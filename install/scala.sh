#!/bin/sh


SCALA_VERSION=${1}
SCALA_DEB="http://www.scala-lang.org/files/archive/scala-${SCALA_VERSION}.deb"


apt-get install -y wget && \
   wget -q ${SCALA_DEB} -O /tmp/scala.deb && dpkg -i /tmp/scala.deb && \
   scala -version && \
   rm /tmp/scala.deb