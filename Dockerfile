# Dockerfile
FROM ruby:2.6.6

RUN apt-get update -qq && apt-get install -y build-essential
RUN gem install bundler

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install --without development test

ADD . $APP_HOME

RUN chmod +x docker-entrypoint.sh
COPY docker-entrypoint.sh /usr/local/bin

ENTRYPOINT ["docker-entrypoint.sh"]
