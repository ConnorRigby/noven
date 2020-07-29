defmodule Noven.MixProject do
  use Mix.Project

  def project do
    [
      app: :noven,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Noven.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.3"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.13.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:membrane_core, "~> 0.5.2"},
      {:membrane_element_udp, "~> 0.3.2"},
      {:membrane_element_file, "~> 0.3.0"},
      {:membrane_element_ffmpeg_h264, "~> 0.3.0"},
      {:membrane_scissors_plugin, "~> 0.1.0"},
      {:membrane_http_adaptive_stream_plugin, "~> 0.1.0"},
      {:membrane_aac_format, "~> 0.1.0"},
      {:membrane_mp4_plugin, "~> 0.3.0"},
      {:membrane_rtp_aac_plugin, "~> 0.1.0-alpha"},
      {:membrane_rtp_plugin, "~> 0.4.0-alpha"},
      {:membrane_rtp_h264_plugin, "~> 0.3.0-alpha"},
      {:membrane_element_tee, "~> 0.3.2"},
      {:membrane_element_fake, "~> 0.3"},
      {:membrane_loggers, "~> 0.3.0"},
      {:membrane_aac_plugin, "~> 0.4.0"},
      {:turbojpeg, "~> 0.2.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
