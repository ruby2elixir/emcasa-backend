defmodule Re.Neighborhoods do
  @moduledoc """
  Context for neighborhoods.
  """

  import Ecto.Query

  alias Re.{Repo, Address}

  def all do
    Repo.all(from a in Address, select: a.neighborhood, distinct: a.neighborhood)
  end
end
