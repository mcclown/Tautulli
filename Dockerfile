FROM python:3.11-slim

LABEL maintainer="Tautulli"

ARG BRANCH
ARG COMMIT

ENV TAUTULLI_DOCKER=True
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# Add lib directory to Python path
ENV PYTHONPATH=/app/lib:$PYTHONPATH

RUN \
  groupadd -g 1000 tautulli && \
  useradd -u 1000 -g 1000 tautulli && \
  echo ${BRANCH} > /app/branch.txt && \
  echo ${COMMIT} > /app/version.txt

RUN \
  mkdir /config && \
  touch /config/DOCKER
VOLUME /config

CMD [ "python", "Tautulli.py", "--datadir", "/config" ]
ENTRYPOINT [ "./start.sh" ]

EXPOSE 8181
HEALTHCHECK --start-period=90s CMD curl -ILfks https://localhost:8181/status > /dev/null || curl -ILfs http://localhost:8181/status > /dev/null || exit 1
