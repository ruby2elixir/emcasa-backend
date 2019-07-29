defmodule ReIntegrations.SalesforceTest do
  use ReIntegrations.ModelCase

  import Re.CustomAssertion

  alias ReIntegrations.{
    Repo,
    Routific,
    Salesforce
  }

  describe "schedule_tours/1" do
    test "create a new job to monitor routific request" do
      assert {:ok, _} = Salesforce.schedule_visits()
      assert_enqueued_job(Repo.all(Routific.JobQueue), "monitor_routific_job")
    end
  end
end
