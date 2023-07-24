defmodule Boxing.Prompts do
  @moduledoc """
  The Prompts context.
  """

  import Ecto.Query, warn: false
  alias Boxing.Repo

  alias Boxing.Prompts.Prompt

  @doc """
  Creates a question(s) with GPT-4.

  Returns a list of [question, question, ...]
  """
  def create_questions() do
    {:ok, %{choices: [%{"message" => %{"content" => content}} | _]}} =
      OpenAI.chat_completion(
        model: "gpt-4",
        messages: [
          %{
            role: "system",
            content:
              "You are a helpful bot that creates questions for comparing language models. Be creative! Just give me the question, and I'll do the rest."
          },
          %{
            role: "user",
            content: """
            I'm creating an app that compares large language model completions. Can you write me some prompts I can use to compare them? They should be in a wide range of topics. For example, here are some I have already:

            Example outputs:
            How are you today?
            My wife wants me to pick up some Indian food for dinner. I always get the same things - what should I try?
            How much wood could a wood chuck chuck if a wood chuck could chuck wood?
            What's 3 x 5 / 10 + 9
            I really like the novel Anathem by Neal Stephenson. Based on that book, what else might I like?

            Can you give me another? Just give me the question. Separate outputs with a \n. Do NOT include numbers in the output. Do NOT start your response with something like "Sure, here are some additional prompts spanning a number of different topics:". Just give me the questions.
            """
          }
        ]
      )

    content |> String.split("\n")
  end

  @doc """
  Given a question, assigns it a subission ID, answers it with Llama 70B and GPT-3.5,
  and save to DB.
  """
  def generate(question) do
    submission_id = Ecto.UUID.generate()

    for model <- ["gpt-3.5-turbo", "llama70b-v2-chat"] do
      {:ok, prompt} = write(%{model: model, question: question, submission_id: submission_id})
    end
  end

  def write(%{model: "llama70b-v2-chat", question: raw_prompt, submission_id: submission_id}) do
    model = Replicate.Models.get!("replicate/llama70b-v2-chat")
    version = Replicate.Models.get_latest_version!(model)

    prompt = "User: #{raw_prompt}\nAssistant:"

    {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: prompt})
    {:ok, prediction} = Replicate.Predictions.wait(prediction)

    result = Enum.join(prediction.output)

    {:ok, start, _} = DateTime.from_iso8601(prediction.started_at)
    {:ok, completed, _} = DateTime.from_iso8601(prediction.completed_at)

    DateTime.diff(start, completed, :second) |> abs() |> IO.inspect(label: "Time")

    IO.puts("Generated Output: #{result} for Model: #{model.name}")

    create_prompt(%{
      prompt: raw_prompt,
      completion: result,
      model: "llama70b-v2-chat",
      version: version.id,
      time: DateTime.diff(start, completed, :second) |> abs(),
      submission_id: submission_id
    })
  end

  def write(%{model: "gpt-3.5-turbo", question: prompt, submission_id: submission_id}) do
    start_time = System.monotonic_time()

    messages = [
      %{role: "user", content: prompt}
    ]

    {:ok, %{choices: [%{"message" => %{"content" => content}}]}} =
      OpenAI.chat_completion(
        model: "gpt-3.5-turbo",
        messages: messages
      )

    end_time = System.monotonic_time()

    create_prompt(%{
      prompt: prompt,
      completion: content,
      model: "gpt-3.5-turbo",
      version: "gpt-3.5-turbo",
      time: System.convert_time_unit(end_time - start_time, :native, :second) |> abs(),
      submission_id: submission_id
    })
  end

  @doc """
  Count prompts.
  """
  def count_prompts() do
    from(p in Prompt) |> Repo.aggregate(:count)
  end

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

  def get_submission(submission_id) do
    unique_prompt =
      from(p in Prompt, where: p.submission_id == ^submission_id) |> Repo.all() |> Enum.at(0)

    # Get all prompts with the random submission_id
    prompts =
      Prompt
      |> where([p], p.submission_id == ^submission_id)
      |> Repo.all()
      |> Enum.shuffle()

    # Return a map with the unique prompt and all associated prompts
    %{
      text_prompt: unique_prompt.prompt,
      prompts: prompts,
      submission_id: unique_prompt.submission_id
    }
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
        |> Enum.shuffle()

      # Return a map with the unique prompt and all associated prompts
      %{
        text_prompt: unique_prompt.prompt,
        prompts: prompts,
        submission_id: unique_prompt.submission_id
      }
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
