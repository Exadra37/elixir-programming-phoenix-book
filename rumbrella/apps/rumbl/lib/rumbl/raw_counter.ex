defmodule Rumbl.RawCounter do

  @moduledoc """
  The Counter Server and the Api Client.

  This module is composed by the Counter server and the public Api to interact
  with it.
  """

  #
  # THE CLIENT
  #

  @doc """
  Client public api to interact with the Counter server to increase is value.

  When we call this function we will send a message to the Counter server,
  identified by the process id(pid), saying with the atom :inc that we want
  to increment the state it olds on "val" by one.

  This is a fire and forget operation, once we do not wait for the reply to the
  message we sent.

  The message we sent will be processed by listen() function.

  ## Example usage:

    iex> value = 0
    0
    iex> {:ok, pid} = Rumbl.RawCounter.start_link(value)
    {:ok, #PID<0.297.0>}
    iex>  Rumbl.RawCounter.inc(pid)
    :inc
    iex> Rumbl.RawCounter.val(pid)
    1
    iex(14)> value
    0
  """
  def inc(pid) do
    send(pid, :inc)
  end

  @doc """
  Client public api to interact with the Counter server to decrease is value.

  When we call this function we will send a message to the Counter server,
  identified by the process id(pid), saying with the atom :dec that we want
  to decrease the state it olds on "val" by one.

  This is a fire and forget operation, once we do not wait for the reply to the
  message we sent.

  The message we sent will be processed by listen() function.

  ## Example usage:

    iex> value = 0
    0
    iex> {:ok, pid} = Rumbl.RawCounter.start_link(value)
    {:ok, #PID<0.305.0>}
    iex>  Rumbl.RawCounter.dec(pid)
    :dec
    iex> Rumbl.RawCounter.val(pid)
    -1
    iex> value
    0

  """
  def dec(pid) do
    send(pid, :dec)
  end

  @doc """
  Client public api to return the current valeu of the Counter.

  Here we see how we can leverage message passing to retrieve mutable state in
  an immutable world.

  Using an unique reference for each message we sent we then wait for a reply
  matching that same unique reference, that will containe the current values of
  the Counter.

  So waiting for the reply to the message means a synchronust
  operation, thus the runtime execution will stay blocked in the receive block
  until we receive the reply or achieve the timeotu.

  More details how the Counter value is handled can be found in the documentation
  for listen() function.

  ## Example usage:

    iex> value = 0
    0
    iex> {:ok, pid} = Rumbl.RawCounter.start_link(value)
    {:ok, #PID<0.316.0>}
    iex> Rumbl.RawCounter.val(pid)
    0

  """
  def val(pid, timeout \\ 5000) do

    # Creates a unique reference accross the entire system, that will be used to
    # identify each message we sent and makes possible to match later any reply
    # to it.
    ref = make_ref()

    # this will be handled by listen() function on the receive block
    #  {:val, sender, ref} match
    send(pid, {:val, self(), ref})

    receive do
      # waits for the reply to the above sent message to listen() function.
      # will  receive the current value assigned to var `val` in the listen()
      #  function.
      {^ref, val} -> val
    after timeout -> exit(:timeout)
    end

  end

  @doc """
  All servers require this function to be present.

  This is the Server public api that is the entrypoint for this module
  where we will start our server by spawning a process that will return
  is PID.

  The spawned process sets the initial value for the Counter by calling the
  recursive function listen() with the initial value for variable `val`.

  So the Server will be wrapped inside the recursive listen() function and
  then we will use the send() function from the Client Api functions to talk
  with the server.

  ## Example Usage

    iex> value = 0
    0
    iex> {:ok, pid} = Rumbl.RawCounter.start_link(value)
    {:ok, #PID<0.324.0>}
  """
  def start_link(initial_val) do
    {:ok, spawn_link(fn -> listen(initial_val) end)}
  end


  #
  # THE SERVER
  #

  # The Server only as a private api that is used by the above function start_link().
  #
  # This function will work recursively in order to listen to all messages sent
  # to increase or decrease the counter value and to retrieve the current value.

  # So each time this function receives a message from one of the public funtions
  # of the Counter it will perform the correspondent asociated actions and call
  # itself again with the uptaded value for the counter.

  # To note that in the :val match the listener does not return directly a reply
  # to the sender of the request, instead it sends back a message to the sender
  # with a reply that contains the Counter value and the unique reference for
  # the message it received from the sender, therefore this is an assynchronous
  # operation.

  # Using message passing and recursion is what allows us to mutate the Counter
  # value and keep track of it in an immutable world.
  defp listen(val) do

    receive do

      # listen to calls from above function inc()
      :inc -> listen(val + 1)

      # listen to calls from above function dec().
      :dec -> listen(val - 1)

      # listens to calls from above function val() and sends back a message with
      #  the current value assigned to variable `val`.
      {:val, sender, ref} ->
        send sender, {ref, val}
        listen(val)
    end

  end

end