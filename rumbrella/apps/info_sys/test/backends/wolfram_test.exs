defmodule InfoSys.Backends.WolframTest do

  use ExUnit.Case, async: true

  alias InfoSys.Wolfram

  test "makes request, reports results, then terminates" do

    ref = make_ref()

    # As I ranted on the stub for the Http client, this approach of chaeting
    # in tests is pure non sense...
    #
    # This is not the semantics used to interact with the live system, thus
    # in my opinion this approach only reveals that the code is not correctly
    # archtitected, once needs cheating to be tested...
    {:ok, _} = Wolfram.start_link("1 + 1", ref, self(), 1)

    assert_receive {:results, ^ref, [%InfoSys.Result{text: "2"}]}
  end

end
