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
       text_prompt: text_prompt,
       prompts: prompts,
       show_results: false,
       prefight: false,
       round_winner: nil,
       score: [
         %{human_name: "🦙 Llama 2", model: "llama13b-v2-chat", score: 0},
         %{human_name: "🤖 GPT 3.5", model: "gpt-3.5-turbo", score: 0}
       ]
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
      |> Enum.map(fn %{model: model, score: score} ->
        if model == prompt.model do
          %{model: model, score: score + 1}
        else
          %{model: model, score: score}
        end
      end)

    {:noreply,
     socket
     |> assign(round_winner: prompt)
     |> assign(score: new_score)
     |> assign(show_results: true)
     |> assign(snarky_response: "nice")
     |> push_event("confetti", %{winner: prompt.model})}
  end

  def handle_event("next", _, socket) do
    {:noreply,
     socket
     |> assign(show_results: false)
     |> assign(round_winner: nil)
     |> push_event("ring", %{})}
  end

  def handle_event("generate", %{"prompt" => prompt}, socket) do
    submission_id = Ecto.UUID.generate()

    spawn(fn ->
      for model <- ["gpt-3.5-turbo", "llama13b-v2-chat"] do
        prompt = write(%{model: model, prompt: prompt, submission_id: submission_id})
        PubSub.broadcast(Boxing.PubSub, "predictions", {:generated, model, prompt})
      end
    end)

    {:noreply, socket |> assign(prompts: [], text_prompt: prompt)}
  end

  def handle_info({:generated, model, prompt}, socket) do
    {:noreply, update(socket, :prompts, &[prompt | &1])}
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
      |> IO.inspect(label: "")

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
