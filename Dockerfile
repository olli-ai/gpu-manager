FROM ubuntu:18.04 AS builder

RUN apt update && apt install -y curl build-essential apt-utils software-properties-common

# install cuda toolkit
RUN add-apt-repository -y ppa:graphics-drivers/ppa && apt install -y nvidia-cuda-toolkit

WORKDIR /build

# install go 1.13
RUN curl https://dl.google.com/go/go1.13.10.linux-amd64.tar.gz | tar xz
ENV GOROOT=/build/go/ GOPATH=/build/go/ PATH="/build/go/bin:${PATH}"

WORKDIR /build/vcuda-controller

# install libcuda-controller.so
COPY vcuda-controller/include include
COPY vcuda-controller/src src
COPY vcuda-controller/tools tools
COPY vcuda-controller/Makefile ./
RUN make build

WORKDIR /build/gpu-manager

# download go dependencies
COPY go.mod go.sum ./
RUN go mod download

# compile
COPY pkg ./pkg
COPY cmd ./cmd
RUN go build -gcflags=all="-N -l" -o gpu-manager tkestack.io/gpu-manager/cmd/manager
RUN go build -o gpu-client tkestack.io/gpu-manager/cmd/client

RUN echo "/usr/local/nvidia/lib64" > /etc/ld.so.conf.d/nvidia.conf
ENV PATH="/usr/local/nvidia/bin:${PATH}"

COPY /build/vcuda-controller/libcuda-control.so \
	/usr/local/lib/
COPY /build/vcuda-controller/nvml-monitor \
	/build/gpu-manager/gpu-manager \
	/build/gpu-manager/gpu-client \
	/usr/local/bin/
