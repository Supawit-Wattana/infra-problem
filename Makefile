BUILD_DIR=build
APPS=front-end quotes newsfeed
LIBS=common-utils
STATIC_BASE=front-end/public
STATIC_PATHS=css
STATIC_ARCHIVE=$(BUILD_DIR)/static.tgz
INSTALL_TARGETS=$(addsuffix .install, $(LIBS))
APP_JARS=$(addprefix $(BUILD_DIR)/, $(addsuffix .jar, $(APPS)))

all: $(BUILD_DIR) $(APP_JARS) $(STATIC_ARCHIVE)

libs: $(INSTALL_TARGETS)

static: $(STATIC_ARCHIVE)

%.install:
	cd $* && lein install

test: $(addsuffix .test, $(LIBS) $(APPS))

%.test:
	cd $* && lein midje

clean:
	rm -rf $(BUILD_DIR) $(addsuffix /target, $(APPS))

$(APP_JARS): | $(BUILD_DIR)
	cd $(notdir $(@:.jar=)) && lein uberjar && cp target/uberjar/*-standalone.jar ../$@

$(STATIC_ARCHIVE): | $(BUILD_DIR)
	tar -c -C $(STATIC_BASE) -z -f $(STATIC_ARCHIVE) $(STATIC_PATHS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)


# ---------------------------------------------- DEPLOYMENT OPTION 1 -----------------------------------------------

build-ms: $(addsuffix .build-ms, $(APPS)) build-static

%.build-ms:
	docker build -f Dockerfile.ms --build-arg APP_DIR=$* -t service/$* .

build-static:
	docker build -f Dockerfile.static -t service/static .

deploy-ms:
	docker compose -f dc-option-1.yml up -d

deploy-1: build-ms deploy-ms

check-1:
	docker compose -f dc-option-1.yml ps

clean-1:
	docker compose -f dc-option-1.yml down && docker system prune -f -a

# ---------------------------------------------- DEPLOYMENT OPTION 2 -----------------------------------------------

deploy-ms-nginx:
	docker compose -f dc-option-2.yml up -d

deploy-2: build-ms deploy-ms-nginx

check-2:
	docker compose -f dc-option-2.yml ps

clean-2:
	docker compose -f dc-option-2.yml down && docker system prune -f -a

# ---------------------------------------------- DEPLOYMENT OPTION 3 -----------------------------------------------

deploy-ms-nginx-nossl:
	docker compose -f dc-option-3.yml up -d

deploy-3: build-ms deploy-ms-nginx-nossl

check-3:
	docker compose -f dc-option-3.yml ps

clean-3:
	docker compose -f dc-option-3.yml down

# ---------------------------------------------- DEPLOYMENT OPTION 4 -----------------------------------------------

build: $(addsuffix .build, $(APPS)) build-static

%.build:
	docker build --build-arg APP_DIR=$* -t service/$* .

deploy-4: build deploy-ms

check-4:
	docker compose -f dc-option-1.yml ps

clean-4:
	docker compose -f dc-option-1.yml down && docker system prune -f -a


