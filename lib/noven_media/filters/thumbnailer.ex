defmodule NovenMedia.Thumbnailer do
  use Membrane.Sink
  alias Membrane.Caps.Video.Raw
  alias Membrane.Buffer
  require Logger

  def_input_pad(:input, caps: Raw, demand_unit: :buffers)

  @impl true
  def handle_init(_) do
    {:ok, %{caps: nil}}
  end

  @impl true
  def handle_caps(:input, caps, ctx, state) do
    %{input: input} = ctx.pads

    if !input.caps || caps == input.caps do
      actions = [
        demand: :input
      ]

      {{:ok, actions}, %{state | caps: caps}}
    else
      raise "Caps have changed while playing. This is not supported."
    end
  end

  @impl true
  def handle_stopped_to_prepared(_ctx, state) do
    {:ok, state}
  end

  @impl true
  def handle_write(:input, %Buffer{payload: payload}, _ctx, state) do
    %Membrane.Caps.Video.Raw{
      format: format,
      height: height,
      width: width
    } = state.caps

    case Turbojpeg.yuv_to_jpeg(payload, width, height, 90, format) do
      {:ok, jpeg} ->
        File.write!("test.jpg", Shmex.to_binary(jpeg))
        actions = [demand: :input]
        {{:ok, actions}, state}

      error ->
        Logger.error("Could not decode yuv to jpeg: #{inspect(error)}")
        {:ok, state}
    end
  end
end
