defmodule NovenWeb.DeviceSocket do
  use Phoenix.Socket
  require Logger

  ## Channels
  channel "device:*", NovenWeb.DeviceChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, token} <- Base.decode64(token, padding: false),
         token <- :crypto.hash(:sha256, token),
         %Noven.Devices.Device{} = device <- Noven.Devices.get_device_by_token(token) do
      {:ok,
       socket
       |> assign(:device, device)}
    else
      error ->
        Logger.error("Could not authenticate device: #{inspect(error)}")
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     NovenWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket), do: "device_socket:#{socket.assigns.device.id}"
end
