defmodule ReIntegrations.SalesforceTest do
  use ReIntegrations.ModelCase

  import Re.CustomAssertion

  import Re.Factory

  alias ReIntegrations.{
    Repo,
    Routific,
    Salesforce
  }

  setup do
    address = insert(:address)
    district = insert(:district)
    insert(:calendar, address: address, districts: [district])
    :ok
  end

  describe "schedule_tours/1" do
    test "create a new job to monitor routific request" do
      assert {:ok, _} = Salesforce.schedule_visits(date: Timex.now())
      assert_enqueued_job(Repo.all(Routific.JobQueue), "monitor_routific_job")
    end
  end
end
