defmodule ReIntegrations.Salesforce.JobQueueTest do
  use ReIntegrations.ModelCase

  import Re.CustomAssertion

  alias ReIntegrations.{
    Repo,
    Routific,
    Salesforce.JobQueue
  }

  alias Ecto.Multi

  describe "monitor_routific_job" do
    test "enqueues salesforce events for insertion when routific job succeeds" do
      assert {:ok, %{get_job_status: %Routific.Payload.Inbound{}}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "monitor_routific_job",
                 "job_id" => "FINISHED_JOB_ID"
               })

      assert_enqueued_job(Repo.all(JobQueue), "insert_event", 2)
    end

    test "fails when routific job is pending" do
      assert {:error, _, _, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "monitor_routific_job",
                 "job_id" => "PENDING_JOB_ID"
               })
    end

    test "fails when routific job fails" do
      assert {:error, _, _, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "monitor_routific_job",
                 "job_id" => "FAILED_JOB_ID"
               })
    end
  end

  describe "insert_event" do
    @event %{
      "start" => Timex.now() |> DateTime.to_iso8601(),
      "end" => Timex.now() |> DateTime.to_iso8601(),
      "duration" => 60,
      "type" => "visit",
      "subject" => "some subject"
    }

    test "creates a salesforce event" do
      assert {:ok, %{insert_event: %{}}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "insert_event",
                 "event" => @event
               })
    end
  end
end
