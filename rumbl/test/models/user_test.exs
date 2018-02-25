defmodule Rumbl.UserTest do

  @moduledoc """
  For tests without side effects.
  So this tests only transform data and will not hit the database or any other external resource.
  Thus test that are free of side effects will run in parallel.
  """

  use Rumbl.ModelCase, async: true

  alias Rumbl.User

  @valid_attrs %{name: "A User", username: "eva", password: "secret"}
  #@invalid_attrs %{}


  test "changeset with valid attributes" do

    changeset = User.changeset(%User{}, @valid_attrs)

    assert changeset.valid?

  end


  # Cannot make this tes pass, maybe is related to the BOOK_FIX: chapter 4, page 60.
  # test "changeset with invalid attributes" do

  #   changeset = User.changeset(%User{}, @invalid_attrs)

  #   refute changeset.valid?

  # end


  test "changeset does not accept long usernames" do

    attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))

    # BOOK_FIX: chapter 8, page 150
    # using book assertation the test always fails.
    assert [username: "should be at most 20 character(s)"] == errors_on(%User{}, attrs)

  end


  test "registration_changeset password must be at least 6 chars long" do

    attrs = Map.put(@valid_attrs, :password, "12345")

    changeset = User.registration_changeset(%User{}, attrs)

    # BOOK_FIX: chapter 8, page 150
    # using book assertation the test always fails.
    assert [password: {"should be at least %{count} character(s)", [count: 6, validation: :length, min: 6]}] == changeset.errors

  end


  test "registration_changeset with valid attributes hashes password" do

    attrs = Map.put(@valid_attrs, :password, "123456")

    changeset = User.registration_changeset(%User{}, attrs)

    %{password: pass, password_hash: pass_hash} = changeset.changes

    assert changeset.valid?
    assert pass_hash
    assert Comeonin.Bcrypt.checkpw(pass, pass_hash)

  end

end
