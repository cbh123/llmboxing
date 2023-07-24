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

    %{text_prompt: text_prompt, prompts: prompts, submission_id: submission_id} =
      Prompts.get_random_submission()

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
         %{human_name: "🦙 Llama", js_name: "llama", model: "llama70b-v2-chat", health: 5},
         %{human_name: "🤖 GPT 3.5", js_name: "gpt", model: "gpt-3.5-turbo", health: 5}
       ]
     )}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    %{text_prompt: text_prompt, prompts: prompts, submission_id: submission_id} =
      Prompts.get_submission(id)

    {:noreply,
     socket
     |> assign(show_results: false)
     |> assign(progress: 0)
     |> assign(submitted: false)
     |> assign(prefight: false)
     |> assign(prompts: prompts)
     |> assign(round_winner: nil)
     |> assign(text_prompt: text_prompt)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("start", _, socket) do
    %{text_prompt: text_prompt, prompts: prompts, submission_id: submission_id} =
      Prompts.get_random_submission()

    {:noreply,
     socket
     |> assign(prefight: false)
     |> push_patch(to: ~p"/question/#{submission_id}")
     |> push_event("ring", %{})}
  end

  def handle_event(
        "select",
        %{"id" => id, "submission-id" => submission_id},
        %{assigns: %{show_results: true}} = socket
      ) do
    {:noreply, socket}
  end

  def handle_event("select", %{"id" => id, "submission-id" => submission_id}, socket) do
    prompt = Prompts.get_prompt!(id)
    {:ok, vote} = Votes.create_vote(%{prompt_id: id, submission_id: submission_id})

    new_score =
      socket.assigns.score
      |> Enum.map(fn %{model: model} = score ->
        if model != prompt.model do
          %{score | health: score.health - 1}
        else
          score
        end
      end)

    emoji =
      case prompt.model do
        "gpt-3.5-turbo" -> "🦙"
        "llama70b-v2-chat" -> "🤖"
      end

    winner =
      new_score
      |> Enum.filter(fn %{health: health} -> health == 0 end)
      |> Enum.at(0)

    {:noreply,
     socket
     |> assign(progress: 0)
     |> assign(round_winner: prompt)
     |> assign(score: new_score)
     |> assign(show_results: true)
     |> assign(vote_emojis: socket.assigns.vote_emojis ++ [emoji])
     |> assign(winner: winner)
     |> push_event("timer", %{game_over: not is_nil(winner)})
     |> push_event("scrollTop", %{})
     |> push_event("confetti", %{winner: prompt.model})}
  end

  def handle_event("next", _, socket) do
    send(self(), :next)
    {:noreply, socket |> push_event("clear_interval", %{})}
  end

  def handle_info(:next, socket) do
    %{text_prompt: text_prompt, prompts: prompts, submission_id: submission_id} =
      Prompts.get_random_submission()

    {:noreply,
     socket
     |> assign(show_results: false)
     |> assign(progress: 0)
     |> assign(submitted: false)
     |> assign(prompts: prompts)
     |> assign(round_winner: nil)
     |> assign(text_prompt: text_prompt)
     |> push_event("ring", %{})
     |> push_patch(to: ~p"/question/#{submission_id}")}
  end

  def handle_event("inspire", _, socket) do
    text_prompt = Prompts.get_random_prompt()
    {:noreply, socket |> assign(text_prompt: text_prompt)}
  end

  def handle_event("update-prompt", %{"prompt" => prompt}, socket) do
    {:noreply, assign(socket, text_prompt: prompt)}
  end

  defp other_model(model) do
    if String.contains?(model, "llama") do
      "gpt"
    else
      "llama"
    end
  end
end
