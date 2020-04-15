
.PHONY: build
build:
	docker built . -t ubuntu:18.04-cuda-gcsfuse

.PHONY: push
push: build
	docker tag ubuntu:18.04-cuda-gcsfuse asia.gcr.io/olli-iviet/ubuntu:18.04-cuda-gcsfuse
	docker push asia.gcr.io/olli-iviet/ubuntu:18.04-cuda-gcsfuse