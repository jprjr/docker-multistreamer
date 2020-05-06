.PHONY: all

VERSION = 11.3.4
MANIFEST_TOOL_VER=1.0.2
YQ_VER=1.14.0
PLATFORM = $(shell uname -s | tr '[A-Z]' '[a-z]')

all:
	@printf 'Please run `make VERSION=whatever (target)`\n'
	@printf "Available targets:\n"
	@printf "  setup (grabs manifest-tool, yq)\n"
	@printf "  images (builds and pushes docker images)\n"

clean:
	rm -rf tools

setup: tools/manifest-tool tools/yq

images: docker-images docker-compose.yml

gpg-key: tools/.gpg-imported

tools/.gpg-imported: | tools
	gpg --list-keys 0F386284C03A1162 >/dev/null 2>&1 || gpg --recv-keys 0F386284C03A1162
	touch $@

tools/manifest-tool: tools/manifest-tool-$(MANIFEST_TOOL_VER)
	rm -f tools/manifest-tool
	ln -s manifest-tool-$(MANIFEST_TOOL_VER) $@

tools/yq: tools/yq-$(YQ_VER)
	rm -f tools/yq
	ln -s yq-$(YQ_VER) $@

tools/yq-$(YQ_VER):
	curl -R -L -o tools/yq-$(YQ_VER) "https://github.com/mikefarah/yq/releases/download/$(YQ_VER)/yq_$(PLATFORM)_amd64"
	chmod +x tools/yq-$(YQ_VER)

tools/manifest-tool-$(MANIFEST_TOOL_VER): | tools/.gpg-imported
	mkdir -p manifest-tool.tmp
	cd manifest-tool.tmp && curl -R -L -O "https://github.com/estesp/manifest-tool/releases/download/v$(MANIFEST_TOOL_VER)/manifest-tool-$(PLATFORM)-amd64"
	cd manifest-tool.tmp && curl -R -L -O "https://github.com/estesp/manifest-tool/releases/download/v$(MANIFEST_TOOL_VER)/manifest-tool-$(PLATFORM)-amd64.asc"
	cd manifest-tool.tmp && gpg --verify manifest-tool-$(PLATFORM)-amd64.asc
	mv manifest-tool.tmp/manifest-tool-$(PLATFORM)-amd64 tools/manifest-tool-$(MANIFEST_TOOL_VER)
	chmod +x tools/manifest-tool-$(MANIFEST_TOOL_VER)
	rm -rf manifest-tool.tmp

tools:
	mkdir -p tools

manifest.yml: FORCE
	sed "s/@@VERSION@@/$(VERSION)/" templates/$@ > $@

Dockerfile: FORCE
	sed "s/@@VERSION@@/$(VERSION)/" templates/$@ > $@

Dockerfile-armv6: FORCE
	sed "s/@@VERSION@@/$(VERSION)/" templates/$@ > $@

docker-compose.yml: FORCE
	sed "s/@@VERSION@@/$(VERSION)/" templates/$@ > $@

docker-images: tools/yq tools/manifest-tool docker-image-amd64 docker-image-armv6
	./tools/manifest-tool push from-spec manifest.yml

docker-image-amd64: Dockerfile manifest.yml
	docker build --pull -t $(shell ./tools/yq read manifest.yml manifests[0].image) -f Dockerfile .
	docker push $(shell ./tools/yq read manifest.yml manifests[0].image)

docker-image-armv6: Dockerfile-armv6 manifest.yml
	docker build --pull -t $(shell ./tools/yq read manifest.yml manifests[1].image) -f Dockerfile-armv6 .
	docker push $(shell ./tools/yq read manifest.yml manifests[1].image)

FORCE:
