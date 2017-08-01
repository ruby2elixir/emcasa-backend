# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :re,
  ecto_repos: [Re.Repo]

# Configures the endpoint
config :re, ReWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AFa6xCBxoVrAjCy3YRiSjY9e1TfUn75VT2QhSALdwJ+q/oA693/5mJ0OKptYSIID",
  render_errors: [view: ReWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Re.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
