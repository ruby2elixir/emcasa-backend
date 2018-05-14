defmodule Re.Application do
  @moduledoc """
  Main module for Re, starts supervision tree.
  """

  use Application

  alias ReWeb.{
    Endpoint,
    Integrations.Pipedrive,
    Notifications.Emails,
    Search
  }

  alias Re.Stats.Visualizations

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Re.Repo, []),
      supervisor(ReWeb.Endpoint, []),
      supervisor(Absinthe.Subscription, [ReWeb.Endpoint]),
      worker(Visualizations, []),
      worker(Emails.Server, []),
      worker(Search.Server, []),
      worker(Pipedrive.Server, []),
      Search.Cluster
      # worker(Elasticsearch.Executable, [
      #   "Elasticsearch",
      #   "./elasticsearch/bin/elasticsearch",
      #   9200
      # ], id: :elasticsearch),
      # worker(Elasticsearch.Executable, [
      #   "Kibana",
      #   "./kibana/bin/kibana",
      #   5601
      # ], id: :kibana)
    ]

    opts = [strategy: :one_for_one, name: Re.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
