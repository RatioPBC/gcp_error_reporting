defmodule GcpErrorReporting.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Rely on Goth auto-config: https://hexdocs.pm/goth/readme.html#installation
      {Goth, name: GcpErrorReporting.Goth}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GcpErrorReporting.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
