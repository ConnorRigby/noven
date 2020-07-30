defmodule Noven.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :serial, :string, null: false
      add :name, :string, null: false
      add :last_connected, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:devices, [:user_id])
    create unique_index(:devices, [:serial])

    create table(:device_tokens) do
      add :device_id, references(:devices, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      timestamps(updated_at: false)
    end

    create index(:device_tokens, [:device_id])
    create unique_index(:device_tokens, [:device_id, :token])
  end
end
