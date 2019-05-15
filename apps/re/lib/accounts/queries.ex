defmodule Re.Accounts.Queries do
  @moduledoc """
  Module for grouping accounts queries
  """
  use Ecto.Schema

  import Ecto.Query

  def or_contains_email(query, %{search: search}) do
    from(u in query, or_where: ilike(u.email, ^"%#{search}%"))
  end

  def or_contains_email(query, _), do: query

  def or_contains_name(query, %{search: search}) do
    from(u in query, or_where: ilike(u.name, ^"%#{search}%"))
  end

  def or_contains_name(query, _), do: query

  def or_contains_phone(query, %{search: search}) do
    from(u in query, or_where: like(u.phone, ^"%#{search}%"))
  end

  def or_contains_phone(query, _), do: query
end
