FROM python:3-alpine

# install requirements
ADD requirements*.txt ./
RUN pip install --no-cache-dir -r requirements.txt

ADD check out in /opt/resource/

RUN chmod 755 /opt/resource/*
