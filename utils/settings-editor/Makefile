.PHONY: build publish run

all: help
help:
	@echo "make build ......... build yankelscialom/pinanas-settings-editor image"
#	@echo "make publish ....... publish yankelscialom/pinanas-settings-editor image to dockerhub"
	@echo "make run ............ run yankelscialom/pinanas-settings-editor on http://localhost:80"
	@echo "make stop ........... stops yankelscialom/pinanas-settings-editor"

build:
	@sed '1s/^/var schema = /' <../../src/utils/settings-validator/schema.json >www/schema.js
	docker build -t "yankelscialom/pinanas-settings-editor:$(shell git describe --tags)" .
	docker tag "yankelscialom/pinanas-settings-editor:$(shell git describe --tags)" yankelscialom/pinanas-settings-editor:latest
	@rm www/schema.js

#publish: build
#	docker push "yankelscialom/pinanas-settings-editor:$(shell git describe)"
#	docker push yankelscialom/pinanas-settings-editor:latest

run: build
	docker run -d --name pinanas-settings-editor --rm -p 80:80 yankelscialom/pinanas-settings-editor

stop:
	docker stop pinanas-settings-editor
