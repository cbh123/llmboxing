defmodule BoxingWeb.QuizLive.Image do
  use BoxingWeb, :live_view
  alias Phoenix.PubSub

  alias Boxing.Prompts
  alias Boxing.Votes

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Boxing.PubSub, "predictions")
    end

    %{text_prompt: text_prompt, prompts: prompts, submission_id: _submission_id} =
      Prompts.get_random_submission("image")

    {:ok,
     socket
     |> assign(
       show_results: false,
       prefight: false,
       round_winner: nil,
       winner: nil,
       text_prompt: text_prompt,
       prompts: prompts,
       sounds: true,
       vote_emojis: [],
       progress: 0,
       score: [
         %{human_name: "SDXL", js_name: "sdxl", model: "sdxl", health: 5, emoji: "🖼️"},
         %{
           human_name: "Midjourney V5",
           js_name: "midjourney",
           model: "midjourney v5",
           health: 5,
           emoji: "⛵"
         }
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

  @impl true
  def handle_event("handle-keypress", %{"key" => "Enter"}, socket) do
    send(self(), :next)
    {:noreply, socket}
  end

  @impl true
  def handle_event("handle-keypress", %{"key" => _key}, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "handle-keypress-question",
        %{"key" => "ArrowLeft", "left-id" => id, "left-submission-id" => submission_id},
        socket
      ) do
    if not socket.assigns.show_results do
      send(self(), {:select, id, submission_id})
    end

    {:noreply, socket}
  end

  def handle_event(
        "handle-keypress-question",
        %{"key" => "ArrowRight", "right-id" => id, "right-submission-id" => submission_id},
        socket
      ) do
    if not socket.assigns.show_results do
      send(self(), {:select, id, submission_id})
    end

    {:noreply, socket}
  end

  def handle_event("handle-keypress-question", params, socket) do
    IO.inspect(params, label: "")
    {:noreply, socket}
  end

  def handle_event("handle-check", _params, socket) do
    {:noreply, socket |> assign(sounds: !socket.assigns.sounds)}
  end

  def handle_event("start", _, socket) do
    %{text_prompt: _text_prompt, prompts: _prompts, submission_id: submission_id} =
      Prompts.get_random_submission("image")

    {:noreply,
     socket
     |> assign(prefight: false)
     |> push_patch(to: ~p"/fight/image/question/#{submission_id}")
     |> push_event("ring", %{sounds: socket.assigns.sounds})}
  end

  def handle_event(
        "select",
        %{"id" => _id, "submission-id" => _submission_id},
        %{assigns: %{show_results: true}} = socket
      ) do
    {:noreply, socket}
  end

  def handle_event("select", %{"id" => id, "submission-id" => submission_id}, socket) do
    send(self(), {:select, id, submission_id})
    {:noreply, socket}
  end

  def handle_event("next", _, socket) do
    send(self(), :next)
    {:noreply, socket |> push_event("clear_interval", %{})}
  end

  def handle_event("inspire", _, socket) do
    text_prompt = Prompts.get_random_prompt()
    {:noreply, socket |> assign(text_prompt: text_prompt)}
  end

  def handle_event("update-prompt", %{"prompt" => prompt}, socket) do
    {:noreply, assign(socket, text_prompt: prompt)}
  end

  @impl true
  def handle_info(:next, socket) do
    %{text_prompt: text_prompt, prompts: prompts, submission_id: submission_id} =
      Prompts.get_random_submission("image")

    {:noreply,
     socket
     |> assign(show_results: false)
     |> assign(progress: 0)
     |> assign(submitted: false)
     |> assign(prompts: prompts)
     |> assign(round_winner: nil)
     |> assign(text_prompt: text_prompt)
     |> push_event("ring", %{})
     |> push_patch(to: ~p"/fight/image/question/#{submission_id}")}
  end

  def handle_info({:select, id, submission_id}, socket) do
    prompt = Prompts.get_prompt!(id)
    {:ok, _vote} = Votes.create_vote(%{prompt_id: id, submission_id: submission_id})

    new_score =
      socket.assigns.score
      |> Enum.map(fn %{model: model} = score ->
        if model != prompt.model do
          %{score | health: score.health - 1}
        else
          score
        end
      end)

    loser = loser(new_score)
    winner = if is_nil(loser), do: nil, else: winner(loser, new_score)

    {:noreply,
     socket
     |> assign(progress: 0)
     |> assign(round_winner: prompt)
     |> assign(score: new_score)
     |> assign(show_results: true)
     |> assign(
       vote_emojis:
         socket.assigns.vote_emojis ++ [get_model(socket.assigns.score, prompt.model).emoji]
     )
     |> assign(winner: winner)
     |> push_event("timer", %{game_over: not is_nil(winner)})
     |> push_event("scrollTop", %{})
     |> push_event("confetti", %{winner: prompt.model, sounds: socket.assigns.sounds})}
  end

  defp other_model(model) do
    if String.contains?(model, "llama") do
      "gpt"
    else
      "llama"
    end
  end

  defp get_model(score, model_name) do
    score
    |> Enum.filter(fn %{model: model} -> model == model_name end)
    |> Enum.at(0)
  end

  # Returns the model with the highest health that isn't the loser.
  defp winner(loser, score) do
    score
    |> Enum.filter(fn %{model: model} -> model != loser.model end)
    |> Enum.max_by(fn %{health: health} -> health end)
  end

  # Returns the model with 0 health.
  defp loser(score) do
    score
    |> Enum.filter(fn %{health: health} -> health == 0 end)
    # Returns nil if no elements found
    |> Enum.at(0)
  end
end
