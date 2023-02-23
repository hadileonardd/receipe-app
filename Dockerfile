FROM python:3.9-alpine3.13
LABEL maintainer="londonappdeveloper.com"

# don't buffer the output, the output will be printed directly on the console
# preventing delay the application, so able to see the log immidiately as they run
# recommended when doing python dev on docker
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

#define build argument to false and change to true when run docker compose
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
        fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \ 
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user