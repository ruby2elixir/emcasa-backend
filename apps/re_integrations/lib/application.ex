defmodule ReIntegrations.Application do
  @moduledoc """
  Application module for Integrations, starts supervision tree.
  """

  use Application

  alias ReIntegrations.{
    Notifications.Emails,
    Pipedrive,
    Search
  }

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Emails.Server, []),
      worker(Search.Server, []),
      worker(Pipedrive.Server, []),
      Search.Cluster,
    ]

    opts = [strategy: :one_for_one, name: ReIntegrations.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
