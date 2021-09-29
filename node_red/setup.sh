#!/bin/bash
cd /data
npm install

# For patches
cp /data/patches/connection-parameters.js /data/node_modules/pg/lib/connection-parameters.js
cd /usr/src/node-red

# Patch node-red dashboard
rm /data/node_modules/node-red-dashboard/dist/index.html
ln -s /data/patches/node-red-dashboard/index.html /data/node_modules/node-red-dashboard/dist/index.html
ln -s /data/patches/static /data/node_modules/node-red-dashboard/dist/unicef