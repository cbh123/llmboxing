defmodule BoxingWeb.LeaderboardLive.Index do
  use BoxingWeb, :live_view
  alias Phoenix.PubSub

  alias Boxing.Prompts
  alias Boxing.Votes
  alias Contex.Sparkline

  @impl true
  def mount(_params, _session, socket) do
    cum_votes = Votes.cumulative_votes()

    # Create separate datasets for each model
    llama =
      cum_votes
      |> Enum.filter(&(&1.model == "llama70b-v2-chat"))

    gpt = cum_votes |> Enum.filter(&(&1.model == "gpt-3.5-turbo"))

    {:ok,
     socket
     |> assign(
       votes: Votes.count_votes(),
       llama_plot:
         llama
         |> Enum.map(fn v -> v.cumulative_votes end)
         |> Sparkline.new()
         |> Sparkline.colours("#fad48e", "#ff9838")
         |> Sparkline.draw(),
       gpt_plot:
         llama
         |> Enum.map(fn v -> v.cumulative_votes end)
         |> Sparkline.new()
         |> Sparkline.colours("#fad48e", "#ff9838")
         |> Sparkline.draw()
     )}
  end
end
