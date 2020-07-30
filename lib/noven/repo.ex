defmodule Noven.Repo do
  use Ecto.Repo,
    otp_app: :noven,
    adapter: Ecto.Adapters.Postgres

  if Mix.env() == :prod do
    def init(_, opts) do
      {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
    end
  end
end
