defmodule Re.Listings.Opts do
  @moduledoc """
  Module for managing options
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "params" do
    field :page_size, :integer
    field :excluded_listing_ids, {:array, :integer}, default: []
  end

  @fields ~w(page_size excluded_listing_ids)a

  def build(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> apply_changes()
  end
end
