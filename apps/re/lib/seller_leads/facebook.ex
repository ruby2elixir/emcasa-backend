defmodule Re.SellerLeads.Facebook do
  @moduledoc """
  Schema for facebook seller leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "facebook_seller_leads" do
    field :full_name, :string
    field :email, :string
    field :phone_number, :string
    field :neighborhoods, :string
    field :objective, :string
    field :timestamp, :utc_datetime
    field :lead_id, :string
    field :location, :string

    timestamps()
  end

  @required ~w(full_name email phone_number timestamp lead_id location)a
  @optional ~w(neighborhoods objective)a
  @params @required ++ @optional
  @locations ~w(RJ SP)

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> validate_inclusion(:location, @locations,
      message: "should be one of: [#{Enum.join(@locations, " ")}]"
    )
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
