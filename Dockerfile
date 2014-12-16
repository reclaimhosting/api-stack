FROM ubuntu
MAINTAINER Reclaim Hosting <info@reclaimhosting.com>

RUN mkdir /data
RUN mkdir /data/db
RUN mkdir /data/app

# Define mountable directories.
VOLUME ["/data/db", "/data/app"]

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

RUN apt-get update && apt-get upgrade -y
RUN apt-get install git python build-essential wget screen tmux curl mongodb-org -y
RUN sudo service mongod start

# Install Node.js
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm && \
  echo -e '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# Install Sails.js
RUN npm install -g sails

# Define working directory.
WORKDIR /data/app

ENV sailsapp="sails"

# Create Sails application
RUN sails new sailsapp
WORKDIR sailsapp
RUN npm install
RUN npm install sails-mongo --save

# Expose ports
EXPOSE 3000
EXPOSE 1337
EXPOSE 27017
EXPOSE 28017

# Set command to start Sails
ENTRYPOINT ["sails", "lift", "--verbose"]