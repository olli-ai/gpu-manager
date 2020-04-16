FROM ubuntu:18.04 AS builder

RUN apt update

# install cuda toolkit
RUN apt install -y apt-utils software-properties-common
RUN add-apt-repository -y ppa:graphics-drivers/ppa
RUN apt install -y nvidia-cuda-toolkit

WORKDIR /build/go

# install go 1.13
RUN apt install -y curl build-essential
RUN curl https://dl.google.com/go/go1.13.10.linux-amd64.tar.gz | tar xz
RUN mv go /usr/local/go
ENV GOPATH=/build/go/.go
RUN ln -s /usr/local/go/bin/* /usr/local/bin/

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
RUN go build -o gpu-manager tkestack.io/gpu-manager/cmd/manager
RUN go build -o gpu-client tkestack.io/gpu-manager/cmd/client

FROM ubuntu:18.04

# get ready to mount /usr/local/nvidia
RUN echo "/usr/local/nvidia/lib64" > /etc/ld.so.conf.d/nvidia.conf
ENV PATH="/usr/local/nvidia/bin:${PATH}"

# copy libraries and binaries binaries
COPY --from=builder \
	/build/vcuda-controller/libcuda-control.so \
	/usr/local/lib
COPY --from=builder \
	/build/vcuda-controller/nvml-monitor \
	/build/gpu-manager/gpu-manager \
	/build/gpu-manager/gpu-client \
	/usr/local/bin/
