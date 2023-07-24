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
       prefight: false,
       round_winner: nil,
       winner: nil,
       text_prompt: text_prompt,
       prompts: prompts,
       vote_emojis: [],
       progress: 0,
       score: [
         %{human_name: "🦙 Llama 2", model: "llama70b-v2-chat", health: 10},
         %{human_name: "🤖 GPT 3.5", model: "gpt-3.5-turbo", health: 10}
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
      |> Enum.map(fn %{model: model, health: health, human_name: human_name} ->
        if model != prompt.model do
          %{model: model, health: health - 1, human_name: human_name}
        else
          %{model: model, health: health, human_name: human_name}
        end
      end)

    emoji =
      case prompt.model do
        "gpt-3.5-turbo" -> "🦙 ✅"
        "llama70b-v2-chat" -> "🤖 ✅"
      end

    winner =
      new_score
      |> Enum.filter(fn %{health: health} -> health == 0 end)
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

    if new_progress <= 4000 do
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
end
