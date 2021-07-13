FROM curlimages/curl:latest AS curl
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /tmp/kubectl && \
  chmod +x /tmp/kubectl

FROM hashicorp/consul-template:0.26.0
COPY --from=curl /tmp/kubectl /usr/local/bin/kubectl
