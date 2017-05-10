FROM ubuntu:14.04

RUN echo "Asia/Tokyo" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install ruby1.9.3
RUN apt-get -y install build-essential

RUN gem install bundler --no-ri --no-rdoc

# スクリプトに変更があっても、bundle installをキャッシュさせる
WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install # @todo --without=test だと動かないのを修正

ADD . /script
WORKDIR /script

EXPOSE 80

CMD bundle exec rackup -p 80
