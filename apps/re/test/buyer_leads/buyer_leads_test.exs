defmodule Re.BuyerLeadsTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    BuyerLeads,
    BuyerLeads.Budget,
    BuyerLeads.EmptySearch,
    BuyerLeads.JobQueue,
    Repo
  }

  describe "create_budget" do
    test "should create a buyer lead and process job" do
      user = insert(:user)
      params = params_for(:budget_buyer_lead, user_uuid: user.uuid)

      assert {:ok, _buyer_lead} = BuyerLeads.create_budget(params, user)

      assert Repo.one(Budget)
      assert Repo.one(JobQueue)
    end
  end

  describe "create_empty_search" do
    test "should create a buyer lead and process job" do
      user = insert(:user)
      params = params_for(:empty_search_buyer_lead, user_uuid: user.uuid)

      assert {:ok, _buyer_lead} = BuyerLeads.create_empty_search(params, user)

      assert Repo.one(EmptySearch)
      assert Repo.one(JobQueue)
    end
  end
end
