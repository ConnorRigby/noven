defmodule Noven.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset

  schema "devices" do
    field :last_connected, :utc_datetime
    field :name, :string
    field :serial, :string
    field :user_id, :id
    has_one :device_token, Noven.Devices.DeviceToken

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:user_id, :serial, :name, :last_connected])
    |> validate_required([:serial, :name])
  end
end
