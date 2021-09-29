#!/bin/bash
cd /data
npm install

# For patches
cp /data/patches/connection-parameters.js /data/node_modules/pg/lib/connection-parameters.js
cd /usr/src/node-red