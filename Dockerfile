FROM frolvlad/alpine-glibc:latest

RUN mkdir -p /opt/app
WORKDIR /opt/app

COPY oc /opt/app/bin/oc
COPY sentry-cli /opt/app/bin/sentry-cli
COPY log_parser.exs /opt/app/log_parser.exs
ENV PATH=/opt/app/bin:$PATH

RUN    chmod a+x /opt/app/bin/oc /opt/app/bin/sentry-cli \
    && chmod g+rwx /opt/app /root \
    && mkdir -p ~/.kube \
    && touch ~/.kube/config \
    && apk add --no-cache elixir

CMD ["elixir", "--no-halt", "/opt/app/log_parser.exs"]
