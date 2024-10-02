FROM ruby:3.1.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN apt-get update -qq && apt-get install -y default-mysql-client
WORKDIR /app
COPY Gemfile* /app/

RUN bundle install

COPY . .
ARG SERVICE
ENV SERVICE=${SERVICE}
COPY docker/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
EXPOSE 3000
