.PHONY: build publish

all: help
help:
	@echo "make build ......... build yankelscialom/ssmtp image"
#	@echo "make publish ....... publish yankelscialom/ssmtp image to dockerhub"

build:
	@sed '1s/^/var schema = /' <../../src/utils/settings-validator/schema.json >www/schema.js
	docker build -t "yankelscialom/pinanas-settings-editor:$(shell git describe)" .
	docker tag "yankelscialom/pinanas-settings-editor:$(shell git describe)" yankelscialom/pinanas-settings-editor:latest
	@rm www/schema.js

#publish:
#	docker push "yankelscialom/ssmtp:$(shell git describe)"
#	docker push yankelscialom/ssmtp:latest
