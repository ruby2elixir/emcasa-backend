defmodule ReIntegrations.OruloTest do
  @moduledoc false

  use Re.ModelCase

  alias ReIntegrations.{
    Orulo,
    Orulo.JobQueue
  }

  describe "get_building_payload/2" do
    test "create o new job with to sync development" do
      assert {:ok, _} = Orulo.get_building_payload(100)
      assert Repo.one(JobQueue)
    end
  end
end
