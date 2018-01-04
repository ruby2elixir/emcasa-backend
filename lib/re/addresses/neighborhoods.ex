defmodule Re.Neighborhoods do
  @moduledoc """
  Context for neighborhoods.
  """

  import Ecto.Query

  alias Re.{Repo, Address}

  @all_query from a in Address,
    select: a.neighborhood,
    distinct: a.neighborhood

  def all do
    Repo.all(@all_query)
  end
end
