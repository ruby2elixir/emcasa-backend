[![Build Status](https://travis-ci.org/em-casa/backend.svg?branch=master)](https://travis-ci.org/em-casa/backend)
[![Ebert](https://ebertapp.io/github/em-casa/backend.svg)](https://ebertapp.io/github/em-casa/backend)
# Re WebService

## Install

  * Install dependencies with `mix deps.get`

  * Create, migrate and seed your database with `mix ecto.setup`
  * Rename `config/dev.secret-example.exs` to `config/dev.secret.exs` and follow instructions at the top of the file to generate necessary keys.

  * Setup elastic search with docker:
  ```
  docker pull elasticsearch
  mkdir <data-dir>
  docker run -d -p 9200:9200 -p 9300:9300 -v <data-dir> elasticsearch /elasticsearch/bin/elasticsearch -Des.config=<data-dir>/elasticsearch.yml
  open http://localhost:9200
  ```


## Run

  * Start Phoenix endpoint with `mix phx.server`

## Production

To see backend endpoint in production:

`https://em-casa-backend.herokuapp.com/listings`

At the moment, we're tracking tasks at https://www.pivotaltracker.com/n/projects/2125081
