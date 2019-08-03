defmodule ReIntegrations.SalesforceTest do
  use ReIntegrations.ModelCase

  import Re.CustomAssertion

  import Re.Factory

  alias ReIntegrations.{
    Repo,
    Salesforce
  }

  @event %{
    start: Timex.now(),
    end: Timex.now(),
    duration: 60,
    type: :visit,
    subject: "some subject"
  }

  setup do
    address = insert(:address)
    district = insert(:district, name: "Vila Mariana", name_slug: "vila-mariana")
    insert(:calendar, address: address, districts: [district])
    :ok
  end

  describe "schedule_tours/1" do
    test "creates a new job to monitor routific request" do
      assert {:ok, _} = Salesforce.schedule_visits(date: Timex.now())
      assert_enqueued_job(Repo.all(Salesforce.JobQueue), "monitor_routific_job")
    end
  end

  describe "insert_event/1" do
    test "creates a salesforce event" do
      assert {:ok, %{}} = Salesforce.insert_event(@event)
    end
  end
end
