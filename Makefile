REGISTRY ?= quay.io
NAMESPACE ?= fedora-oci
BASE_IMAGE ?= quay.io/fedora-ostree-desktops/kinoite
BASE_VERSION ?= 44

.PHONY: all nvidia amd clean

all: nvidia amd

nvidia:
	podman build \
		--build-arg VARIANT=nvidia \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BASE_VERSION=$(BASE_VERSION) \
		-t $(REGISTRY)/$(NAMESPACE)/nvidia:latest .

amd:
	podman build \
		--build-arg VARIANT=amd \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BASE_VERSION=$(BASE_VERSION) \
		-t $(REGISTRY)/$(NAMESPACE)/amd:latest .

clean:
	podman rmi -f $(REGISTRY)/$(NAMESPACE)/nvidia:latest 2>/dev/null || true
	podman rmi -f $(REGISTRY)/$(NAMESPACE)/amd:latest 2>/dev/null || true
