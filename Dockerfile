FROM python:3.9-alpine3.13
LABEL maintainer="fscheu"

# This is to run python without the output
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./scripts /scripts
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
    then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    # rm -rf removes the tmp directory
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    # adduser is to not use the root user
    adduser \
    --disabled-password \
    --no-create-home \
    django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    # 755 means that you can do any change to that directory
    chmod -R 755 /vol && \
    # +x is for make the directory executable
    chmod -R +x /scripts

# The concatenacion of commands is to not add differents "layers" in the docker image


ENV PATH="/scripts:/py/bin:$PATH"

USER django-user

CMD ["run.sh"]