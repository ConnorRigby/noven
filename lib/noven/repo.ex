defmodule Noven.Repo do
  use Ecto.Repo,
    otp_app: :noven,
    adapter: Ecto.Adapters.Postgres
end
