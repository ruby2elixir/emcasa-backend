defmodule ReWeb.Resolvers.Developments do
  import Absinthe.Resolution.Helpers

  require Ecto.Query

  def index(_params, _context) do
    developments =
      Re.Development
      |> Re.Repo.all()

    {:ok, developments}
  end
end
