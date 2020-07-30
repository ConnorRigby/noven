defmodule NovenWeb.DeviceLiveTest do
  use NovenWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Noven.Devices

  @create_attrs %{
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

  defp fixture(:device) do
    {:ok, device} = Devices.create_device(@create_attrs)
    device
  end

  defp create_device(_) do
    device = fixture(:device)
    %{device: device}
  end

  describe "Index" do
    setup [:create_device]

    test "lists all devices", %{conn: conn, device: device} do
      {:ok, _index_live, html} = live(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Listing Devices"
      assert html =~ device.name
    end

    test "saves new device", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.device_index_path(conn, :index))

      assert index_live |> element("a", "New Device") |> render_click() =~
               "New Device"

      assert_patch(index_live, Routes.device_index_path(conn, :new))

      assert index_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#device-form", device: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Device created successfully"
      assert html =~ "some name"
    end

    test "updates device in listing", %{conn: conn, device: device} do
      {:ok, index_live, _html} = live(conn, Routes.device_index_path(conn, :index))

      assert index_live |> element("#device-#{device.id} a", "Edit") |> render_click() =~
               "Edit Device"

      assert_patch(index_live, Routes.device_index_path(conn, :edit, device))

      assert index_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#device-form", device: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Device updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes device in listing", %{conn: conn, device: device} do
      {:ok, index_live, _html} = live(conn, Routes.device_index_path(conn, :index))

      assert index_live |> element("#device-#{device.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#device-#{device.id}")
    end
  end

  describe "Show" do
    setup [:create_device]

    test "displays device", %{conn: conn, device: device} do
      {:ok, _show_live, html} = live(conn, Routes.device_show_path(conn, :show, device))

      assert html =~ "Show Device"
      assert html =~ device.name
    end

    test "updates device within modal", %{conn: conn, device: device} do
      {:ok, show_live, _html} = live(conn, Routes.device_show_path(conn, :show, device))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Device"

      assert_patch(show_live, Routes.device_show_path(conn, :edit, device))

      assert show_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#device-form", device: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_show_path(conn, :show, device))

      assert html =~ "Device updated successfully"
      assert html =~ "some updated name"
    end
  end
end
