FROM docker.io/heywoodlh/heralding:1.0.7

RUN mkdir -p /logs /web \
    && ln -s /logs/log_auth.csv /web \
    && ln -s /logs/log_session.csv /web \
    && ln -s /logs/log_session.json /web

COPY run.sh /run.sh

WORKDIR /logs

ENTRYPOINT ["/run.sh"]
