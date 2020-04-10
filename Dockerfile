FROM ubuntu:18.04 AS build-stage

RUN apt update

# install cuda toolkit
RUN apt install -y apt-utils software-properties-common
RUN add-apt-repository -y ppa:graphics-drivers/ppa
RUN apt install -y nvidia-cuda-toolkit gcc-6

WORKDIR /build

# install go 1.13
RUN apt install -y curl gcc
RUN curl https://dl.google.com/go/go1.13.10.linux-amd64.tar.gz | tar xz
RUN mv go /usr/local/go
ENV GOPATH=/build/.go
RUN ln -s /usr/local/go/bin/* /usr/local/bin/

# download go dependencies
COPY go.mod go.sum ./
RUN go mod download

# compile
COPY pkg ./pkg
COPY cmd ./cmd
RUN go build -o /gpu-manager tkestack.io/gpu-manager/cmd/manager
RUN go build -o /gpu-client tkestack.io/gpu-manager/cmd/client

# clean
WORKDIR /
RUN rm -rf /build