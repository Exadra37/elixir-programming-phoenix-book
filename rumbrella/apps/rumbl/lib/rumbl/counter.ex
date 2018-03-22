defmodule Rumbl.Counter do

  use GenServer

  @moduledoc """
  This module is composed by the Counter server and the public Api to interact
  with it.

  Here we will use the OTP GenServer to handle the server for us, instead of
  building ourselfes it, like we did in counter.ex.
  """

  #
  # THE CLIENT
  #

  @doc """
  Client public api to interact with the Counter server to increase is value.

  ## Example usage:

    iex> value = 0
    0
    iex> {:ok, pid} = Rumbl.Counter.start_link(value)
    {:ok, #PID<0.297.0>}
    iex>  Rumbl.Counter.inc(pid)
    :inc
    iex> Rumbl.Counter.val(pid)
    1
    iex(14)> value
    0
  """
  def inc(pid) do
    GenServer.cast(pid, :inc)
  end

  @doc """
  Client public api to interact with the Counter server to decrease is value.

  ## Example usage:

    iex> value = 0
    0
    iex> {:ok, pid} = Rumbl.Counter.start_link(value)
    {:ok, #PID<0.305.0>}
    iex>  Rumbl.Counter.dec(pid)
    :dec
    iex> Rumbl.Counter.val(pid)
    -1
    iex> value
    0
  """
  def dec(pid) do
    GenServer.cast(pid, :dec)
  end

  @doc """
  Client public api to return the current value of the Counter.

  ## Example usage:

    iex> value = 0
    0
    iex> {:ok, pid} = Rumbl.Counter.start_link(value)
    {:ok, #PID<0.316.0>}
    iex> Rumbl.Counter.val(pid)
    0

  """
  def val(pid) do
    GenServer.call(pid, :val)
  end


  @doc """
  Client API to start the OTP server.

  ## Example Usage

    iex> value = 0
    0
    iex> {:ok, pid} = Rumbl.Counter.start_link(value)
    {:ok, #PID<0.324.0>}
  """

  def start_link(initial_val) do
    GenServer.start_link(__MODULE__, initial_val)
  end


  #
  # THE OTP SERVER
  #

  def init(initial_val) do
    Process.send_after(self(), :tick, 1000)
    {:ok, initial_val}
  end

  def handle_info(:tick, val) when val <= 0 do
    raise "boom!"
  end

  def handle_info(:tick, val) do
    IO.puts "tick #{val}"
    Process.send_after(self(), :tick, 1000)
    {:noreply, val - 1}
  end

  def handle_cast(:inc, val) do
    {:noreply, val + 1}
  end

  def handle_cast(:dec, val) do
    {:noreply, val - 1}
  end

  def handle_call(:val, _from, val) do
    {:reply, val, val}
  end

end