defmodule Re.BuyerLeads.WalkInOffline do
  @moduledoc """
  Schema for offline walk-in buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  alias Re.{
    Accounts.Users,
    BuyerLead
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "walk_in_offline_buyer_leads" do
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
  @optional ~w(full_name email phone_number neighborhoods timestamp location cpf
               where_did_you_find_about)a
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

  def buyer_lead_changeset(nil), do: raise("BuyerLeads.WalkInOffline not found")

  def buyer_lead_changeset(lead) do
    params =
      %{
        name: lead.full_name,
        email: lead.email,
        origin: "walk_in_offline",
        cpf: lead.cpf,
        where_did_you_find_about: lead.where_did_you_find_about
      }
      |> put_location(lead)
      |> put_user_info(lead)

    BuyerLead.changeset(%BuyerLead{}, params)
  end

  defp put_location(params, %{location: location}),
    do: Map.put(params, :location, get_location(location))

  defp get_location("SP"), do: "sao-paulo|sp"
  defp get_location("RJ"), do: "rio-de-janeiro|rj"
  defp get_location(_), do: "unknown"

  defp put_user_info(params, lead) do
    phone_number = concat_phone_number(lead)

    phone_number
    |> Users.get_by_phone()
    |> case do
      {:ok, user} ->
        params
        |> Map.put(:user_uuid, user.uuid)
        |> Map.put(:user_url, Users.build_user_url(user))

      {:error, :not_found} ->
        params
    end
    |> Map.put(:phone_number, phone_number)
  end

  defp concat_phone_number(%{phone_number: "+" <> phone_number}), do: "+55" <> phone_number

  defp concat_phone_number(%{phone_number: phone_number}), do: "+" <> phone_number
end
