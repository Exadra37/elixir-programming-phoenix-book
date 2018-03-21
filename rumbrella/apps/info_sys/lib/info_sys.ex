defmodule InfoSys do

  @moduledoc """
  # Rumbl Information System

  Will manage several backends that query external API's.


  ## Simplified Overview

  $ iex -S mix
    -> Rumbl
        -> InfoSys.Supervisor.start_link/0

    -> iex> InfoSys.compute("what is elixir?")
      -> InfoSys.compute/2
        -> InfoSys.spawn_query/3
            -> InfoSys.Supervisor.init/1
                -> InfoSys.start_link/5
                    -> InfoSys.Wolfram.start_link/4
                        -> InfoSys.Wolfram.fetch/4
            -> InfoSys.await_results/2
                -> InfoSys.await_result/3 <-
  """

  @backends [
    InfoSys.Wolfram
  ]

  defmodule Result do
    defstruct score: 0, text: nil, url: nil, backend: nil
  end

  @doc """
  ## Implements Proxy for the Supervisor

  This a proxy to call the start_link defined in each @backends worker, like
  for example InfoSys.Wolfram.start/4.

  So whenever in spawn_query/3 the Supervisor starts a child, this function will
  be invoked.

  This will be called by the InfoSys.Supervisor.init/1 in order to  be
  able to start this children worker process.
  """
  def start_link(backend, query, query_ref, owner, limit) do
    backend.start_link(query, query_ref, owner, limit)
  end


  @doc """
  ## Entrypoint for our Information System.

  #### Example:

    cli-iex> InfoSys.compute("what is elixir?")
    [{#PID<0.582.0>, #Reference<0.0.1.9142>}]
    cli-iex> flush()
    {
      :results,
      #Reference<0.0.1.9142>,
      [
        %InfoSys.Result{
          backend: "wolfram",
          score: 95,
          text: "1 | noun | a sweet flavored liquid (usually containing a small amount of alcohol) used in compounding medicines to be taken by mouth in order to mask an unpleasant taste\n2 | noun | hypothetical substance that the alchemists believed to be capable of changing base metals into gold\n3 | noun | a substance believed to cure all ills",
          url: nil
        }
      ]
    }
    :ok
  """
  def compute(query, opts \\ []) do

    limit = opts[:limit] || 10

    backends = opts[:backends] || @backends

    backends
    |> Enum.map(&spawn_query(&1, query, limit))
    |> await_results(opts) # will walk recursively over all backends queries
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(limit)

  end

  # We will trigger from here the same query to all available backends.
  #
  # Each backend is triggered as a child worker process by the Supervisor as
  # it was registered in InfoSys.Supervisor.init/1.
  #
  # We will monitor each child process to ensure we will not get stuck forever
  # waiting for them to finish.
  defp spawn_query(backend, query, limit) do

    query_ref = make_ref()

    opts = [backend, query, query_ref, self(), limit]

    {:ok, pid} = Supervisor.start_child(InfoSys.Supervisor, opts)

    monitor_ref = Process.monitor(pid)

    {pid, monitor_ref, query_ref}

  end

  # This is invoked by compute/2 to wait for the results for the queries we
  # against all backends.
  #
  # This achieved by starting the recursion for await_result/3
  defp await_results(children, opts) do

    timeout = opts[:timeout] || 5000 # mile-seconds

    timer = Process.send_after(self(), :timeout, timeout)

    results = await_result(children, [], :infinity)

    cleanup(timer)

    results

  end

  # Processes recursively each backend query result.
  defp await_result([head|tail], acc, timeout) do

    {pid, monitor_ref, query_ref} = head

    receive do

      # The recursion of this function will end always with returning this tuple
      # containing the :results alongside the unique query reference associated
      # with them.
      {:results, ^query_ref, results} ->

        # Stop monitoring the query and uses :flush to guarantee that any
        # message related with monitoring this process is removed.
        Process.demonitor(monitor_ref, [:flush])

        # only ends recursion when this call matches: await_result([], acc, _)
        await_result(tail, results ++ acc, timeout)

      # The processor monitor we initiate in spawn_query/3 will send us a :DONW
      # message when the timeout is reached.
      {:DOWN, ^monitor_ref, :process, ^pid, _reason} ->

        # only ends recursion when this call matches: await_result([], acc, _)
        await_result(tail, acc, timeout)

      # When we start the recursion in await_results/2 we also set a timer to
      # send to this process a :timeout message after the given timeout is
      # reached.
      :timeout ->

        kill(pid, monitor_ref)

        # only ends recursion when this call matches: await_result([], acc, _)
        await_result(tail, acc, 0)

      after

        timeout ->

          kill(pid, monitor_ref)

          # only ends recursion when this call matches: await_result([], acc, _)
          await_result(tail, acc, 0)
    end

  end

  # Ends the recursion for await_result/3
  defp await_result([], acc, _) do
    acc
  end


  defp kill(pid, ref) do

    Process.demonitor(ref, [:flush])
    Process.exit(pid, :kill)

  end

  defp cleanup(timer) do

    :erlang.cancel_timer(timer)

    receive do
      # in case the :timeout message was already sent we need to flush it from
      # our inbox.
      :timeout -> :ok
    after
      # exit here means that no :timeout message was already in our inbox.
      0 -> :ok
    end

  end

end