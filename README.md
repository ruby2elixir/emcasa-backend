[![Build Status](https://travis-ci.org/emcasa/backend.svg?branch=master)](https://travis-ci.org/emcasa/backend)
[![Ebert](https://ebertapp.io/github/emcasa/backend.svg)](https://ebertapp.io/github/emcasa/backend)
[![Coverage Status](https://coveralls.io/repos/github/emcasa/backend/badge.svg)](https://coveralls.io/github/emcasa/backend)
[![codebeat badge](https://codebeat.co/badges/eaf3bdc4-572b-4c84-8a93-347850ca530c)](https://codebeat.co/projects/github-com-emcasa-backend-master)
# Re WebService

## Pre-requisites

  * Elixir
  * PostgreSQL

## Install

  * Install dependencies with `mix deps.get`
  * Create, migrate and seed your database with `cd apps/re && mix ecto.setup`
  * Rename `config/dev.secret-example.exs` to `config/dev.secret.exs` and follow instructions at the top of the file to generate necessary keys.
  * Install git hooks with `mix git.hook`

## Setup elasticsearch (optional)

  * Download and install (comes with kibana): `mix elasticsearch.install . --version 6.2.4`
  * Run elasticsearch: `./elasticsearch/bin/elasticsearch` and check `http://localhost:9200`
  * Run kibana: `./kibana/bin/kibana` and check `http://localhost:5601`
  * Optionally, uncomment the lines in `application.ex` to run `elasticsearch` and `kibana` together with the application
  * Create listings index: `mix elasticsearch.build listings --existing --cluster ReIntegrations.Search.Cluster` (see `ReIntegrations.Search` for more operations)

## Test

  * Run `mix test`

## Run

  * Start Phoenix endpoint with `mix phx.server`
  * Check `http://localhost:4000/graphql_api`
  * WebSocket subscriptions at `ws://localhost:4000/socket`

## Production

To see backend endpoint in production:

`https://api.emcasa.com/`

At the moment, we're tracking tasks at https://www.pivotaltracker.com/n/projects/2125081

## Possible issues

Use `asdf` or check the tools versions in `.tools-version`
