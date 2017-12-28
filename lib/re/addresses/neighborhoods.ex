defmodule Re.Neighborhoods do
  @moduledoc """
  Context for neighborhoods.
  """

  import Ecto.Query

  alias Re.{Repo, Address}

  def all do
    Re.Repo.all(from a in Address, select: a.neighborhood)
  end
end
