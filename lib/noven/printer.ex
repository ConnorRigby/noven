defmodule Noven.Printer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "printers" do
    field :name, :string
    belongs_to :device, Noven.Devices.Device
    timestamps()
  end

  @doc false
  def changeset(printer, attrs) do
    printer
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
