.PHONY: env up down deps logs ps reset config

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
