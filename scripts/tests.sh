#!/bin/bash

go fmt ${gocode} #Format code
go vet #reports suspicious constructs
goapp test
go test -cover #check code coverage
go test -cover -coverprofile=c.out #html coverage report
go tool cover -html=c.out -o coverage.html
