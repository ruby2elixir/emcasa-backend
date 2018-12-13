defmodule Re.Repo do
  use Ecto.Repo, otp_app: :re
  use Scrivener, page_size: 20
end
