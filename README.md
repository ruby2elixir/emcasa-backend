[![Build Status](https://travis-ci.org/em-casa/backend.svg?branch=master)](https://travis-ci.org/em-casa/backend)
[![Ebert](https://ebertapp.io/github/em-casa/backend.svg)](https://ebertapp.io/github/em-casa/backend)
# Re WebService

## Install

  * Install dependencies with `mix deps.get`

  * Create, migrate and seed your database with `mix ecto.setup`
  * Rename `config/dev.secret-example.exs` to `config/dev.secret.exs` and follow instructions at the top of the file to generate necessary keys.

  * Setup elasticsearch: `mix elasticsearch.install vendor --version 6.2.4`
  * Run elasticsearch: `./vendor/elasticsearch/bin/elasticsearch` and check `http://localhost:9200`
  * Run kibana: `./vendor/kibana/bin/kibana` and check `http://localhost:5601`
  * Optionally, uncomment the lines in `application.ex` to run `elasticsearch` and `kibana` together with the application
  * Create listings index: `mix elasticsearch.build listings --existing --cluster ReWeb.Search.Cluster`

## Run

  * Start Phoenix endpoint with `mix phx.server`

## Production

To see backend endpoint in production:

`https://em-casa-backend.herokuapp.com/listings`

At the moment, we're tracking tasks at https://www.pivotaltracker.com/n/projects/2125081
