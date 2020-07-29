defmodule NovenMedia.Pipeline do
  use Membrane.Pipeline
  alias Membrane.Time

  require Logger

  @impl true
  def handle_init(port) do
    children = %{
      app_source: %Membrane.Element.UDP.Source{
        local_port_no: port,
        recv_buffer_size: 500_000
      },
      rtp: %Membrane.RTP.Session.ReceiveBin{
        fmt_mapping: %{96 => :H264},
        custom_depayloaders: %{
          :H264 => Membrane.RTP.H264.Depayloader
        }
      }
    }

    links = [
      link(:app_source) |> via_in(:input, buffer: [fail_size: 300]) |> to(:rtp)
    ]

    spec = %ParentSpec{children: children, links: links}
    {{:ok, spec: spec}, %{}}
  end

  @impl true
  def handle_notification({:new_rtp_stream, ssrc, :H264}, :rtp, state) do
    directory = Application.app_dir(:noven, ["priv", "static", "stream"])
    File.mkdir_p(directory)
    video_timestamper = {:video_timestamper, make_ref()}
    video_nal_parser = {:video_nal_parser, make_ref()}
    decoder = {:decoder, make_ref()}
    thumbnailer = {:thumbnailer, make_ref()}
    tee = {:tee, make_ref()}
    scissors = {:scissors, make_ref()}
    video_payloader = {:video_payloader, make_ref()}
    video_cmaf_muxer = {:video_cmaf_muxer, make_ref()}
    hls_encoder = {:hls_encoder, make_ref()}

    children = %{
      # TODO: remove when moved to the RTP bin
      video_timestamper => %Membrane.RTP.Timestamper{
        resolution: Ratio.new(Time.second(), 90_000)
      },
      video_nal_parser => %Membrane.Element.FFmpeg.H264.Parser{
        framerate: {30, 1},
        alignment: :au,
        attach_nalus?: true
      },
      decoder => Membrane.Element.FFmpeg.H264.Decoder,
      scissors => %Membrane.Scissors{
        intervals:
          Stream.iterate(0, &(&1 + Membrane.Time.milliseconds(10))) |> Stream.map(&{&1, 1}),
        interval_duration_unit: :buffers,
        buffer_duration: fn _buffer, _caps -> 100 end
      },
      thumbnailer => NovenMedia.Thumbnailer,
      tee => Membrane.Element.Tee.Parallel,
      video_payloader => Membrane.MP4.Payloader.H264,
      video_cmaf_muxer => Membrane.MP4.CMAF.Muxer,
      hls_encoder => %Membrane.HTTPAdaptiveStream.Sink{
        manifest_module: Membrane.HTTPAdaptiveStream.HLS,
        target_window_duration: 10 |> Membrane.Time.seconds(),
        storage: %Membrane.HTTPAdaptiveStream.Storages.FileStorage{directory: directory}
      }
    }

    links = [
      link(:rtp)
      |> via_out(Pad.ref(:output, ssrc))
      |> to(video_timestamper)
      |> to(video_nal_parser)
      |> to(tee)
      |> to(video_payloader)
      |> to(video_cmaf_muxer)
      |> via_in(:input)
      |> to(hls_encoder),
      link(tee)
      |> to(decoder)
      |> to(thumbnailer)
    ]

    spec = %ParentSpec{children: children, links: links}
    {{:ok, spec: spec}, state}
  end

  def handle_notification({:new_rtp_stream, ssrc, _}, :rtp, state) do
    Logger.warn("Unsupported stream connected")

    children = [
      {{:fake_sink, ssrc}, Membrane.Element.Fake.Sink.Buffers}
    ]

    links = [
      link(:rtp)
      |> via_out(Pad.ref(:output, ssrc))
      |> to({:fake_sink, ssrc})
    ]

    spec = %ParentSpec{children: children, links: links}
    {{:ok, spec: spec}, state}
  end

  def handle_notification(_notification, _element, state) do
    {:ok, state}
  end
end
