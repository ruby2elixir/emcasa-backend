[![Build Status](https://travis-ci.org/em-casa/backend.svg?branch=master)](https://travis-ci.org/em-casa/backend)
[![Ebert](https://ebertapp.io/github/em-casa/backend.svg)](https://ebertapp.io/github/em-casa/backend)
# Re WebService

## Install

  * Install dependencies with `mix deps.get`

  * Create, migrate and seed your database with `mix ecto.setup`
  * Rename `config/dev.secret-example.exs` to `config/dev.secret.exs` and follow instructions at the top of the file to generate necessary keys.

## Setup elasticsearch
  * Download and install (comes with kibana): `mix elasticsearch.install . --version 6.2.4`
  * Run elasticsearch: `./elasticsearch/bin/elasticsearch` and check `http://localhost:9200`
  * Run kibana: `./kibana/bin/kibana` and check `http://localhost:5601`
  * Optionally, uncomment the lines in `application.ex` to run `elasticsearch` and `kibana` together with the application
  * Create listings index: `mix elasticsearch.build listings --existing --cluster ReWeb.Search.Cluster` (see `ReWeb.Search` for more operations)

## Run

  * Start Phoenix endpoint with `mix phx.server`
  * Check `http://localhost:4000/listings`
  * WebSocket subscriptions at `ws://localhost:4000/socket`

## Production

To see backend endpoint in production:

`https://em-casa-backend.herokuapp.com/listings`

At the moment, we're tracking tasks at https://www.pivotaltracker.com/n/projects/2125081
