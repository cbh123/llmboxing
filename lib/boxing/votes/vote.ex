defmodule Boxing.Votes.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :prompt_id, :id
    field :submission_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:prompt_id, :submission_id])
    |> validate_required([])
  end
end
