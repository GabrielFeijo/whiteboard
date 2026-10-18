.PHONY: env up down deps logs ps reset config check check-quick test typecheck lint format sync-shared sync-shared-check gen-api

env:
	@test -f .env || cp .env.example .env

up: env
	docker compose up -d --build

down:
	docker compose down

deps: env
	docker compose -f docker-compose.deps.yml up -d

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps

config: env
	docker compose config -q

reset:
	docker compose down -v

sync-shared:
	@npm --prefix frontend run sync:shared

sync-shared-check:
	@npm --prefix frontend run sync:shared:check

gen-api:
	@npm --prefix frontend run gen:api

typecheck:
	@npm --prefix backend run typecheck
	@npm --prefix frontend run typecheck

lint:
	@npm --prefix backend run lint
	@npm --prefix frontend run lint

test:
	@npm --prefix backend run test
	@npm --prefix frontend run test

format:
	@npm --prefix backend run format
	@npm --prefix frontend run format

check: sync-shared-check typecheck lint test

check-quick: sync-shared-check typecheck test
