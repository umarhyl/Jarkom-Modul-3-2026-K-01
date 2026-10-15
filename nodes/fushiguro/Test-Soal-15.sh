#!/bin/sh

for i in {1..8}; do curl -s -H "Host: api.shibuya.com" http://10.64.4.2; echo ""; done