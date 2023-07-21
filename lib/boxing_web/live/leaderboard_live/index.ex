defmodule BoxingWeb.LeaderboardLive.Index do
  use BoxingWeb, :live_view
  alias Phoenix.PubSub

  alias Boxing.Prompts
  alias Boxing.Votes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(votes: Votes.list_votes())}
  end
end
