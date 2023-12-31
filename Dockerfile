FROM python:3.9-alpine3.13
LABEL maintainer="2sansrit@gmail.com"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./scripts /scripts
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
#runs command onto alpine images
#create a virtual env
RUN python -m venv /py

#upgrade pip
RUN /py/bin/pip install --upgrade pip

#install into docker image
#install PostgreSQL client and build dependencies
#linux-headers for uwsgi deploy
RUN apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev zlib zlib-dev linux-headers

RUN /py/bin/pip install -r /tmp/requirements.txt && \
    # if [ $DEV = "true" ]; \
    # then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    # fi && \
    if [ "$DEV" = "true" ]; then pip install -r /tmp/requirements.dev.txt; fi 

#remove temporary files and dependencies
RUN rm -rf /tmp && \
    apk del .tmp-build-deps

#non-root user addition
RUN adduser \
    --disabled-password \
    --no-create-home \
    django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts



ENV PATH="/scripts:/py/bin:$PATH"

USER django-user

CMD ["run.sh"]

