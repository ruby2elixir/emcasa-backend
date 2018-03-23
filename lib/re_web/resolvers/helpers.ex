defmodule ReWeb.Schema.Helpers do

  import Ecto.Query

  alias Re.Repo

  def by_id(model, ids) do

    ids = Enum.uniq(ids)

    model
    |> where([m], m.id in ^ids)
    |> Repo.all()
    |> Map.new(&{&1.id, &1})
  end
end
