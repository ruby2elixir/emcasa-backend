defmodule Re.SellerLeads.DuplicatedEntity do
  @moduledoc """
  Embedded schema for duplicated entity info
  """
  use Ecto.Schema

  import EctoEnum

  @derive Jason.Encoder

  defenum(Type, [{Re.Listing, "listing"}, {Re.SellerLead, "seller_lead"}])

  embedded_schema do
    field :type, Type
    field :uuid, :string
  end

  def changeset(struct, params \\ %{}),
    do:
      Ecto.Changeset.cast(
        struct,
        params,
        ~w(type uuid)a@derive Jason.Encoder
      )
end
