defmodule Boxing.Repo do
  use Ecto.Repo,
    otp_app: :boxing,
    adapter: Ecto.Adapters.Postgres
end
