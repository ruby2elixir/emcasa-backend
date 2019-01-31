defmodule ReTags.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ReTags.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: ReTags.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
