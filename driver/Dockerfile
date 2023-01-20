FROM ruby:3.2 AS build

WORKDIR /application

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local path 'vendor'
RUN bundle config set --local without 'devel'
RUN bundle install

COPY bin bin
COPY lib lib
COPY Rakefile ./

# This container doesn't do anything on startup; instead,
# you're expected to "exec" into it to perform operations.
CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
