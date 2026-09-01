BINARY := tellgrader

build:
	go build -o $(BINARY) ./cmd/tellgrader

test:
	go test ./...

vet:
	go vet ./...

lint:
	golangci-lint run ./...

install:
	go install ./cmd/tellgrader

check: vet lint test

clean:
	rm -f $(BINARY)

.PHONY: build test vet lint install check clean
