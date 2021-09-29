FROM nodered/node-red:latest
MAINTAINER Irwan Fathurrahman<meomancer@gmail.com>
ADD settings/package.json /data/package.json
ADD settings/flows.json /data/flows.json
ADD settings/settings.js /data/settings.js
ADD settings/patches /data/patches

ADD setup.sh /usr/local/bin/setup.sh
ADD start.sh /usr/local/bin/start.sh
RUN setup.sh