defmodule Rumbl.Video do
  use Rumbl.Web, :model
require IEx
  schema "videos" do
    field :url, :string
    field :title, :string
    field :description, :string
    belongs_to :user, Rumbl.User
    belongs_to :category, Rumbl.Category

    timestamps()
  end

  @required_fields [:url, :title, :description]
  @optional_fields [:category_id]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do

    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields, @optional_fields)
    |> assoc_constraint(:category)

  end
end