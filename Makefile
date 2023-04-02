.PHONY: clean
clean:
	@docker compose --project-directory docker/ --project-name ziher down

.PHONY: stop
stop:
	@docker compose --project-directory docker/ --project-name ziher stop

.PHONY: pull
pull:
	@docker compose --project-directory docker/ --project-name ziher pull

.PHONY: reset
reset: clean pull setup-db

.PHONY: restart
restart: stop run

.PHONY: setup-db
setup-db: run-db run-dev-shell run-db-create-migrate-seed stop-dev-shell stop-db

.PHONY: run-db-create-migrate-seed
run-db-create-migrate-seed:
	@./docker/recreate-db.sh
	@docker compose --project-directory docker/ exec ziher-dev-shell rake db:migrate
	@docker compose --project-directory docker/ exec ziher-dev-shell rake db:seed

.PHONY: run-db
run-db:
	@docker compose --project-directory docker/ up postgres --detach --force-recreate

.PHONY: stop-db
stop-db:
	@docker compose --project-directory docker/ stop postgres

.PHONY: run
run: run-db
	@docker compose --project-directory docker/ up ziher-dev --detach --force-recreate

.PHONY: run-dev-shell
run-dev-shell: run-db
	@docker compose --project-directory docker/ up ziher-dev-shell --detach --force-recreate

.PHONY: stop-dev-shell
stop-dev-shell:
	@docker compose --project-directory docker/ stop ziher-dev-shell
