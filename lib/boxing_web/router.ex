defmodule BoxingWeb.Router do
  use BoxingWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {BoxingWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BoxingWeb do
    pipe_through(:browser)

    live "/", QuizLive.LlamaMistral, :index
    live("/fight/image", QuizLive.Image, :index)
    live("/fight/image/question/:id", QuizLive.Image, :index)

    live("/fight/language", QuizLive.Language, :index)
    live("/fight/language/question/:id", QuizLive.Language, :index)
    live "/llama-vs-mistral", QuizLive.LlamaMistral, :index
    live "/llama-vs-mistral/question/:id", QuizLive.LlamaMistral, :index

    live("/prompts", PromptLive.Index, :index)

    live("/leaderboard", LeaderboardLive.Index, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", BoxingWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:boxing, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: BoxingWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
