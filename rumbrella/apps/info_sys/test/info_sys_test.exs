defmodule InfoSysTest do

  use ExUnit.Case

  alias InfoSys.Result

  doctest InfoSys

  # TODO: Do not stub the entire backend but only the code responsible to fetch
  #       the url.
  #
  # WHY:
  #
  # → Stub an entire backend to be able to perform an integration test on the
  #   Information System is half testing it...
  # → A best approach is to create a generic module to fecth urls and then stub
  #   or mock it.
  # → The stub is not at all a real representation of the backend, it feels more
  #   like an hack to make testing easier, once we use 2 functions fetch/2 while
  #   the real implementation only use 1 function fetch/2.
  defmodule TestBackend do

    def start_link(query, ref, owner, limit) do
      Task.start_link(__MODULE__, :fetch, [query, ref, owner, limit])
    end

    def fetch("result", ref, owner, _limit) do
      send(owner, {:results, ref, [%Result{backend: "test", text: "result"}]})
    end

    def fetch("none", ref, owner, _limit) do
      send(owner, {:results, ref, []})
    end

    def fetch("timeout", _ref, owner, _limit) do
      send(owner, {:backend, self()})
      :timer.sleep(:infinity)
    end

    def fetch("boom", _ref, _owner, _limit) do
      raise "boom!"
    end

  end

  ####
  #
  # TODO: this tests do not reflect at all how we use the InfoSys.compute/2 Api.
  #
  # WHY:
  #  → the way we call the compute/2 looks like we do it by action, not as in a
  #    real usage, where the first argument is a question that we want to know
  #    a response for.
  #  → as the author of the book recognizes, this is chaeting, thus in my point
  #    of view it defeats the purpose of testing.
  #
  ####

  test "compute/2 with backend results" do

    expected_result = [%Result{backend: "test", text: "result"}]

    result =  InfoSys.compute("result", backends: [TestBackend])

    assert expected_result == result

  end

  test "compute/2 with no backend results" do

    assert [] = InfoSys.compute("none", backends: [TestBackend])

  end

  test "compute/2 with timeout returns no results and kills workers" do

    # Tests that no results are returned on a timeout of the backend process.
    results = InfoSys.compute("timeout", backends: [TestBackend], timeout: 10)
    assert results == []

    # Tests the backend sends the message with is Pid to be used by a monitor.
    assert_receive {:backend, backend_pid}
    ref = Process.monitor(backend_pid)

    # Tests the backend process is killed when reaches the timeout
    # assert_receive waits 100ms by default until it fails the test.
    assert_receive {:DOWN, ^ref, :process, _pid, _reason}

    # Tests InfoSys cleanup code works after a timeout is received.
    # Once we already know our backend is down we use refute_received instead
    # of refute_receive, because the later waits 100ms before it fails the test.
    refute_received {:DOWN, _, _, _, _}
    refute_received :timeout

  end

  @tag :capture_log
  test "compute/2 discards backend errors" do

    assert InfoSys.compute("boom", backends: [TestBackend]) == []

    refute_received {:DOWN, _, _, _, _}
    refute_received {:timeout}

  end

end
