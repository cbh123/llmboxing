defmodule BoxingWeb.LeaderboardLive.Index do
  use BoxingWeb, :live_view
  alias Phoenix.PubSub

  alias Boxing.Prompts
  alias Boxing.Votes
  alias Contex.Sparkline

  @impl true
  def mount(_params, _session, socket) do
    vote_dict =
      %{
        "llama-vs-gpt" => Votes.count_votes_by_fight("llama-vs-gpt"),
        "llama-vs-mistral" => Votes.count_votes_by_fight("llama-vs-mistral")
      }

    {:ok,
     socket
     |> assign(vote_dict: vote_dict)}
  end

  def get_count_by_model(vote_list, model_name) do
    vote_list
    |> Enum.find(fn vote -> vote.model == model_name end)
    |> Map.get(:count)
  end
end
