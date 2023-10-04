defmodule Boxing.Votes do
  @moduledoc """
  The Votes context.
  """

  import Ecto.Query, warn: false
  alias Boxing.Repo

  alias Boxing.Votes.Vote
  alias Boxing.Prompts.Prompt

  @doc """
  Returns cumulative votes by model for a given fight.
  """
  def cumulative_votes_by_fight(fight_name) do
    vote_query =
      from(v in Vote,
        join: p in Prompt,
        on: p.id == v.prompt_id,
        select: %{model: p.model, inserted_at: v.inserted_at},
        where: p.fight_name == ^fight_name
      )

    from(v in subquery(vote_query),
      group_by: [fragment("date_trunc('hour', ?)", v.inserted_at), v.model],
      order_by: [fragment("date_trunc('hour', ?)", v.inserted_at), v.model],
      select: %{
        hour: fragment("date_trunc('hour', ?)", v.inserted_at),
        model: v.model,
        cumulative_votes: count(v.model)
      }
    )
    |> Repo.all()
  end

  @doc """
  Returns cumulative votes by model.
  """
  def cumulative_votes() do
    vote_query =
      from(v in Vote,
        join: p in Prompt,
        on: p.id == v.prompt_id,
        select: %{model: p.model, inserted_at: v.inserted_at}
      )

    from(v in subquery(vote_query),
      group_by: [fragment("date_trunc('hour', ?)", v.inserted_at), v.model],
      order_by: [fragment("date_trunc('hour', ?)", v.inserted_at), v.model],
      select: %{
        hour: fragment("date_trunc('hour', ?)", v.inserted_at),
        model: v.model,
        cumulative_votes: count(v.model)
      }
    )
    |> Repo.all()
  end

  @doc """
  Returns total count of each model's votes. Note we have to use a join to get model name.
  """
  def count_votes_by_fight(fight_name) do
    from(v in Vote,
      join: p in Prompt,
      on: p.id == v.prompt_id,
      group_by: p.model,
      where: p.fight_name == ^fight_name,
      select: %{model: p.model, count: count(v.id)}
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of votes.

  ## Examples

      iex> list_votes()
      [%Vote{}, ...]

  """
  def list_votes do
    Repo.all(Vote)
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id), do: Repo.get!(Vote, id)

  @doc """
  Creates a vote.

  ## Examples

      iex> create_vote(%{field: value})
      {:ok, %Vote{}}

      iex> create_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(attrs \\ %{}) do
    %Vote{}
    |> Vote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vote.

  ## Examples

      iex> update_vote(vote, %{field: new_value})
      {:ok, %Vote{}}

      iex> update_vote(vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vote(%Vote{} = vote, attrs) do
    vote
    |> Vote.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vote.

  ## Examples

      iex> delete_vote(vote)
      {:ok, %Vote{}}

      iex> delete_vote(vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vote changes.

  ## Examples

      iex> change_vote(vote)
      %Ecto.Changeset{data: %Vote{}}

  """
  def change_vote(%Vote{} = vote, attrs \\ %{}) do
    Vote.changeset(vote, attrs)
  end
end
