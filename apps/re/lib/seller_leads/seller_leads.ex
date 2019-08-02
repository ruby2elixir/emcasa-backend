defmodule Re.SellerLeads do
  @moduledoc """
  Context boundary to Seller Leads
  """
  require Ecto.Query

  alias Re.{
    PubSub,
    Repo,
    User,
    Accounts.Users,
    SellerLead,
    SellerLeads.Facebook,
    SellerLeads.Site,
    SellerLeads.Broker
  }

  alias Ecto.{
    Changeset,
    Multi,
    Query
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def create_site(params) do
    %Site{}
    |> Site.changeset(params)
    |> Repo.insert()
    |> PubSub.publish_new("new_site_seller_lead")
  end

  def create_broker(params) do
    changeset = Broker.changeset(%Broker{}, params)

    property_owner_param = %{
      name: Map.get(params, "owner_name"),
      phone: Map.get(params, "owner_telephone"),
      email: Map.get(params, "owner_email"),
      role: "user"
    }

    property_owner = User.create_changeset(%User{}, property_owner_param)

    Ecto.Multi.new()
    |> Multi.insert(:insert_broker_seller_lead, changeset)
    |> handle_property_owner(property_owner)
    |> Repo.transaction()
    |> return_insertion()
  end

  defp handle_property_owner(multi, property_owner_changeset) do
    phone = Changeset.get_field(property_owner_changeset, :phone)

    case Users.get_by_phone(phone) do
      {:error, _} -> Multi.insert(multi, :insert_broker_user_lead, property_owner_changeset)
      _ -> multi
    end
  end

  defp return_insertion({:ok, %{insert_broker_seller_lead: request}}), do: {:ok, request}

  defp return_insertion(error), do: error

  def create(%{"source" => "facebook_seller"} = payload) do
    %Facebook{}
    |> Facebook.changeset(payload)
    |> Repo.insert()
  end

  def get_preloaded(uuid, preloads) do
    SellerLead
    |> Query.preload(^preloads)
    |> do_get(uuid)
  end

  defp do_get(query, uuid) do
    case Repo.get(query, uuid) do
      nil -> {:error, :not_found}
      seller_lead -> {:ok, seller_lead}
    end
  end
end
