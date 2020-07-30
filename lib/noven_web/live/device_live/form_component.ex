defmodule NovenWeb.DeviceLive.FormComponent do
  use NovenWeb, :live_component

  alias Noven.Devices

  @impl true
  def update(%{device: device} = assigns, socket) do
    changeset = Devices.change_device(device)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"device" => device_params}, socket) do
    changeset =
      socket.assigns.device
      |> Devices.change_device(device_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"device" => device_params}, socket) do
    save_device(socket, socket.assigns.action, device_params)
  end

  defp save_device(socket, :edit, device_params) do
    case Devices.update_device(socket.assigns.device, device_params) do
      {:ok, _device} ->
        {:noreply,
         socket
         |> put_flash(:info, "Device updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_device(socket, :new, device_params) do
    case Devices.create_device(device_params) do
      {:ok, _device} ->
        {:noreply,
         socket
         |> put_flash(:info, "Device created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
