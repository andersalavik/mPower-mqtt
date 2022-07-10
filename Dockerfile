FROM alpine

RUN apk add --no-cache python3 py3-pip bash



COPY runner.py /opt/mpower/runner.py
COPY settings.py /opt/mpower/settings.py
COPY requirements.txt /opt/mpower/requirements.txt
WORKDIR /opt/mpower/
RUN python3 -m pip install -r /opt/mpower/requirements.txt

CMD ["python3","/opt/mpower/runner.py"]

