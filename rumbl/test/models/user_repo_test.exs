defmodule Rumbl.UserRepoTest do

  @moduledoc """
  For tests WITH side effects.
  So this tests will hit the database or other external resources.
  Thus test with side effect WILL NOT run in parallel.
  """

  use Rumbl.ModelCase

  alias Rumbl.User

  @valid_attrs %{name: "A User", username: "eva"}


  test "converst uniquer_constraint on username to error" do

    insert_user(username: "eric")

    attrs = Map.put(@valid_attrs, :username, "eric")

    changeset = User.changeset(%User{}, attrs)

    assert {:error, changeset} = Repo.insert(changeset)

    # BOOK_FIX: chapter 8, page 152
    # using book assertation the test always fails.
    assert [username: {"has already been taken", []}] == changeset.errors

  end

end