defmodule LiveStreamAsync.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_stream_async,
      version: "0.1.0",
      elixir: ">= 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "LiveStreamAsync",
      description: "LivewView: assigns stream keys asynchronously with stream_async/4 macro.",
      package: package(),
      source_url: "https://github.com/utopos/live_stream_async",
      docs: [
        # The main page in the docs
        main: "LiveStreamAsync"
      ]
    ]
  end

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
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
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
