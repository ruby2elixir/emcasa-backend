defmodule ReIntegrations.Application do
  @moduledoc """
  Application module for Integrations, starts supervision tree.
  """

  use Application

  import Supervisor.Spec

  alias ReIntegrations.{
    Notifications.Emails,
    Orulo,
    Routific,
    Repo,
    Search
  }

  def start(_type, _args) do
    children =
      [
        supervisor(Repo, [])
      ] ++ extra_applications(Mix.env())

    opts = [strategy: :one_for_one, name: ReIntegrations.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp extra_applications(:test), do: []

  defp extra_applications(_),
    do: [
      worker(Emails.Server, []),
      worker(Search.Server, []),
      {Orulo.JobQueue, repo: Repo},
      {Routific.JobQueue, repo: Repo, reservation_timeout: 60_000, execution_timeout: 30_000},
      Search.Cluster
    ]
end
