defmodule Noven.DevicePresence do
  use Phoenix.Presence,
    otp_app: :noven,
    pubsub_server: Noven.PubSub

  def fetch("devices", entries) do
    for {key, entry} <- entries, into: %{}, do: {key, merge_metas(entry)}
  end

  def fetch(_, entries), do: entries

  @allowed_fields [:pipeline, :ssrc]

  defp merge_metas(%{metas: metas}) do
    # The most current meta is head of the list so we
    # accumulate that first and merge everthing else into it
    Enum.reduce(metas, %{}, &Map.merge(&1, &2))
    |> Map.take(@allowed_fields)
  end

  defp merge_metas(unknown), do: unknown
end
