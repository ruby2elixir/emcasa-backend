defmodule Re.Accounts.Filtering do
  @moduledoc """
  Module for grouping accounts filter queries
  """
  use Ecto.Schema

  import Ecto.{
    Query,
    Changeset
  }

  schema "account_filter" do
    field :search, :string
  end

  @filters ~w(search)a

  def changeset(struct, params \\ %{}), do: cast(struct, params, @filters)

  def apply(query, params) do
    params
    |> cast()
    |> build_query(query)
  end

  def cast(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Map.get(:changes)
  end

  defp build_query(params, query), do: Enum.reduce(params, query, &attr_filter/2)

  defp attr_filter({:search, search}, query) do
    from(l in query,
      where: like(l.phone, ^"%#{search}%"),
      or_where: ilike(l.name, ^"%#{search}%"),
      or_where: ilike(l.email, ^"%#{search}%")
    )
  end
end
