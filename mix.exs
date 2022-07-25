defmodule GcpErrorReporting.MixProject do
  use Mix.Project

  def project do
    [
      app: :gcp_error_reporting,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:dialyxir, "~> 1.2", only: :dev},
      {:google_api_cloud_error_reporting, "~> 0.19"},
      {:goth, "~> 1.3"},
      {:mox, "~> 1.0", only: :test}
    ]
  end
end
