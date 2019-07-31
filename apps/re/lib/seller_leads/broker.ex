defmodule Re.SellerLeads.Broker do
  @moduledoc """
  Schema for broker indication seller leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "broker_seller_leads" do

    field :complement, :string
    field :type, :string
    field :additional_information, :string
    field :owner_name, :string
    field :owner_telephone, :string
    field :owner_email, :string

    belongs_to :address, Re.Address,
               references: :uuid,
               foreign_key: :address_uuid,
               type: Ecto.UUID

    belongs_to :broker, Re.User,
               references: :uuid,
               foreign_key: :broker_uuid,
               type: Ecto.UUID

    timestamps()
  end

  @types ~w(Apartamento Casa Cobertura)
  @required ~w(type address_uuid broker_uuid owner_name owner_telephone)a
  @optional ~w(complement additional_information)a
  @params @required ++ @optional

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> validate_inclusion(:type, @types)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
