defmodule ReIntegrations.Application do
  @moduledoc """
  Application module for Integrations, starts supervision tree.
  """

  use Application

  import Supervisor.Spec

  alias ReIntegrations.{
    Notifications.Emails,
    Search
  }

  def start(_type, _args) do
    children = [] ++ extra_applications(Mix.env())

    opts = [strategy: :one_for_one, name: ReIntegrations.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp extra_applications(:test), do: []

  defp extra_applications(_),
    do: [
      worker(Emails.Server, []),
      worker(Search.Server, []),
      Search.Cluster
    ]
end
