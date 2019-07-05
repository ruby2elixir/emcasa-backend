defmodule Re.BuyerLeads.WalkinOffline do
  @moduledoc """
  Schema for offline walkin buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  alias Re.{
    Accounts.Users,
    BuyerLead,
    BuyerLeads.FacebookClient,
    Listings
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "walking_offline_buyer_leads" do
    field :full_name, :string
    field :email, :string
    field :phone_number, :string
    field :neighborhoods, :string
    field :timestamp, :utc_datetime
    field :location, :string
    field :cpf, :string
    field :where_did_you_find_about, :string

    timestamps(type: :utc_datetime)
  end

  @required ~w()a
  @optional ~w(full_name email phone_number neighborhoods timestamp location cpf where_did_you_find_about)a
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
