defmodule Re.SellerLeads.Utm do
  @moduledoc """
  Embedded schema for utm info
  """
  use Ecto.Schema

  embedded_schema do
    field :campaign, :string
    field :medium, :string
    field :source, :string
    field :initial_campaign, :string
    field :initial_medium, :string
    field :initial_source, :string
  end

  def changeset(struct, params \\ %{}),
      do:
        Ecto.Changeset.cast(
          struct,
          params,
          ~w(campaign medium source initial_campaign initial_medium initial_source)a
        )
end
