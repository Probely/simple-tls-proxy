INSTALL_PATH=/etc/tls-proxy

all: docker

docker:
	docker build -f docker/nginx/Dockerfile -t probely/nginx docker/nginx
	docker build -f docker/tls-controller/Dockerfile -t probely/tls-controller docker/tls-controller

docker-push: docker
	docker push probely/nginx:latest
	docker push probely/tls-controller:latest

install:
	mkdir -p $(INSTALL_PATH)
	chmod 0700 $(INSTALL_PATH)
	grep ^export deployments/stand-alone/*.env | cut -d ' ' -f 2- > $(INSTALL_PATH)/system.env
	cp deployments/stand-alone/docker-compose.yml $(INSTALL_PATH)/
	cp systemd/* /etc/systemd/system
	systemctl enable tls-proxy tls-proxy-controller.timer
	systemctl start tls-proxy tls-proxy-controller.timer

uninstall:
	systemctl disable tls-proxy tls-proxy-controller.timer 2>/dev/null|| true
	systemctl stop tls-proxy tls-proxy-controller.timer 2>/dev/null|| true
	pushd $(INSTALL_PATH) 2>/dev/null|| true
	docker-compose down 2>/dev/null|| true
	popd 2>/dev/null|| true
	rm /etc/systemd/system/tls-proxy* 2>/dev/null || true
	rm -rf $(INSTALL_PATH)

.PHONY: all docker install uninstall docker-push
