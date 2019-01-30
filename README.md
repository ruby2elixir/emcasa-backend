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

* Prepare database with `mix ecto.create`
* Apply all migrations `mix ecto.migrate`
* Start Phoenix endpoint with `mix phx.server`
* Check `http://localhost:4000/graphql_api`
* WebSocket subscriptions at `ws://localhost:4000/socket`

### Enable `https` locally

To enable `https` locally, it's necessary to add `priv/cert/dev/dev_cert_ca.cert.pem` to your trusted root certificates, this varies accordingly your OS, or browser of choice, below are links, showing how to procede:

* OSX: [adding the root certificate to macOS keychain][0]
* Windows: [manage trusted root certificates in windows][1]
* Linux (debian/ubuntu): [how to import ca root certificate][2]
* Firefox: [add root to firefox][3]

Now it's time to update our `/etc/hosts` (or `C:\Windows\System32\drivers\etc\hosts`), and add an entry mapping `dev.emcasa.com` to `127.0.0.1`.

## Production

To see backend endpoint in production: `https://api.emcasa.com/`

At the moment, we're tracking tasks at https://www.pivotaltracker.com/n/projects/2125081

## Possible issues

Use `asdf` or check the tools versions in `.tools-version`

[0]: https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/#adding-root-cert-macos-keychain
[1]: https://www.thewindowsclub.com/manage-trusted-root-certificates-windows
[2]: https://thomas-leister.de/en/how-to-import-ca-root-certificate/#linux-debian-ubuntu
[3]: https://wiki.mozilla.org/CA/AddRootToFirefox
