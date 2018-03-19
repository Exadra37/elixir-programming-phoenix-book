defmodule Rumbl do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Rumbl.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Rumbl.Endpoint, []),

      # The Supervisor will start a children Supervisor for our backend
      # Information System in Rumbl.InfoSys.Supervisor.start_link/0
      supervisor(Rumbl.InfoSys.Supervisor, [])

      # Start your own worker by calling: Rumbl.Worker.start_link(arg1, arg2, arg3)
      # worker(Rumbl.Worker, [arg1, arg2, arg3]),

      # We use a :temporary restart strategy that means when our worker crashes
      # it will not be restarted.
      #
      # To always restart it on crash we want to use :permanent instead, that is the default behaviour,
      # thus optional to be specified.
      #worker(Rumbl.Counter, [5], restart: :temporary),
      #worker(Rumbl.Counter, [5]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rumbl.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Rumbl.Endpoint.config_change(changed, removed)
    :ok
  end
end
