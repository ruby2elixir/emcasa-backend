defmodule Re.Repo.Migrations.AddUserRole do
  use Ecto.Migration
  import Ecto.Query
  alias Re.{
    Repo,
    User
  }

  @users_with_password from u in User, where: not is_nil(u.password)

  def up do
    alter table(:users) do
      add :role, :string
    end
    flush()
    @users_with_password
    |> Repo.update_all(set: [role: "admin"])
  end

  def down do
    alter table(:users) do
      remove :role
    end
  end

end
