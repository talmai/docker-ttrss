DOCKER_IMAGE_VERSION=1.0
DOCKER_IMAGE_NAME=talmai/docker-ttrss
DOCKER_IMAGE_TAGNAME=$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

default: build

build: 
	docker build -t $(DOCKER_IMAGE_TAGNAME) .
	docker tag $(DOCKER_IMAGE_TAGNAME) $(DOCKER_IMAGE_NAME):latest

push: build
	docker push $(DOCKER_IMAGE_TAGNAME)
	docker push $(DOCKER_IMAGE_NAME):latest
	
test:
	# docker run --rm $(DOCKER_IMAGE_TAGNAME) /bin/echo "Success."
	## run test container
	#docker run -it talmai/test
	##docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -e ENV_1=xxx -e ENV_2=xxx talmai/docker-ttrss
	#docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e ENV_1=xxx -e ENV_2=xxx talmai/docker-ttrss
	##docker ps -a | grep Exited | cut -d ' ' -f 1 | xargs docker rm
	##docker rmi $(docker images --quiet --filter "dangling=true")

rmi:
	docker rmi -f $(DOCKER_IMAGE_TAGNAME)

rebuild: clean rmi build
