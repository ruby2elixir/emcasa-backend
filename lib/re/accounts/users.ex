defmodule Re.Accounts.Users do

  alias Re.{
    Repo,
    User
  }

  def get_by_email(email) do
    case Repo.get_by(User, email: String.downcase(email)) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

end
