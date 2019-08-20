defmodule Re.SellerLeads.JobQueue do
  @moduledoc """
  Module for processing seller leads to extract only necessary attributes
  """
  use EctoJob.JobQueue, table_name: "seller_lead_jobs"

  require Ecto.Query

  alias Re.{
    Addresses,
    PriceSuggestions.Request,
    Repo,
    SellerLead,
    SellerLeads,
    SellerLeads.Salesforce,
    SellerLeads.Site,
    SellerLeads.DuplicatedEntity,
    User
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def perform(%Multi{} = multi, %{"type" => "process_price_suggestion_request", "uuid" => uuid}) do
    request =
      Request
      |> Ecto.Query.preload([:address, :user])
      |> Repo.get_by(uuid: uuid)

    request
    |> Request.seller_lead_changeset()
    |> check_duplicity()
    |> insert_seller_lead(multi, request)
    |> update_name(request)
    |> update_email(request)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "process_site_seller_lead", "uuid" => uuid}) do
    site_seller_lead =
      Site
      |> Ecto.Query.preload(price_request: [seller_lead: [:address, :user]])
      |> Repo.get(uuid)

    site_seller_lead
    |> Site.seller_lead_changeset(site_seller_lead.price_request.seller_lead)
    |> update_seller_lead(multi)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "create_lead_salesforce", "uuid" => uuid}) do
    {:ok, seller_lead} = SellerLeads.get_preloaded(uuid, [:address, :user])

    multi
    |> Multi.run(:create_salesforce_lead, fn _repo, _changes ->
      Salesforce.create_lead(seller_lead)
    end)
    |> Multi.run(:update_seller_lead, fn _repo, %{create_salesforce_lead: %{"id" => id}} ->
      seller_lead
      |> SellerLead.changeset(%{salesforce_id: id})
      |> Repo.update()
    end)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "update_lead_salesforce", "uuid" => uuid}) do
    {:ok, seller_lead} = SellerLeads.get_preloaded(uuid, [:address, :user])

    multi
    |> Multi.run(:update_salesforce_lead, fn _repo, _changes ->
      Salesforce.update_lead(seller_lead)
    end)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(_multi, job), do: raise("Job type not handled. Job: #{Kernel.inspect(job)}")

  defp insert_seller_lead(changeset, multi, request) do
    uuid = Changeset.get_field(changeset, :uuid)
    request_changeset = Request.changeset(request, %{seller_lead_uuid: uuid})

    multi
    |> Multi.insert(:insert_seller_lead, changeset)
    |> Multi.update(:update_request, request_changeset)
    |> __MODULE__.enqueue(:salesforce_job, %{"type" => "create_lead_salesforce", "uuid" => uuid})
  end

  defp update_seller_lead(changeset, multi) do
    uuid = Changeset.get_field(changeset, :uuid)

    multi
    |> Multi.update(:update_seller_lead, changeset)
    |> __MODULE__.enqueue(:salesforce_job, %{"type" => "update_lead_salesforce", "uuid" => uuid})
  end

  defp update_name(multi, %{name: name, user: %{name: nil} = user}),
    do: Multi.update(multi, :update_user_name, User.update_changeset(user, %{name: name}))

  defp update_name(multi, _), do: multi

  defp update_email(multi, %{email: email, user: %{email: nil} = user}),
    do: Multi.update(multi, :update_user_email, User.update_changeset(user, %{email: email}))

  defp update_email(multi, _), do: multi

  defp check_duplicity(changeset) do
    uuid = Changeset.get_field(changeset, :address_uuid)
    complement = Changeset.get_field(changeset, :complement)

    case Addresses.get_by_uuid(uuid) do
      {:ok, address} ->
        duplicated_entities = SellerLeads.duplicated_entities(address, complement)

        changeset_duplicated =
          duplicated_entities
          |> Enum.map(fn entity -> DuplicatedEntity.changeset(%DuplicatedEntity{}, entity) end)

        changeset = Changeset.put_embed(changeset, :duplicated_entities, changeset_duplicated)

        case SellerLeads.duplicated?(duplicated_entities) do
          true -> Changeset.put_change(changeset, :duplicated, "almost_sure")
          false -> Changeset.put_change(changeset, :duplicated, "maybe")
        end

      {:error, _} ->
        Changeset.put_change(changeset, :duplicated, "unlikely")
    end
  end

  defp handle_error({:ok, result}), do: {:ok, result}

  defp handle_error(_error), do: raise("Error when performing SellerLeads.JobQueue")
end
