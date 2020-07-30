defmodule NovenWeb.DeviceLive.Index do
  use NovenWeb, :live_view

  alias Noven.Devices
  alias Noven.Devices.Device
  alias Noven.Accounts

  @impl true
  def mount(_params, %{"current_user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)

    {:ok,
     socket
     |> assign(:devices, list_devices(user))
     |> assign(:current_user, user)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Device")
    |> assign(:device, Devices.get_device!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Device")
    |> assign(:device, %Device{user_id: socket.assigns.current_user.id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Devices")
    |> assign(:device, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    device = Devices.get_device!(socket.assigns.current_user, id)
    {:ok, _} = Devices.delete_device(device)

    {:noreply, assign(socket, :devices, list_devices(socket.assigns.current_user))}
  end

  defp list_devices(user) do
    Devices.list_devices(user)
  end
end
