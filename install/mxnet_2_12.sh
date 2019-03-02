#!/bin/sh


MXNET_VERSION=${1}


MXNET_BUILD_OPT=${2}


CUDA_STUBS_DIR=${3}
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CUDA_STUBS_DIR}"


apt-get install -y git build-essential libopenblas-dev libopencv-dev maven cmake && \
   git clone -b ${MXNET_VERSION} --recursive https://github.com/dmlc/mxnet /tmp/mxnet && \
   cd /tmp/mxnet && \
   make -j $(nproc) ${MXNET_BUILD_OPT} && \
   ln -s ${CUDA_STUBS_DIR}/libcuda.so ${CUDA_STUBS_DIR}/libcuda.so.1 && \
   sed -rim 's/([a-zA-Z])_2.11/\1_2.12/g' $(find scala-package -name pom.xml) && \
   sed -im 's/SCALA_VERSION_PROFILE := scala-2.11/SCALA_VERSION_PROFILE := scala-2.12/g' Makefile && \
   sed -im 's/<module>spark<\/module>/<\!--<module>spark<\/module>-->/g' scala-package/pom.xml && \
   make scalapkg ${MXNET_BUILD_OPT} && \
   mkdir -p /usr/local/share/mxnet/scala/linux-x86_64-gpu && \
   mv /tmp/mxnet/scala-package/assembly/linux-x86_64-gpu/target/mxnet-full_2.12-linux-x86_64-gpu-${MXNET_VERSION}-SNAPSHOT.jar /usr/local/share/mxnet/scala/linux-x86_64-gpu/mxnet-full_2.12-linux-x86_64-gpu-${MXNET_VERSION}-SNAPSHOT.jar && \
   rm -rf /tmp/mxnet && rm -rf /root/.m2