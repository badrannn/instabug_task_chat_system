#!/bin/bash 
set -e
rm -f tmp/pids/server.pid
if [ "$SERVICE" = "worker" ] 
then
  echo "Running sidekiq"
  exec bundle exec sidekiq -C config/sidekiq.yml
else
  echo "Starting server"
  bundle exec rails s -p 3000 -b '0.0.0.0'
fi

