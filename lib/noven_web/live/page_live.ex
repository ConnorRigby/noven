defmodule NovenWeb.PageLive do
  use NovenWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, results: %{})}
  end
end

# <video id='hls-example' phx-hook="Video" class="video-js vjs-default-skin" controls>
#     <source type="application/x-mpegURL" src="http://localhost:4000/stream/index.m3u8">
# </video>
