FROM python:3-alpine

RUN apk add --update bash

RUN pip install s3cmd python-dateutil python-magic
