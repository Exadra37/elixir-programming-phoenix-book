defmodule Rumbl.Permalink do

  @moduledoc """
  This module is a custom type defined according to the Ecto.Type bahaviour, thus it expects us to define 4 funtions:
    * type
    * cast
    * dump
    * load
  """

  @behaviour Ecto.Type

  @doc """
  Returns the underlying Ecto.Type. In this case, we are building on top of :id.
  """
  def type do
    :id
  end

  @doc """
  Called when external data is passed into Ecto.
  It's invoked when values in queries are interpolated.
  Also invoked by the cast function in changesets.

  We only parse an integer values if is in the start of the binary, otherwise we return an :error.

  Examples:

    iex> Rumbl.Permalink.cast "13-hello-world"
    {:ok, 13}

    iex> Rumbl.Permalink.cast "hello-world-13"
    :error
  """
  def cast(binary) when is_binary(binary) do

    case Integer.parse(binary) do

      {int, _} when int > 0 -> {:ok, int}
      _ -> :error

    end

  end

  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def cast(_) do
    :error
  end

  @doc """
  Invoked when data is sent to the database.
  """
  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  @doc """
  Invoked when data is loaded from database
  """
  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end

end