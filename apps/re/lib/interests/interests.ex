defmodule Re.Interests do
  @moduledoc """
  Context to manage operation between users and listings
  """

  import Ecto.Query

  alias Ecto.{
    Changeset,
    Multi
  }

  alias Re.{
    Addresses,
    BuyerLeads.JobQueue,
    Interest,
    Interests.ContactRequest,
    Interests.NotifyWhenCovered,
    InterestType,
    PriceSuggestions,
    PubSub,
    Repo,
    User
  }

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Interest

  def show_interest(params) do
    %Interest{}
    |> Interest.changeset(params)
    |> insert()
    |> PubSub.publish_new("new_interest")
  end

  def preload(interest), do: Repo.preload(interest, :interest_type)

  def get_types do
    Repo.all(from(it in InterestType, where: it.enabled == true, order_by: {:asc, :id}))
  end

  def request_contact(params, user) do
    %ContactRequest{}
    |> ContactRequest.changeset(params)
    |> attach_user(user)
    |> Repo.insert()
    |> PubSub.publish_new("contact_request")
  end

  def request_price_suggestion(params, user) do
    with {:ok, address} <- Addresses.insert_or_update(params.address),
         {:ok, request} <- PriceSuggestions.create_request(params, address, user),
         request <- Repo.preload(request, :address),
         suggested_price <- PriceSuggestions.suggest_price(request) do
      PubSub.publish_new(
        {:ok, %{req: request, price: suggested_price}},
        "new_price_suggestion_request"
      )

      {:ok, request, suggested_price}
    end
  end

  def notify_when_covered(params) do
    %NotifyWhenCovered{}
    |> NotifyWhenCovered.changeset(params)
    |> Repo.insert()
    |> PubSub.publish_new("notify_when_covered")
  end

  defp insert(%{valid?: true} = changeset) do
    uuid = Changeset.get_field(changeset, :uuid)

    Multi.new()
    |> JobQueue.enqueue(:buyer_lead_job, %{"type" => "interest", "uuid" => uuid})
    |> Multi.insert(:add_interest, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{add_interest: interest}} -> {:ok, interest}
      error -> error
    end
  end

  defp insert(changeset), do: {:error, changeset}

  defp attach_user(changeset, %User{id: id}),
    do: ContactRequest.changeset(changeset, %{user_id: id})

  defp attach_user(changeset, _), do: changeset
end
