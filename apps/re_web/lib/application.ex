defmodule ReWeb.Application do
  @moduledoc """
  Application module for ReWeb, starts supervision tree.
  """

  use Application

  alias ReWeb.{
    Endpoint,
    Pipedrive
  }

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Endpoint, []),
      supervisor(Absinthe.Subscription, [Endpoint]),
      worker(Pipedrive.Server, [])
    ]

    opts = [strategy: :one_for_one, name: ReWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
