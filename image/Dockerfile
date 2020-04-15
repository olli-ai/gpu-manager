FROM ubuntu:18.04

ARG nvidiav=418

RUN apt update
RUN apt install -y build-essential

# install gcsfuse
RUN apt install -y curl
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-bionic main" > /etc/apt/sources.list.d/gcsfuse.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt update
RUN apt install -y gcsfuse

# install cuda toolkit
RUN apt install -y apt-utils software-properties-common
RUN add-apt-repository -y ppa:graphics-drivers/ppa
# RUN apt install -y gcc-6 nvidia-cuda-toolkit libnvidia-compute-418 nvidia-utils-418 nvidia-compute-utils-418
RUN apt install -y gcc-6 nvidia-cuda-toolkit libnvidia-compute-${nvidiav} nvidia-utils-${nvidiav} nvidia-compute-utils-${nvidiav}

COPY start.sh /usr/local/bin/start
CMD ["start"]
