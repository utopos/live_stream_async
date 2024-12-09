defmodule LiveStreamAsync.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_stream_async,
      version: "0.1.2",
      elixir: ">= 1.16.1",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [ignore_module_conflict: true],
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "LiveStreamAsync",
      description: "LivewView: assigns stream keys asynchronously with stream_async/4 macro.",
      package: package(),
      source_url: "https://github.com/utopos/live_stream_async",
      docs: [
        # The main page in the docs
        main: "LiveStreamAsync",
        extras: ["README.md"]
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, ">= 0.20.0"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:phoenix_playground, "~> 0.1.6", only: :test, runtime: false}
    ]
  end

  def package() do
    [
      maintainers: ["Jakub Lambrych"],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/utopos/live_stream_async"
      }
    ]
  end
end
