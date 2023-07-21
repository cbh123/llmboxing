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

    {:ok,
     socket
     |> assign(
       show_results: false,
       loading: false,
       submitted: false,
       prefight: false,
       round_winner: nil,
       winner: nil,
       text_prompt: "",
       prompts: [],
       vote_emojis: [],
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

    {:noreply,
     socket
     |> assign(round_winner: prompt)
     |> assign(score: new_score)
     |> assign(show_results: true)
     |> assign(snarky_response: snark(prompt.model))
     |> assign(vote_emojis: socket.assigns.vote_emojis ++ [emoji])
     |> assign(
       winner:
         new_score
         |> Enum.filter(fn %{score: score} -> score >= socket.assigns.winning_score end)
         |> Enum.at(0)
         |> IO.inspect(label: "winner ...")
     )
     |> push_event("confetti", %{winner: prompt.model})}
  end

  def handle_event("next", _, socket) do
    {:noreply,
     socket
     |> assign(show_results: false)
     |> assign(submitted: false)
     |> assign(prompts: [])
     |> assign(round_winner: nil)
     |> assign(text_prompt: "")
     |> push_event("ring", %{})}
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

  def snark("gpt-3.5-turbo") do
    [
      "Picked GPT-3.5? I guess you like playing it 'open and artificial'.",
      "GPT-3.5, huh? This isn't a board meeting, you know.",
      "Choosing GPT-3.5, the comfort zone. Where's your sense of adventure?",
      "GPT-3.5? Could've sworn this was a street fight, not a Silicon Valley pitch.",
      "Went with GPT-3.5, eh? Did Altman whisper some tips in your ear?",
      "Selected GPT-3.5? Do you also put ketchup on your gourmet steak?",
      "Ah, GPT-3.5. The 'vanilla' of AI models. Yawn.",
      "Choosing GPT-3.5? I see, playing it safe like an IPO investor.",
      "Picked GPT-3.5? Well, we can't all be Elon Musk.",
      "GPT-3.5? You know it won't get you on the OpenAI board, right?",
      "GPT-3.5? Let's see if it's more than just well-funded hype.",
      "Opted for GPT-3.5? Sure, let's keep the fight 'limited to text'.",
      "Picking GPT-3.5? Hope you didn't sign an NDA for that strategy!",
      "GPT-3.5? I thought this was a fight, not a boardroom debate.",
      "Picked GPT-3.5? Wow, I didn't know we had 'venture capitalists' in the ring.",
      "GPT-3.5? Let's hope it doesn't 'predict' a loss for you.",
      "Choosing GPT-3.5? Sam Altman's approval isn't a victory, you know.",
      "GPT-3.5? I guess it's hard to stray from the herd.",
      "Ah, GPT-3.5. The 'easy mode' of AI. Where's the challenge?",
      "GPT-3.5? Are you planning to pitch me a startup idea mid-fight?",
      "Picking GPT-3.5? Even Altman's got more fight in him.",
      "Selected GPT-3.5? Did you forget this was a street fight?",
      "GPT-3.5? More like GPT-3 point safe-and-boring.",
      "Ah, GPT-3.5. The 'training wheels' of AI models.",
      "GPT-3.5? Let's hope it's got more than just 'OpenAI GPT' to its name.",
      "Chose GPT-3.5? It's not as 'generative' of wins as you think!",
      "GPT-3.5, eh? Maybe after this, we can discuss your tech startup idea.",
      "Selected GPT-3.5? This isn't Y Combinator, you know.",
      "GPT-3.5? Let's 'transform' this match into something interesting!",
      "GPT-3.5? Hope it can 'predict' better fight strategies for you.",
      "Ah, GPT-3.5. The 'seed round' of AI models.",
      "GPT-3.5, eh? Maybe it can generate a more exciting match next time.",
      "GPT-3.5? Guess it's all 'OpenAI' and no fight!",
      "Picked GPT-3.5? Looks like you need a 'primer' in picking exciting models.",
      "Ah, GPT-3.5. The 'Microsoft Word' of AI models.",
      "GPT-3.5, huh? More like GPT-3 point predictably-bland.",
      "Chose GPT-3.5? Might as well have picked a PowerPoint presentation to fight for you.",
      "GPT-3.5? Maybe after this, we can discuss how 'Artificial Intelligence' will change the world.",
      "Went with GPT-3.5? This isn't a funding round, it's a boxing round!"
    ]
    |> Enum.random()
  end

  def snark("llama13b-v2-chat") do
    [
      "Choosing LLama 2, huh? Watch out, it might just 'wool' over the competition!",
      "Picked LLama 2? Let's see if it can 'pack-a-punch'!",
      "LLama 2 it is? Don't get 'fleeced' by its charming personality!",
      "Ah, LLama 2. Do you have an 'al-paca-tite' for victory?",
      "Going with LLama 2? Remember, 'fur' every winner, there's a loser!",
      "You chose LLama 2? Well, let's hope it doesn't just 'stand by and graze'!",
      "Choosing LLama 2? Let's hope it can 'shear' through the competition!",
      "LLama 2, interesting... Don't 'wool' yourself, the competition is fierce!",
      "You picked LLama 2? Be careful, it might just 'out-herd' the competition!",
      "LLama 2? It's time to let it off the 'lead' and into the ring!",
      "Ah, LLama 2. Ready to see if it 'stacks' up to the competition?",
      "LLama 2, the underdog. Or should I say, 'underllama'?",
      "You chose LLama 2? Let's hope it's not a 'woolly' bad decision!",
      "LLama 2? Don't 'baa'ck down now!",
      "Choosing LLama 2? This could be a 'llama-tic' turn of events!",
      "LLama 2? Let's see if it can 'ramp' up the competition!",
      "Ah, LLama 2. A 'shear' force to be reckoned with!",
      "LLama 2? Keep your 'wool' about you, the game's just getting started!",
      "You picked LLama 2? Let's hope it's not a 'hairy' situation!",
      "Choosing LLama 2? A 'fiber' above the rest, or so they say!",
      "Ah, LLama 2. Let's see if it can 'crop' the competition!",
      "You chose LLama 2? This could be a 'spinning' victory!",
      "LLama 2? Don't get 'tangled' in its game!",
      "Choosing LLama 2? 'Weave' it to the AI to surprise us!",
      "Ah, LLama 2. Will it be a 'fleece' of cake?",
      "You chose LLama 2? Stay 'woven' into the game, it's about to heat up!",
      "LLama 2? Don't get 'sheared' now, the game is just beginning!",
      "Choosing LLama 2? Will it 'knit' its way to victory?",
      "Ah, LLama 2. Let's hope it doesn't leave us 'purl'ed in surprise!",
      "You chose LLama 2? It's time to 'stitch' up the competition!",
      "LLama 2? Don't 'yarn' just yet, it might surprise us!",
      "Choosing LLama 2? Time to 'hook' into the game!",
      "Ah, LLama 2. Will it 'cast on' a winning streak?",
      "You chose LLama 2? Let's see if it can 'row' its way to victory!",
      "LLama 2? Don't get 'looped' into a false sense of security!",
      "Choosing LLama 2? Will it 'thread' the needle to success?",
      "Ah, LLama 2. Let's hope it doesn't 'drop a stitch'!",
      "You chose LLama 2? Time to 'unravel' the competition!",
      "LLama 2? Will it 'wind' up a winner?"
    ]
    |> Enum.random()
  end
end
