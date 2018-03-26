defmodule InfoSys.Wolfram do

  @moduledoc """
  # Rumb Information System Wolfram Backend

  Queries the [Wolfram API](http://api.wolframalpha.com/v2/query) to retrieve all results for the given query.
  """

  import SweetXml

  alias InfoSys.Result

  @doc """
  ## Entrypoint for the Supervisor

  This call comes from InfoSys.start_link/5, that is triggered when in
  InfoSys.spawn_query/3 we start this backend as a child worker as per
  defined in InfoSys.Supervisor/init/1.

  As result a Task is launched to handle the query against the Wolfram Api and
  we tell to that Task to use the fetch/4 of this module to perform it.
  """
  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  @doc """
  ## Entrypoint for the Task

  This is called by the Task we invoked in start_link/4.

  We will query the Wolfram Api and fetch their xml response, parse it and send
  a message to InfoSys.await_result/3 with the parsed results.
  """
  def fetch(query_str, query_ref, owner, _limit) do

    query_str
    |> fech_xml()
    |> xpath(~x"/queryresult/pod[contains(@title, 'Result') or contains(@title, 'Definitions')]/subpod/plaintext/text()")
    |> send_results(query_ref, owner)

  end

  defp send_results(nil, query_ref, owner) do
    send(owner, {:results, query_ref, []})
  end

  defp send_results(answer, query_ref, owner) do
    results = [%Result{backend:  "wolfram", score: 95, text: to_string(answer)}]
    send(owner, {:results, query_ref, results})
  end

  defp fech_xml(query_str) do

    text = "http://api.wolframalpha.com/v2/query" <> "?appid=#{app_id()}" <> "&input=#{URI.encode(query_str)}&format=plaintext"

    payload = String.to_char_list(text)

    # TODO: fetching the url MUST NOT be a responsability of this module.
    #
    # WHY:
    #  → we are violating the Single Responsability Principle from SOLID code.
    #  → makes testing this module impossible, unless we want to violate our
    #    system boundaries, that we MUST never do.
    {:ok, {_, _, body}} = :httpc.request(payload)

    body

  end

  defp app_id() do
    Application.get_env(:info_sys, :wolfram)[:app_id]
  end

end