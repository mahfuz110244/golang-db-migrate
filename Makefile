.PHONY: migrate migrate_down migrate_up migrate_version docker prod docker_delve local swaggo test

# ==============================================================================
# Go migrate postgresql

force:
	migrate -database postgres://postgres:postgres@localhost:5432/example?sslmode=disable -path db/migrations force 1

version:
	migrate -database postgres://postgres:postgres@localhost:5432/example?sslmode=disable -path db/migrations version

migrate_up:
	migrate -database postgres://postgres:postgres@localhost:5432/example?sslmode=disable -path db/migrations up

migrate_down:
	migrate -database postgres://postgres:postgres@localhost:5432/example?sslmode=disable -path db/migrations down


# ==============================================================================
# Docker compose commands

develop:
	echo "Starting docker environment"
	docker-compose -f docker-compose.dev.yml up --build

docker_delve:
	echo "Starting docker debug environment"
	docker-compose -f docker-compose.delve.yml up --build

prod:
	echo "Starting docker prod environment"
	docker-compose -f docker-compose.prod.yml up --build

local:
	echo "Starting local environment"
	docker-compose -f docker-compose.local.yml up --build


# ==============================================================================
# Tools commands

run-linter:
	echo "Starting linters"
	golangci-lint run ./...

swaggo:
	echo "Starting swagger generating"
	swag init -g **/**/*.go

# ==============================================================================
# Tools commands

build-mocks:
	@go get github.com/golang/mock/gomock
	@go install github.com/golang/mock/mockgen@v1.6.0
	@~/go/bin/mockgen -source=internal/status/usecase.go -destination=internal/status/mock/usecase_mock.go -package=mock
	@~/go/bin/mockgen -source=internal/status/pg_repository.go -destination=internal/status/mock/pg_repository_mock.go -package=mock
	@~/go/bin/mockgen -source=internal/status/redis_repository.go -destination=internal/status/mock/redis_repository_mock.go -package=mock
# Main

run:
	go build ./cmd/api/main.go
	go run ./cmd/api/main.go

build:
	go build ./cmd/api/main.go

test:
	go test -cover ./...


# ==============================================================================
# Modules support

deps-reset:
	git checkout -- go.mod
	go mod tidy
	go mod vendor

tidy:
	go mod tidy
	go mod vendor

deps-upgrade:
	# go get $(go list -f '{{if not (or .Main .Indirect)}}{{.Path}}{{end}}' -m all)
	go get -u -t -d -v ./...
	go mod tidy
	go mod vendor

deps-cleancache:
	go clean -modcache


# ==============================================================================
# Docker support

FILES := $(shell docker ps -aq)

down-local:
	docker stop $(FILES)
	docker rm $(FILES)

clean:
	docker system prune -f

logs-local:
	docker logs -f $(FILES)