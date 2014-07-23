#!/bin/bash

set -e

dir="$(dirname $0)"

# We need the port logstash indexer is listening on for our tests.
service logstash-indexer stop || true

java -jar /usr/src/packages/logstash-1.2.2-flatjar.jar rspec "$dir"/*_spec.rb
