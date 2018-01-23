FROM ruby:latest

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

COPY Gemfile /code/
WORKDIR /code
CMD foreman start

RUN apt-get update && \
    apt-get install -y locales apt-utils nodejs && \
    cd /code/ && \
    bundle install && \
    printf "LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLANGUAGE=en_US:en\n" > /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8 && \
    rm -rf /code
