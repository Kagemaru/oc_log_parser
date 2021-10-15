FROM frolvlad/alpine-glibc:latest

RUN mkdir -p /opt/app/bin
WORKDIR /opt/app

ENV PATH=/opt/app/bin:$PATH

# Install Packages
RUN    apk update \
    && apk upgrade \
    && apk add --no-cache elixir

# Get oc
RUN    wget -qO- https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz \
    |  tar xvzf - \
    && mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /opt/app/bin/oc \
    && rm -rf openshift* \
    && ls -lha /opt/app \
    && ls -lha /opt/app/bin \
    # Get sentry-cli
    && wget -qO /opt/app/bin/sentry-cli https://github.com/getsentry/sentry-cli/releases/download/1.69.1/sentry-cli-Linux-x86_64 \
    # Set permissions
    && chmod a+x /opt/app/bin/oc /opt/app/bin/sentry-cli \
    && chmod g+rwx /opt/app /root
# && mkdir -p ~/.kube \
# && touch ~/.kube/config

COPY log_parser.exs /opt/app/log_parser.exs
CMD ["elixir", "--no-halt", "/opt/app/log_parser.exs"]
