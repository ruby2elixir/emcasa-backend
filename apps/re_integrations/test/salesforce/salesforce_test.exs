defmodule ReIntegrations.SalesforceTest do
  use ReIntegrations.ModelCase

  import Re.CustomAssertion

  import Re.Factory

  alias ReIntegrations.{
    Repo,
    Routific,
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
      assert_enqueued_job(Repo.all(Routific.JobQueue), "monitor_routific_job")
    end
  end

  describe "enqueue_insert_event/1" do
    test "creates a new job to insert a salesforce event" do
      assert {:ok, _} = Salesforce.enqueue_insert_event(@event)
      assert_enqueued_job(Repo.all(Salesforce.JobQueue), "insert_event")
    end
  end

  describe "insert_event/1" do
    test "creates a salesforce event" do
      assert {:ok, %{}} = Salesforce.insert_event(@event)
    end
  end
end
