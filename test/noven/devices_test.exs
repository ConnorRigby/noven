defmodule Noven.DevicesTest do
  use Noven.DataCase

  alias Noven.Devices

  describe "devices" do
    alias Noven.Devices.Device

    @valid_attrs %{
      last_connected: "2010-04-17T14:00:00Z",
      name: "some name",
      serial: "some serial",
      token: "some token"
    }
    @update_attrs %{
      last_connected: "2011-05-18T15:01:01Z",
      name: "some updated name",
      serial: "some updated serial",
      token: "some updated token"
    }
    @invalid_attrs %{last_connected: nil, name: nil, serial: nil, token: nil}

    def device_fixture(attrs \\ %{}) do
      {:ok, device} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Devices.create_device()

      device
    end

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert Devices.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert Devices.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      assert {:ok, %Device{} = device} = Devices.create_device(@valid_attrs)
      assert device.last_connected == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert device.name == "some name"
      assert device.serial == "some serial"
      assert device.token == "some token"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      assert {:ok, %Device{} = device} = Devices.update_device(device, @update_attrs)
      assert device.last_connected == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert device.name == "some updated name"
      assert device.serial == "some updated serial"
      assert device.token == "some updated token"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_device(device, @invalid_attrs)
      assert device == Devices.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()
      assert {:ok, %Device{}} = Devices.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()
      assert %Ecto.Changeset{} = Devices.change_device(device)
    end
  end
end
