defmodule Noven.Repo.Migrations.CreatePrinters do
  use Ecto.Migration

  def change do
    create table(:printers) do
      add :name, :string, null: false
      add :device_id, references(:devices, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:printers, [:device_id])
  end
end
