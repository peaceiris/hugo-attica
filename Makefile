include .env

pwd := $(CURDIR)
cmd := ""
DOCKER_COMPOSE := docker-compose
GH_USER_ID := peaceiris


.PHONY: up
up:
	$(DOCKER_COMPOSE) up -d
	$(DOCKER_COMPOSE) exec hugo hugo \
		server --navigateToChanged --bind=0.0.0.0 --buildDrafts --i18n-warnings

.PHONY: npm-up
npm-up:
	cd ./exampleSite && \
	hugo server --navigateToChanged --buildDrafts --i18n-warnings

.PHONY: hugo
hugo:
	# make hugo cmd="version"
	$(DOCKER_COMPOSE) run --rm --entrypoint=hugo hugo $(cmd)

.PHONY: bumphugo
bumphugo:
	bash ./scripts/bump_hugo.sh

.PHONY: build
build:
	$(eval opt := --minify --cleanDestinationDir)
	$(DOCKER_COMPOSE) run --rm --entrypoint=hugo hugo $(opt)

.PHONY: npm-build
npm-build:
	cd ./exampleSite && \
	hugo --minify --cleanDestinationDir

.PHONY: test
test:
	$(eval opt := --minify \
		--renderToMemory --i18n-warnings --path-warnings --debug)
	$(DOCKER_COMPOSE) run --rm --entrypoint=hugo hugo $(opt)

.PHONY: npm-test
npm-test:
	cd ./exampleSite && \
	hugo --minify \
		--renderToMemory --i18n-warnings --path-warnings --debug

.PHONY: metrics
metrics:
	$(eval opt := --minify \
		--renderToMemory --i18n-warnings --path-warnings --debug \
		--templateMetrics --templateMetricsHints)
	$(DOCKER_COMPOSE) run --rm --entrypoint=hugo hugo $(opt)

.PHONY: cibuild
cibuild:
	cd ./exampleSite && \
		hugo --minify --cleanDestinationDir \
			--environment "staging" \
			--i18n-warnings --path-warnings --debug \
			--templateMetrics --templateMetricsHints

.PHONY: cibuild-prod
cibuild-prod:
	cd ./exampleSite && \
		hugo --minify --cleanDestinationDir \
			--i18n-warnings --path-warnings && \
		wget -O ./public/report.html ${BASE_URL}/report.html || true

.PHONY: fetchdata
fetchdata:
	cd ./exampleSite && \
		bash ./scripts/fetch_data.sh ${GH_USER_ID} > ./data/github/${GH_USER_ID}.json && \
		deno run --allow-net --allow-read --allow-write --unstable scripts/fetch_images.ts
