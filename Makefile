.PHONY: up down restart logs shell db-setup db-reset test clean build build-dev build-prod

COMPOSE := docker compose

CACHE_FROM ?=
CACHE_TO ?=
CACHE_FROM_FLAG := $(if $(CACHE_FROM),--cache-from=$(CACHE_FROM))
CACHE_TO_FLAG := $(if $(CACHE_TO),--cache-to=$(CACHE_TO))

build: build-dev

build-dev:
	docker buildx build --load --target dev --tag ziher/app:dev $(CACHE_FROM_FLAG) $(CACHE_TO_FLAG) .

build-prod:
	./update-version.sh
	docker buildx build --load --target prod --tag ziher/app:latest $(CACHE_FROM_FLAG) $(CACHE_TO_FLAG) .

up: build-dev
	$(COMPOSE) up --detach --wait --no-build

down:
	$(COMPOSE) down

restart: down up

logs:
	$(COMPOSE) logs --follow --tail=100

shell:
	$(COMPOSE) exec web bash

db-setup:
	$(COMPOSE) exec -T web bundle exec rails db:prepare
	$(COMPOSE) exec -T web bundle exec rails runner "Rails.application.load_seed unless User.exists?"

db-reset:
	$(COMPOSE) exec -T web bundle exec rails db:drop db:create db:migrate db:seed

test:
	$(COMPOSE) exec -T -e RAILS_ENV=test web bundle exec rails db:test:prepare
	$(COMPOSE) exec -T -e RAILS_ENV=test web bundle exec rails test

clean:
	$(COMPOSE) down --volumes --remove-orphans
