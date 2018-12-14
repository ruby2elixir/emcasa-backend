defmodule ReWeb.Application do
  @moduledoc """
  Application module for ReWeb, starts supervision tree.
  """

  use Application

  import Supervisor.Spec

  alias ReWeb.{
    Endpoint
  }

  alias ReIntegrations.Pipedrive

  def start(_type, _args) do
    children =
      [
        supervisor(Endpoint, []),
        supervisor(Absinthe.Subscription, [Endpoint])
      ] ++ extra_processes(Mix.env())

    opts = [strategy: :one_for_one, name: ReWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end

  defp extra_processes(:test), do: []

  defp extra_processes(_),
    do: [
      worker(Pipedrive.Server, [])
    ]
end
