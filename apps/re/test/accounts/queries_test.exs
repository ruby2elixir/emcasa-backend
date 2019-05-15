defmodule Re.Accounts.QueriesTest do
  use Re.ModelCase

  alias Re.{
    Accounts.Queries,
    Repo,
    User
  }

  import Re.Factory

  describe "search_by_name_or_email_or_phone/2" do
    test "filter by phone number" do
      user = insert(:user, phone: "(99)999999999")

      {:ok, _other_user} =
        %User{phone: "(88)888888888"}
        |> Repo.insert()

      result =
        User
        |> Queries.search_by_name_or_email_or_phone(%{search: "999"})
        |> Repo.all()

      assert result == [user]
    end

    test "filter by user name not considering case" do
      user = insert(:user, name: "Alice")

      {:ok, _other_user} =
        %User{name: "Bob"}
        |> Repo.insert()

      result =
        User
        |> Queries.search_by_name_or_email_or_phone(%{search: "ali"})
        |> Repo.all()

      assert result == [user]
    end

    test "filter by user email not considering case" do
      user = insert(:user, email: "alice@gmail.com")

      {:ok, _other_user} =
        %User{email: "bob@bol.com"}
        |> Repo.insert()

      result =
        User
        |> Queries.search_by_name_or_email_or_phone(%{search: "GMAIL"})
        |> Repo.all()

      assert result == [user]
    end
  end
end
