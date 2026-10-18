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

# ==============================================================================
# Verificação e Desenvolvimento Agêntico
# ==============================================================================

sync-shared:
	@npm --prefix frontend run sync:shared

sync-shared-check:
	@npm --prefix frontend run sync:shared:check

gen-api:
	@npm --prefix frontend run gen:api

typecheck:
	@echo "==> Verificando tipos no backend..."
	@npm --prefix backend run typecheck
	@echo "==> Verificando tipos no frontend..."
	@npm --prefix frontend run typecheck

lint:
	@echo "==> Executando linter no backend..."
	@npm --prefix backend run lint
	@echo "==> Executando linter no frontend..."
	@npm --prefix frontend run lint

test:
	@echo "==> Executando testes unitários e de contrato no backend..."
	@npm --prefix backend run test
	@echo "==> Executando testes unitários e de contrato no frontend..."
	@npm --prefix frontend run test

format:
	@npm --prefix backend run format
	@npm --prefix frontend run format

check: sync-shared-check typecheck lint test
	@echo "\n✅ Todas as verificações de integridade, tipos, linters e testes passaram com sucesso!"

check-quick: sync-shared-check typecheck test
	@echo "\n✅ Verificação rápida (tipos, testes e contratos) passou com sucesso!"
