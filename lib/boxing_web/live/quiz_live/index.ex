defmodule BoxingWeb.QuizLive.Index do
  use BoxingWeb, :live_view
  alias Phoenix.PubSub

  alias Boxing.Prompts
  alias Boxing.Votes

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Boxing.PubSub, "predictions")
    end

    %{text_prompt: text_prompt, prompts: prompts} = Prompts.get_random_submission()

    {:ok,
     socket
     |> assign(
       show_results: false,
       prefight: true,
       round_winner: nil,
       winner: nil,
       text_prompt: text_prompt,
       prompts: prompts,
       vote_emojis: [],
       progress: 0,
       score: [
         %{human_name: "🦙 Llama 2", model: "llama13b-v2-chat", score: 0},
         %{human_name: "🤖 GPT 3.5", model: "gpt-3.5-turbo", score: 0}
       ],
       winning_score: 3
     )}
  end

  def handle_event("start", _, socket) do
    {:noreply, socket |> assign(prefight: false) |> push_event("ring", %{})}
  end

  def handle_event("select", %{"id" => id, "submission-id" => submission_id}, socket) do
    prompt = Prompts.get_prompt!(id)
    {:ok, vote} = Votes.create_vote(%{prompt_id: id, submission_id: submission_id})

    new_score =
      socket.assigns.score
      |> Enum.map(fn %{model: model, score: score, human_name: human_name} ->
        if model == prompt.model do
          %{model: model, score: score + 1, human_name: human_name}
        else
          %{model: model, score: score, human_name: human_name}
        end
      end)

    emoji =
      case prompt.model do
        "gpt-3.5-turbo" -> "🤖"
        "llama13b-v2-chat" -> "🦙"
      end

    winner =
      new_score
      |> Enum.filter(fn %{score: score} -> score >= socket.assigns.winning_score end)
      |> Enum.at(0)

    if is_nil(winner) do
      send(self(), :tick)
    end

    {:noreply,
     socket
     |> assign(progress: 0)
     |> assign(round_winner: prompt)
     |> assign(score: new_score)
     |> assign(show_results: true)
     |> assign(snarky_response: snark(prompt.model))
     |> assign(vote_emojis: socket.assigns.vote_emojis ++ [emoji])
     |> assign(winner: winner)
     |> push_event("confetti", %{winner: prompt.model})}
  end

  def handle_event("next", _, socket) do
    send(self(), :next)
    {:noreply, socket}
  end

  def handle_info(:next, socket) do
    %{text_prompt: text_prompt, prompts: prompts} = Prompts.get_random_submission()

    {:noreply,
     socket
     |> assign(show_results: false)
     |> assign(progress: 0)
     |> assign(submitted: false)
     |> assign(prompts: prompts)
     |> assign(round_winner: nil)
     |> assign(text_prompt: text_prompt)
     |> push_event("ring", %{})}
  end

  def handle_info(:tick, socket) do
    new_progress = socket.assigns.progress + 1000

    if new_progress <= 3000 do
      Process.send_after(self(), :tick, 1000)
    else
      send(self(), :next)
    end

    {:noreply, assign(socket, progress: new_progress)}
  end

  def handle_event("inspire", _, socket) do
    text_prompt = Prompts.get_random_prompt()
    {:noreply, socket |> assign(text_prompt: text_prompt)}
  end

  def handle_event("update-prompt", %{"prompt" => prompt}, socket) do
    {:noreply, assign(socket, text_prompt: prompt)}
  end

  def handle_event("generate", %{"prompt" => prompt}, socket) do
    submission_id = Ecto.UUID.generate()

    # Prepare a list for collected prompts
    prompt_list = Agent.start_link(fn -> [] end, name: :prompt_list)

    spawn(fn ->
      for model <- ["gpt-3.5-turbo", "llama13b-v2-chat"] do
        prompt = write(%{model: model, prompt: prompt, submission_id: submission_id})

        # Instead of broadcasting the prompt right away, we add it to the list of collected prompts
        Agent.update(:prompt_list, fn prompts -> [prompt | prompts] end)

        if length(Agent.get(:prompt_list, & &1)) == 2 do
          # When all prompts are collected, then broadcast
          PubSub.broadcast(
            Boxing.PubSub,
            "predictions",
            {:generated, Agent.get(:prompt_list, & &1)}
          )

          # Stop the Agent
          Agent.stop(:prompt_list)
        end
      end
    end)

    {:noreply, socket |> assign(loading: true) |> assign(submitted: true)}
  end

  def handle_info({:generated, prompts}, socket) do
    {:noreply, assign(socket, prompts: prompts, loading: false)}
  end

  def write(%{model: "llama13b-v2-chat", prompt: raw_prompt, submission_id: submission_id}) do
    model = Replicate.Models.get!("a16z-infra/llama13b-v2-chat")
    version = Replicate.Models.get_latest_version!(model)

    prompt = "User: #{raw_prompt}\nAssistant:"

    {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: prompt})
    {:ok, prediction} = Replicate.Predictions.wait(prediction)

    result = Enum.join(prediction.output)

    {:ok, start, _} = DateTime.from_iso8601(prediction.started_at)
    {:ok, completed, _} = DateTime.from_iso8601(prediction.completed_at)

    DateTime.diff(start, completed, :second) |> abs() |> IO.inspect(label: "Time")

    {:ok, prompt} =
      Prompts.create_prompt(%{
        prompt: raw_prompt,
        completion: result,
        model: "llama13b-v2-chat",
        version: version.id,
        time: DateTime.diff(start, completed, :second) |> abs(),
        submission_id: submission_id
      })

    prompt
  end

  def write(%{model: "gpt-3.5-turbo", prompt: prompt, submission_id: submission_id}) do
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

    {:ok, prompt} =
      Prompts.create_prompt(%{
        prompt: prompt,
        completion: content,
        model: "gpt-3.5-turbo",
        version: "gpt-3.5-turbo",
        time: System.convert_time_unit(end_time - start_time, :native, :second) |> abs(),
        submission_id: submission_id
      })

    prompt
  end
end
