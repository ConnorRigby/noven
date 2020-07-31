defmodule NovenWeb.StreamController do
  use NovenWeb, :controller

  def index(conn, _params) do
    case :ets.lookup(:"stream-1", "index.m3u8") do
      [{_, contents}] ->
        send_resp(conn, 200, contents)
    end
  end

  def stream(conn, _params) do
    render(conn, "stream.html")
  end

  def data(conn, %{"data" => name}) do
    case :ets.lookup(:"stream-1", name) do
      [{_, contents}] ->
        send_resp(conn, 200, contents)

      [] ->
        send_resp(conn, 404, "not found")
    end
  end
end
