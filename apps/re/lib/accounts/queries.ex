defmodule Re.Accounts.Queries do
  @moduledoc """
  Module for grouping accounts queries
  """
  use Ecto.Schema

  import Ecto.Query

  def search_by_name_or_email_or_phone(query, %{search: search}) do
    from(u in query,
      where: like(u.phone, ^"%#{search}%"),
      or_where: ilike(u.name, ^"%#{search}%"),
      or_where: ilike(u.email, ^"%#{search}%")
    )
  end

  def search_by_name_or_email_or_phone(query, _), do: query
end
