defmodule Noven.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Noven.Repo,
      # Start the Telemetry supervisor
      NovenWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Noven.PubSub},
      Noven.DevicePresence,
      {Registry, [keys: :unique, name: NovenMedia.NameRegistry]},
      NovenMedia.Supervisor,
      # Start the Endpoint (http/https)
      NovenWeb.Endpoint
      # Start a worker by calling: Noven.Worker.start_link(arg)
      # {Noven.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Noven.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NovenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
