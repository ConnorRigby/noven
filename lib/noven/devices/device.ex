defmodule Noven.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset

  schema "devices" do
    field :last_connected, :utc_datetime
    field :name, :string
    field :serial, :string
    field :user_id, :id
    has_one :device_token, Noven.Devices.DeviceToken
    has_many :printers, Noven.Printer

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
