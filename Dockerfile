FROM docker:19.03-dind

RUN apk add curl
RUN apk add bash

RUN curl -Lo ./bin/kind "https://kind.sigs.k8s.io/dl/v0.9.0/kind-$(uname)-amd64"
RUN chmod +x ./bin/kind

RUN curl -Lo ./bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl"
RUN chmod +x ./bin/kubectl