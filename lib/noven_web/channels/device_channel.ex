defmodule NovenWeb.DeviceChannel do
  use NovenWeb, :channel

  def join(_topic, _params, socket) do
    port = 5000
    # host = socket.endpoint.host()
    host = "127.0.0.1"

    case NovenMedia.Supervisor.start_pipeline(socket.assigns.device, port) do
      {:ok, pid} ->
        :ok = NovenMedia.Pipeline.play(pid)
        {:ok, %{host: host, port: port}, assign(socket, :pipeline_pid, pid)}

      {:error, {:already_started, pid}} ->
        :ok = NovenMedia.Pipeline.play(pid)
        {:ok, %{host: host, port: port}, assign(socket, :pipeline_pid, pid)}
    end
  end

  def terminate(_, %{assigns: %{pipeline_pid: pid}}) do
    NovenMedia.Pipeline.stop_and_terminate(pid, [])
  end

  def terminate(_, _), do: :ok
end
