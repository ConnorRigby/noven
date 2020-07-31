defmodule NovenMedia.ETSStorage do
  @moduledoc """
  `Membrane.HTTPAdaptiveStream.Storage` implementation that saves the stream to
  files locally.
  """
  @behaviour Membrane.HTTPAdaptiveStream.Storage

  @enforce_keys [:table]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          table: atom
        }

  @impl true
  def init(%__MODULE__{} = config), do: config

  @impl true
  def store(name, contents, _ctx, %__MODULE__{table: table}) do
    :ets.insert(table, {name, contents})
    :ok
  end

  @impl true
  def remove(name, _ctx, %__MODULE__{table: table}) do
    :ets.delete(table, name)
    :ok
  end
end
