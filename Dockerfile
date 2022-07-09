FROM alpine

RUN apk add --no-cache mosquitto-clients curl bash openssl



COPY runner.sh /opt/mpower/runner.sh
COPY settings.cfg /opt/mpower/settings.cfg
WORKDIR /opt/mpower/

CMD ["/bin/bash","/opt/mpower/runner.sh"]

