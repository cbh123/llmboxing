defmodule Boxing.Prompts do
  @moduledoc """
  The Prompts context.
  """

  import Ecto.Query, warn: false
  alias Boxing.Repo

  alias Boxing.Prompts.Prompt

  @doc """
  Vote.
  """
  def vote(id) do
    prompt = Repo.get!(Prompt, id)
    prompt = Prompt.changeset(prompt, %{votes: prompt.votes + 1})
    Repo.update!(prompt)
  end

  @doc """
  Get random prompt.
  """
  def get_random_prompt() do
    from(p in Prompt, order_by: fragment("RANDOM()"), limit: 1, select: p.prompt) |> Repo.one()
  end

  @doc """
  Get random submission.
  """
  def get_random_submission() do
    # Define a subquery to get a random submission_id
    subquery =
      from(p in Prompt,
        order_by: fragment("RANDOM()"),
        limit: 1
      )

    # Get the random submission_id
    unique_prompt = Repo.one(subquery)

    if unique_prompt == nil do
      %{text_prompt: "No submissions yet!", prompts: []}
    else
      # Get all prompts with the random submission_id
      prompts =
        Prompt
        |> where([p], p.submission_id == ^unique_prompt.submission_id)
        |> Repo.all()

      # Return a map with the unique prompt and all associated prompts
      %{text_prompt: unique_prompt.prompt, prompts: prompts}
    end
  end

  @doc """
  Returns the list of prompt.

  ## Examples

      iex> list_prompt()
      [%Prompt{}, ...]

  """
  def list_prompts do
    Repo.all(Prompt)
  end

  @doc """
  Gets a single prompt.

  Raises `Ecto.NoResultsError` if the Prompt does not exist.

  ## Examples

      iex> get_prompt!(123)
      %Prompt{}

      iex> get_prompt!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prompt!(id), do: Repo.get!(Prompt, id)

  @doc """
  Creates a prompt.

  ## Examples

      iex> create_prompt(%{field: value})
      {:ok, %Prompt{}}

      iex> create_prompt(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prompt(attrs \\ %{}) do
    %Prompt{}
    |> Prompt.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prompt.

  ## Examples

      iex> update_prompt(prompt, %{field: new_value})
      {:ok, %Prompt{}}

      iex> update_prompt(prompt, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prompt(%Prompt{} = prompt, attrs) do
    prompt
    |> Prompt.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a prompt.

  ## Examples

      iex> delete_prompt(prompt)
      {:ok, %Prompt{}}

      iex> delete_prompt(prompt)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prompt(%Prompt{} = prompt) do
    Repo.delete(prompt)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prompt changes.

  ## Examples

      iex> change_prompt(prompt)
      %Ecto.Changeset{data: %Prompt{}}

  """
  def change_prompt(%Prompt{} = prompt, attrs \\ %{}) do
    Prompt.changeset(prompt, attrs)
  end
end
