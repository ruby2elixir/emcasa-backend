defmodule Re.Repo.Migrations.AddPriceSuggestionRequestUuid do
  use Ecto.Migration

  alias Re.{
    PriceSuggestions.Request,
    Repo
  }

  def up do
    alter table(:price_suggestion_requests) do
      add :uuid, :uuid
      add :seller_lead_uuid, references(:seller_leads, column: :uuid, type: :uuid)
    end

    create unique_index(:price_suggestion_requests, [:uuid])

    flush()

    Request
    |> Repo.all()
    |> Enum.map(fn req ->
      req
      |> Request.changeset()
      |> Repo.update()
    end)
  end

  def down do
    alter table(:price_suggestion_requests) do
      remove :uuid
      remove :seller_lead_uuid
    end
  end
end
