defmodule Noven.StreamTest do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    port = open_port()
    socket = open_socket()
    {:ok, %{port: port, socket: socket}}
  end

  def handle_info({port, {:data, data}}, %{port: port} = state) do
    :ok = :gen_udp.send(state.socket, {{127, 0, 0, 1}, 5000}, data)
    {:noreply, state}
  end

  def open_socket do
    {:ok, socket} = :gen_udp.open(0, [:binary, ip: :any, active: true])
    socket
  end

  defp open_port do
    gst = System.find_executable("gst-launch-1.0")

    args = [
      "v4l2src",
      "!",
      "video/x-h264,",
      "stream-format=byte-stream,",
      "alignment=au,",
      "width=1920,",
      "height=1080,",
      "pixel-aspect-ratio=1/1,",
      "framerate=30/1",
      "!",
      "rtph264pay",
      "pt=96",
      "!",
      "fdsink",
      "fd=4"
    ]

    :erlang.open_port({:spawn_executable, gst}, [
      {:args, args},
      :binary,
      :nouse_stdio,
      :exit_status
    ])
  end
end
