defmodule Re.BuyerLeads.Facebook do
  @moduledoc """
  Schema for facebook buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  alias Re.{
    Accounts.Users,
    BuyerLead
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "facebook_buyer_leads" do
    field :full_name, :string
    field :email, :string
    field :phone_number, :string
    field :neighborhoods, :string
    field :timestamp, :utc_datetime
    field :lead_id, :string
    field :location, :string

    timestamps()
  end

  @required ~w(full_name email phone_number timestamp lead_id location)a
  @optional ~w(neighborhoods)a
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

  def buyer_lead_changeset(nil), do: raise("Leads.FacebookBuyer not found")

  def buyer_lead_changeset(lead) do
    BuyerLead.changeset(%BuyerLead{}, %{
      name: lead.full_name,
      email: lead.email,
      phone_number: lead.phone_number,
      origin: "facebook",
      user_uuid: extract_user_uuid(lead.phone_number)
    })
  end

  defp extract_user_uuid(nil), do: nil

  defp extract_user_uuid(phone_number) do
    case Users.get_by_phone(phone_number) do
      {:ok, user} -> user.uuid
      _error -> nil
    end
  end
end
