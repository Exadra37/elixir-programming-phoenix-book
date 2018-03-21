defmodule InfoSys.Supervisor do

  @moduledoc """
  # Rumbl Information System Supervisor

  This is a children Supervisor that will be responsible to supervise all
  implemented backends for this Information System in module InfoSys.

  So as a children Supervisor it will need to implement the Supervisor
  behaviour by adhere to the required API contract:
    * start_link/0
    * init/1

  """
  use Supervisor

  @doc """
  ## Implements the Supervisor API Contract for start_link/0

  Required by the Supervisor we trigger in rumbl.ex to know how to to start this
  children Supervisor.

  This module will register it self as Supervisor, thus becoming a children
  Supervisor of Rumbl.start/2.
  """
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  ## Implements the Supervisor API contract for init/1

  Required by Supervisor to know how to initialize the workers that this
  children Supervisor will supervise.

  So init/1 will be called each time the Supervisor.start_child/2 is invoked,
  like we can see in InfoSys.spawn_query/3.
  """
  def init(_opts) do

    children = [

      # Using the :temporary strategy for restart:, means that when our worker
      # crashes we don't care about it, thus the Supervisor will not try to
      # restart our crashed worker.
      worker(InfoSys, [], restart: :temporary)
    ]

    # To surpervise the children We will use the strategy :simple_one_for_one
    # that does not start the children immediately as :one_for_one would, thus
    # we can control when we want to start the children workers, normmaly when
    # we are about to use them, like in InfoSys.spawn_query/3.
    supervise children, strategy: :simple_one_for_one

  end

end