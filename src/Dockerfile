FROM python:3.9-slim

WORKDIR /usr/src/app

RUN apt-get update -y && \
    apt-get install -y \
    default-mysql-client \
    default-libmysqlclient-dev

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r \
    requirements.txt
COPY . .

COPY docker-entrypoint.sh /opt/docker-entrypoint.sh

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD []
