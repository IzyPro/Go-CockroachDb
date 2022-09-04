# Base image 
FROM golang:1.14-alpine AS build

# Runs updates and installs git
RUN apk update && apk upgrade && \
    apk add --no-cache git

# Switches working directory to /tmp/app as the 
WORKDIR /tmp/app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

# Builds the current project to a binary file called api
# The location of the binary file is /tmp/app/out/api
RUN go build -o ./out/api .

#-------------------------------------------------------------

# The project has been successfully built and we will use a
# lightweight alpine image to run the server 
FROM alpine:latest

# Adds CA Certificates to the image
RUN apk add ca-certificates

# Copies the binary file from the BUILD container to /app folder
COPY --from=build /tmp/app/out/api /app/api

# Switches working directory to /app
WORKDIR "/app"

# Exposes the port from the container
EXPOSE 8082

# Runs the binary once the container starts
CMD ["./api"]