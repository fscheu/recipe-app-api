FROM python:3.9-alpine3.13
LABEL maintainer="fscheu"

# This is to run python without the output
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user

# The concatenacion of commands is to not add differents "layers" in the docker image
# rm -rf removes the tmp directory
# adduser is to not use the root user

ENV PATH="/py/bin:$PATH"    

USER django-user