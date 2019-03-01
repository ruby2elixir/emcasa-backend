defmodule Re.Developments do
  @moduledoc """
  Context for developments.
  """

  require Ecto.Query

  alias Re.{
    Development,
    Repo
  }

  def all do
    Re.Development
    |> Re.Repo.all()
  end

  def get(id), do: do_get(Development, id)

  defp do_get(query, id) do
    case Repo.get(query, id) do
      nil -> {:error, :not_found}
      development -> {:ok, development}
    end
  end
end
