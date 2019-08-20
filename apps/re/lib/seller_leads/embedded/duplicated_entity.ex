defmodule Re.SellerLeads.DuplicatedEntity do
  @moduledoc """
  Embedded schema for duplicated entity info
  """
  use Ecto.Schema

  import EctoEnum

  defenum(Type,
    listing: "listing",
    seller_lead: "seller_lead"
  )

  embedded_schema do
    field :type, Type
    field :uuid, :string
  end

  def changeset(struct, params \\ %{}),
    do:
      Ecto.Changeset.cast(
        struct,
        params,
        ~w(type uuid)a
      )

  def struct_to_atom(Re.Listing), do: :listing
  def struct_to_atom(Re.SellerLead), do: :seller_lead
end
