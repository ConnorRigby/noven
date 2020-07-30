defmodule NovenWeb.DeviceLive.Index do
  use NovenWeb, :live_view

  alias Noven.Devices
  alias Noven.Devices.Device
  alias Noven.Accounts
  alias Phoenix.Socket.Broadcast

  @impl true
  def mount(_params, %{"current_user_id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    :ok = socket.endpoint.subscribe("devices")

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

  @impl true
  def handle_info(
        %Broadcast{event: "presence_diff", payload: payload},
        %{assigns: %{devices: devices}} = socket
      ) do
    {:noreply,
     socket
     |> assign(:devices, sync_presence(devices, payload))}
  end

  def handle_info({:refresh_hack, _device}, socket) do
    {:noreply,
     socket
     |> assign(:devices, list_devices(socket.assigns.current_user))}
  end

  defp list_devices(user) do
    Devices.list_devices(user)
    |> sync_presence(%{joins: Noven.DevicePresence.list("devices"), leaves: %{}})
  end

  defp sync_presence(devices, %{joins: joins, leaves: leaves}) do
    for device <- devices do
      id = to_string(device.id)

      cond do
        meta = joins[id] ->
          fields = [:pipeline, :ssrc]
          updates = Map.take(meta, fields)
          device = Map.merge(device, updates)

          if device.ssrc do
            index_file =
              Application.app_dir(:noven, ["priv", "static", "stream", device.ssrc, "index.m3u8"])

            stream_ready = File.exists?(index_file)
            stream_ready || Process.send_after(self(), {:refresh_hack, device}, 1000)
            Map.put(device, :stream_ready, stream_ready)
          else
            Map.put(device, :stream_ready, false)
          end

        leaves[id] ->
          # We're counting a device leaving as its last_communication. This is
          # slightly inaccurate to set here, but only by a minuscule amount
          # and saves DB calls and broadcasts
          disconnect_time = DateTime.truncate(DateTime.utc_now(), :second)

          device
          |> Map.put(:last_communication, disconnect_time)
          |> Map.put(:status, "offline")

        true ->
          device
          |> Map.merge(%{pipeline: "stop", stream_ready: false, ssrc: nil})
      end
    end
  end
end
