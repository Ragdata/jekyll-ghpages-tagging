FROM bash:alpine3.20

# install git
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
