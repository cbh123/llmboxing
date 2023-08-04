defmodule Boxing.Prompts do
  @moduledoc """
  The Prompts context.
  """

  import Ecto.Query, warn: false
  alias Boxing.Repo

  alias Boxing.Prompts.Prompt

  def add() do
    mjs = [
      "choltz_a_Victorian-era_styled_portrait_of_a_woman_oil_on_canvas_b8d577b3-edb9-476a-9ec5-d129d275360f.png",
      "choltz_a_ballerina_Art_Nouveau_pastel_sketch_31e59bbc-b26f-40d3-9b73-fa0c91942c2e.png",
      "choltz_a_bouquet_of_flowers_Dutch_Golden_Age_hyperrealism_e1bf9629-4fe9-4976-a5fe-cd4fb988c344.png",
      "choltz_a_bouquet_of_flowers_Dutch_Golden_Age_oil_painting_123bf993-9777-491b-ba87-5da54ffd99fa.png",
      "choltz_a_bouquet_of_sunflowers_art_nouveau_pastel_colors_2d349c96-5d7b-4eb9-a1ea-4bd5b6830602.png",
      "choltz_a_bustling_cafe_scene_impressionism_watercolor_f545c964-76c8-481f-840e-228bb9db6001.png",
      "choltz_a_bustling_city_scene_Victorian_era_watercolor_911f5413-732f-4e11-9429-9b5916b5ce3e.png",
      "choltz_a_bustling_cityscape_vintage_pencil_sketch_59e7a7e2-1c50-4e77-874f-a58732efc78d.png",
      "choltz_a_butterfly_in_abstract_art_neon_colors_ddc2a5a3-a76d-4725-84eb-4cd5a13ccb4c.png",
      "choltz_a_calming_beach_at_sunset_romanticism_watercolor_bbede6a4-4dc3-47bb-b9fd-f8054103eb29.png",
      "choltz_a_child_black_and_white_photorealistic_sketch_8a9903c0-47b0-46ff-8492-9f1baa4b105a.png",
      "choltz_a_classic_car_art_deco_metal_sculpture_e350bfcb-41d1-44af-8afa-b26b9c922316.png",
      "choltz_a_comic-style_illustration_of_superheroes_in_action_9776201a-d610-4e23-b856-acbb461e7868.png",
      "choltz_a_couple_dancing_cubism_digital_art_ca9d3195-5696-49c8-ad0e-f6c547517be1.png",
      "choltz_a_cubist_acrylic_painting_of_a_vibrant_music_festival_da64dafb-8873-4a06-bd0b-49f04fd0686d.png",
      "choltz_a_cyberpunk_cityscape_digital_illustration_ad405853-76ce-42a4-a951-7fde019a3aac.png",
      "choltz_a_cyberpunk_cityscape_digital_illustration_fd74cee3-e466-43b9-b326-82829b08f17c.png",
      "choltz_a_decadent_dessert_surrealism_digital_art_fcc7644e-f1c4-4d24-8e47-ad104a1c5ffe.png",
      "choltz_a_desert_digital_drawing_vaporwave_aesthetic_37da1fb4-0753-4844-977c-665d4e648bd4.png",
      "choltz_a_detailed_graphite_sketch_of_a_person_59b492da-160d-4d54-bb41-2f7a01438070.png",
      "choltz_a_dog_Renaissance-style_watercolor_14d56026-8fc1-4ee5-9c7c-6981d5981ea0.png",
      "choltz_a_dog_in_a_human_costume_caricature_cartoon_style_646d72b0-e8ac-4f07-b748-44480bc9f82f.png",
      "choltz_a_dragon_Neo-pop_spray_paint_graffiti_5ab77ed5-2055-4863-b328-19ac3ef3cb64.png",
      "choltz_a_dreamy_landscape_Romanticism_oil_painting_d5bb7930-06e5-41a8-b29e-2fec2b60821f.png",
      "choltz_a_fantasy_landscape_Surrealism_mixed_media_fc3c67f0-d08e-45e0-8dc8-222493d50c2d.png",
      "choltz_a_futurist_art_depicting_advances_in_science_and_technol_1830cbb1-4007-498e-a85e-ef90c152b453.png",
      "choltz_a_futurist_art_depicting_advances_in_science_and_technol_c2367618-2351-4d27-9c63-315460d8a948.png",
      "choltz_a_galaxy_far_away_science_fiction_pencil_sketch_7c7e8bf1-d85f-4fc8-982e-01094a8b705a.png",
      "choltz_a_graphite_sketch_of_a_bustling_city_street_56872154-efa9-49ce-8ce4-9d6d03956519.png",
      "choltz_a_horse_Western_Bronze_Sculpture_style_5c5daf57-b496-42ef-bd39-1d662cabdfab.png",
      "choltz_a_hyperrealistic_digital_art_of_a_human_face_8d7db766-3da2-4460-966a-31834e5bb61c.png",
      "choltz_a_landscape_of_a_winter_scene_woodblock_print_style_4785008c-5cc8-4714-9aa3-300e6ec1bdbf.png",
      "choltz_a_landscape_painting_of_a_snowy_mountain_range_at_dawn_e59d8546-d5c6-4348-a4aa-ea1fdceeb456.png",
      "choltz_a_line_drawing_of_a_complex_architectural_structure_16c418b8-45c0-4de1-b44e-7689619bf67f.png",
      "choltz_a_macro_photograph_displaying_the_texture_of_a_leaf_blac_7be17cdf-f156-48e1-8af9-9c51b668248a.png",
      "choltz_a_macro_photograph_displaying_the_texture_of_a_leaf_blac_f0a61582-114e-4fc5-8085-cccdaddcf93b.png",
      "choltz_a_microscopic_view_of_a_crystal_digital_3D_render_919b2466-31ab-43f4-9bd5-60e34d8c6c1b.png",
      "choltz_a_modern_city_skyline_pop_art_digital_rendering_36a3cca9-5929-4163-8177-bf10e2120a76.png",
      "choltz_a_monochrome_oil_painting_of_a_winter_landscape_4cf7466e-789b-459d-a982-284aaaec5150.png",
      "choltz_a_mosaic_art_of_a_garden_filled_with_sunflowers_2edfa7d0-cb6c-42f5-87d7-c4bd4c59785d.png",
      "choltz_a_mountain_landscape_in_watercolor_Japanese_style_3cb04aac-9a67-4645-933a-2a9114c8fe20.png",
      "choltz_a_natural_scenery_Japanese_Ukiyo-e_style_2ec23768-5ceb-4531-8d6f-4f29fc35017d.png",
      "choltz_a_playful_puppy_fauvism_graffiti_art_0b5d2b8a-0bcd-43db-b9da-8166d411892f.png",
      "choltz_a_pop_art_representation_of_a_crowded_marketplace_c6ed9cfb-45b3-4d5e-bc1e-7919188eb611.png",
      "choltz_a_portrait_of_a_historical_figure_renaissance_style_oil__b9c01bd5-79d8-4d24-85e8-f490f4a7a2c3.png",
      "choltz_a_portrait_of_a_woman_renaissance_style_oil_painting_7027d097-35e4-4e1f-928c-ec27b7c9856c.png",
      "choltz_a_rural_landscape_pencil_drawing_Russian_realism_375223c3-83e9-45e2-8e74-8cf42d4d3076.png",
      "choltz_a_scene_from_a_sci-fi_movie_art_nouveau_f6de3221-7c66-4280-9f37-d13fb922d139.png",
      "choltz_a_seascape_acrylic_painting_Fauvism_a177a107-a4b8-49a3-92ca-a82a3757ab86.png",
      "choltz_a_serene_forest_cubism_chalk_drawing_a6ee9675-ab76-472f-8b61-3ba331c83e04.png",
      "choltz_a_serene_nature_scene_Japanese_ink_painting_cb28c8ff-13d7-4d01-81c8-cc43aacb02b1.png",
      "choltz_a_sketch_of_a_busy_cityscape_noir_style_b5042c53-5fd0-4b17-9494-cf9807632937.png",
      "choltz_a_skyscraper_futuristic_cyberpunk_style_digital_art_40bdcbab-e4ee-4908-8ac1-e3866a9165b3.png",
      "choltz_a_skyscraper_futuristic_cyberpunk_style_digital_art_45dba625-1678-4fa7-a82e-3ef395562979.png",
      "choltz_a_smiling_toddler_expressionism_charcoal_sketch_523a53eb-0454-43a6-96b0-34d4bc379624.png",
      "choltz_a_still_life_photography_capturing_morning_coffee_vibes._5e2ea29b-a68c-4faf-9c71-c5d0478f5c52.png",
      "choltz_a_street_food_market_watercolor_sketch_7700f490-89d8-4f08-92f7-37a20996c615.png",
      "choltz_a_superhero_modern_comic_book_style._97a14a17-1608-444d-8111-e12f87127492.png",
      "choltz_a_surreal_depiction_of_a_city_skyline_at_night_d4cd7651-5ea6-4ba0-abfa-a1ce518c90c6.png",
      "choltz_a_surrealist_charcoal_sketch_of_a_dream_sequence_c0c3d989-c332-4594-9f29-70bfae8e0bcb.png",
      "choltz_a_three_dimensional_visualization_of_flowers_3abe7bff-b3d0-45b6-9458-b37b08687d81.png",
      "choltz_a_vibrant_sunset_impressionistic_style_pastel_colors_ff6d68e7-bdc6-4f0f-81be-5e79326ebbc0.png",
      "choltz_a_vintage-style_poster_of_a_rock_concert_1839592a-bf14-479d-903e-8e71428d451a.png",
      "choltz_a_wild_horse_running_abstract_sculpture_ded8eaea-eaf0-4af9-b305-9a461699e996.png",
      "choltz_a_winter_landscape_realism_acrylic_b12741ba-e36c-40fd-9526-ff61570f0752.png",
      "choltz_abstract_depiction_of_emotions_watercolor_painting_abd5b6ed-b40c-4371-8f8b-9298b056de0f.png",
      "choltz_abstract_representation_of_a_cityscape_at_sunset_2f3d69cb-8542-477c-a801-a7ca088e4e0b.png",
      "choltz_an_abstract_interpretation_of_city_skyline_watercolor_fef48f24-df3e-4c2d-9bf6-964117670763.png",
      "choltz_an_abstract_representation_in_watercolors_of_a_forest_du_a9e9c45a-c101-41e2-be5a-7f054c4c1079.png",
      "choltz_an_abstract_representation_of_emotions_acrylic_painting_8e072068-41ed-48e6-8279-e089187358de.png",
      "choltz_an_abstract_watercolor_interpretation_of_the_sunset_af4802da-4522-420e-a6a5-9de252ac9c3f.png",
      "choltz_an_action_scene_comic_book_style_c9687425-51f4-4b16-90ae-5bf411f6ca55.png",
      "choltz_an_aerial_view_of_a_city_digital_art_09d3a052-e01f-41f5-8535-fc81b8d9439f.png",
      "choltz_an_art_nouveau_depiction_of_a_starry_night_1b847dbb-009c-4377-8a85-33ee3c26174d.png",
      "choltz_an_astronaut_in_space_futurism_3D_rendering_1b6ae357-62f2-4ef8-9e3c-eabf2d444c33.png",
      "choltz_an_energetic_sports_match_pop_art_collage_3ac8675f-e078-4fec-ae88-a6894a8b4daf.png",
      "choltz_an_expressionist_pastel_drawing_of_a_tranquil_seaside_40bffbea-daef-4173-a172-bd13007f5918.png",
      "choltz_an_oil_painting_of_a_cat_5085cbe4-8179-4b01-b057-1a5cc240e217.png",
      "choltz_an_underwater_scene_fantasy_style_acrylics_e983aa9d-383c-44ce-a89b-1d77d2cc3a61.png",
      "choltz_an_underwater_scene_with_dolphins_futurism_acrylic_paint_00342500-c2e5-4151-9d3f-c40baf3df8bc.png",
      "choltz_city_skyline_night_scene_cubist_style_14179caa-a80a-463c-a37d-3f34d0af232e.png",
      "choltz_cyberpunk_influenced_digital_art_of_a_robotic_animal_1405aa32-ce31-4cb5-acc1-0c6dde70ba76.png",
      "choltz_depiction_of_a_sunrise_abstract_expressionism_oil_painti_9a98a742-b27e-4809-9f77-7f105fd40455.png",
      "choltz_fantasy_creature_gothic_style_digital_painting_a62ffe73-5265-4261-ab13-0ddcc83e423c.png",
      "choltz_fantasy_creature_in_a_forest_art_nouveau_gouache_paintin_d945f66a-f65c-49d8-9823-d801d77018b3.png",
      "choltz_graphic_design_poster_of_a_rock_concert_1980s_punk_aesth_7b9909da-62b1-4cbb-a8e5-f4201dbda36f.png",
      "choltz_low_angle_shot_of_skyscrapers_black_and_white_photograph_0846136a-9a24-4c4d-885d-6dc8fa620674.png",
      "choltz_nature_and_wildlife_pointillism_charcoal_drawing_2bad1a21-8c05-4d36-8ca9-37b9464b2517.png",
      "choltz_portrait_of_a_woman_Cubist_charcoal_8c9a1af8-d65b-4e25-af07-8bb88e2caeef.png",
      "choltz_portrait_of_an_elderly_man_realism_oil_painting_0f7cbce4-a819-49ce-9830-ad183dd4243e.png",
      "choltz_portraiture_of_a_famous_singer_pop_art_d2ced1a4-7be3-4396-b461-f4274a4f5467.png",
      "choltz_portrayal_of_a_rainy_day_realism_charcoal_drawing_ea5e5b06-e015-4d84-a3ec-9fd38addf85c.png",
      "choltz_silhouette_of_trees_abstract_watercolor_painting_60dbd87b-c83d-4a7c-87d9-24d667bb4711.png",
      "choltz_space_and_galaxies_pop_art_collage_3b76298f-8d7e-4213-8c7b-d67247b31810.png",
      "choltz_sports_car_pop-art_vector_illustration_ad003847-c7bd-46a8-b396-99a419572728.png",
      "choltz_surreal_interpretation_of_a_forest_pastel_5f76b1bf-37d3-42c5-b6b2-d2851aff36a6.png",
      "choltz_the_night_sky_art_nouveau_pen_and_ink_74bfc407-39ad-4299-a296-28dce31088b0.png",
      "choltz_wildlife_Ancient_Egyptian_Art_style_mural_f1a61252-9bf2-4cb2-b9a3-80b6b006e79e.png",
      "choltz_wildlife_in_a_forest_oil_painting_in_the_style_of_the_Ol_a742d531-6694-4736-9130-da887229ae98.png"
    ]

    for mj <- mjs do
      clean_name = String.split(mj, "_") |> Enum.slice(1..-2) |> Enum.join(" ")

      mj_url = "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/mj/#{mj}"

      with %Prompt{submission_id: submission_id} <- search_prompt(clean_name),
           false <- mj_exists?(submission_id) do
        {:ok, _prompt} =
          %{
            submission_id: submission_id,
            time: 10,
            prompt: clean_name,
            version: "midjourney v5",
            model: "midjourney v5",
            model_type: "image",
            output: mj_url
          }
          |> create_prompt()
      else
        _err ->
          IO.puts("Skipping #{clean_name}")
      end
    end
  end

  def mj_exists?(submission_id) do
    # check if midjourney version already exists
    case from(p in Prompt,
           where: p.submission_id == ^submission_id and p.version == "midjourney v5"
         )
         |> Repo.all() do
      [] -> false
      _results -> true
    end
  end

  def search_prompt(prompt) do
    like_pattern = "%" <> String.replace(prompt, " ", "%") <> "%"

    from(p in Prompt,
      where: ilike(p.prompt, ^like_pattern) and p.model == "sdxl"
    )
    |> Repo.one()
  end

  @doc """
  Creates a question(s) with GPT-4.

  Returns a list of [question, question, ...]
  """
  def create_questions() do
    {:ok, %{choices: [%{"message" => %{"content" => content}} | _]}} =
      OpenAI.chat_completion(
        model: "gpt-4",
        messages: [
          %{
            role: "system",
            content:
              "You are a helpful bot that creates questions for comparing language models. Be creative! Just give me the question, and I'll do the rest."
          },
          %{
            role: "user",
            content: """
            I'm creating an app that compares large language model completions. Can you write me some prompts I can use to compare them? They should be in a wide range of topics. For example, here are some I have already:

            Example outputs:
            How are you today?
            My wife wants me to pick up some Indian food for dinner. I always get the same things - what should I try?
            How much wood could a wood chuck chuck if a wood chuck could chuck wood?
            What's 3 x 5 / 10 + 9
            I really like the novel Anathem by Neal Stephenson. Based on that book, what else might I like?

            Can you give me another? Just give me the question. Separate outputs with a \n. Do NOT include numbers in the output. Do NOT start your response with something like "Sure, here are some additional prompts spanning a number of different topics:". Just give me the questions.
            """
          }
        ]
      )

    content |> String.split("\n")
  end

  @doc """
  Creates image prompts with GPT-4.

  Returns a list of [prompt, prompt, ...]
  """
  def create_image_prompts() do
    {:ok, %{choices: [%{"message" => %{"content" => content}} | _]}} =
      OpenAI.chat_completion(
        model: "gpt-4",
        messages: [
          %{
            role: "system",
            content:
              "You are a helpful bot that creates questions for comparing language models. Be creative! Just give me the question, and I'll do the rest."
          },
          %{
            role: "user",
            content: """
            I'm creating an app that compares image model completions. Can you write me some prompts I can use to compare them? They should be in a wide range of styles. For example, here are some I have already:

            Example outputs:
            a digital rendering of fish
            macro photograph of birds, minimalism, cinematic
            a cat, still life, impressionism, oil painting

            Can you give me another? Just give me the prompts. Separate outputs with a \n. Do NOT include numbers in the output. DO NOT end prompts with periods. Do NOT start your response with something like "Sure, here are some additional prompts spanning a number of different topics:". Just give me the prompts.
            """
          }
        ]
      )

    content |> String.split("\n")
  end

  @doc """
  Given a question, assigns it a subission ID, answers it with Llama 70B and GPT-3.5,
  and save to DB.
  """
  def generate_text_completions(question) do
    submission_id = Ecto.UUID.generate()

    for model <- ["gpt-3.5-turbo", "llama70b-v2-chat"] do
      {:ok, _prompt} = gen(%{model: model, question: question, submission_id: submission_id})
    end
  end

  @doc """
  Given an image prompt, assigns it a submission ID, generates an image with DALL-E/SDXL/SD 1.5/SD 2.1/Kandinsky 2.2,
  uploads the output to Supabase, and saves to DB.
  """
  def generate_images(prompt) do
    submission_id = Ecto.UUID.generate()

    for model <- [
          "sdxl"
          # "stable-diffusion 1.5",
          # "stable-diffusion 2.1",
          # "dall-e",
          # "kandinsky-2.2"
        ] do
      {:ok, _prompt} = gen(%{model: model, prompt: prompt, submission_id: submission_id})
    end
  end

  def save_r2(uuid, image_url) do
    {:ok, resp} = :httpc.request(:get, {image_url, []}, [], body_format: :binary)
    {{_, 200, 'OK'}, _headers, image_binary} = resp

    file_name = "prediction-#{uuid}.png"
    bucket = System.get_env("BUCKET_NAME")

    %{status_code: 200} =
      ExAws.S3.put_object(bucket, file_name, image_binary)
      |> ExAws.request!()

    {:ok, "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{file_name}"}
  end

  defp replicate_gen(readable_name, owner_model, version, prompt, submission_id, type) do
    model = Replicate.Models.get!(owner_model)
    version = Replicate.Models.get_version!(model, version)

    {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: prompt})
    {:ok, prediction} = Replicate.Predictions.wait(prediction)

    result = List.first(prediction.output)

    # Save to R2
    {:ok, r2_url} = save_r2(prediction.id, result)

    {:ok, start, _} = DateTime.from_iso8601(prediction.started_at)
    {:ok, completed, _} = DateTime.from_iso8601(prediction.completed_at)

    IO.puts("Generated Output: #{result} for Model: #{model.name}")

    create_prompt(%{
      prompt: prompt,
      output: r2_url,
      model: readable_name,
      version: version.id,
      time: DateTime.diff(start, completed, :second) |> abs(),
      submission_id: submission_id,
      model_type: type
    })
  end

  def gen(%{model: "sdxl", prompt: prompt, submission_id: submission_id}) do
    replicate_gen(
      "sdxl",
      "stability-ai/sdxl",
      "2b017d9b67edd2ee1401238df49d75da53c523f36e363881e057f5dc3ed3c5b2",
      prompt,
      submission_id,
      "image"
    )
  end

  def gen(%{model: "kandinsky-2.2", prompt: prompt, submission_id: submission_id}) do
    replicate_gen(
      "kandinsky-2.2",
      "ai-forever/kandinsky-2.2",
      "ea1addaab376f4dc227f5368bbd8eff901820fd1cc14ed8cad63b29249e9d463",
      prompt,
      submission_id,
      "image"
    )
  end

  def gen(%{model: "stable-diffusion 1.5", prompt: prompt, submission_id: submission_id}) do
    replicate_gen(
      "stable-diffusion 1.5",
      "stability-ai/stable-diffusion",
      "b3d14e1cd1f9470bbb0bb68cac48e5f483e5be309551992cc33dc30654a82bb7",
      prompt,
      submission_id,
      "image"
    )
  end

  def gen(%{model: "stable-diffusion 2.1", prompt: prompt, submission_id: submission_id}) do
    replicate_gen(
      "stable-diffusion 2.1",
      "stability-ai/stable-diffusion",
      "ac732df83cea7fff18b8472768c88ad041fa750ff7682a21affe81863cbe77e4",
      prompt,
      submission_id,
      "image"
    )
  end

  def gen(%{
        model: "llama70b-v2-chat" = model_name,
        question: raw_prompt,
        submission_id: submission_id
      }) do
    model = Replicate.Models.get!("replicate/llama70b-v2-chat")
    version = Replicate.Models.get_latest_version!(model)

    prompt = "User: #{raw_prompt}\nAssistant:"

    {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: prompt})
    {:ok, prediction} = Replicate.Predictions.wait(prediction)

    result = Enum.join(prediction.output)

    {:ok, start, _} = DateTime.from_iso8601(prediction.started_at)
    {:ok, completed, _} = DateTime.from_iso8601(prediction.completed_at)

    DateTime.diff(start, completed, :second) |> abs() |> IO.inspect(label: "Time")

    IO.puts("Generated Output: #{result} for Model: #{model.name}")

    create_prompt(%{
      prompt: raw_prompt,
      completion: result,
      model: model_name,
      version: version.id,
      time: DateTime.diff(start, completed, :second) |> abs(),
      submission_id: submission_id,
      model_type: "language"
    })
  end

  def gen(%{model: "gpt-3.5-turbo", question: prompt, submission_id: submission_id}) do
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

    create_prompt(%{
      prompt: prompt,
      completion: content,
      model: "gpt-3.5-turbo",
      version: "gpt-3.5-turbo",
      time: System.convert_time_unit(end_time - start_time, :native, :second) |> abs(),
      submission_id: submission_id,
      model_type: "language"
    })
  end

  @doc """
  Count prompts.
  """
  def count_prompts(model_type) do
    from(p in Prompt, where: p.model_type == ^model_type) |> Repo.aggregate(:count)
  end

  @doc """
  Vote.
  """
  def vote(id) do
    prompt = Repo.get!(Prompt, id)
    prompt = Prompt.changeset(prompt, %{votes: prompt.votes + 1})
    Repo.update!(prompt)
  end

  @doc """
  Get random prompt.
  """
  def get_random_prompt() do
    from(p in Prompt, order_by: fragment("RANDOM()"), limit: 1, select: p.prompt) |> Repo.one()
  end

  def get_submission(submission_id) do
    unique_prompt =
      from(p in Prompt, where: p.submission_id == ^submission_id) |> Repo.all() |> Enum.at(0)

    # Get all prompts with the random submission_id
    prompts =
      Prompt
      |> where([p], p.submission_id == ^submission_id)
      |> Repo.all()
      |> Enum.shuffle()

    # Return a map with the unique prompt and all associated prompts
    %{
      text_prompt: unique_prompt.prompt,
      prompts: prompts,
      submission_id: unique_prompt.submission_id
    }
  end

  @doc """
  Get random submission.
  """
  def get_random_submission(type) do
    # First, find prompts that appear more than once
    subquery =
      from(p in Prompt,
        group_by: [p.prompt],
        having: count(p.id) > 1,
        select: p.prompt,
        where: p.model_type == ^type
      )

    IO.puts(type)

    # Then, select a random row with one of these prompts
    query =
      from(p in Prompt,
        where: p.prompt in subquery(subquery),
        order_by: fragment("RANDOM()"),
        limit: 1
      )

    unique_prompt = Repo.one(query) |> IO.inspect(label: "Unique Prompt")

    if unique_prompt == nil do
      %{text_prompt: "No submissions yet!", prompts: []}
    else
      # Get all prompts with the random submission_id
      prompts =
        Prompt
        |> where([p], p.submission_id == ^unique_prompt.submission_id)
        |> Repo.all()
        |> Enum.shuffle()

      # Return a map with the unique prompt and all associated prompts
      %{
        text_prompt: unique_prompt.prompt,
        prompts: prompts,
        submission_id: unique_prompt.submission_id
      }
    end
  end

  @doc """
  Returns the list of prompt.

  ## Examples

      iex> list_prompt()
      [%Prompt{}, ...]

  """
  def list_prompts(type) do
    Repo.all(from(p in Prompt, where: p.model_type == ^type))
  end

  def list_prompts do
    Repo.all(Prompt)
  end

  @doc """
  Gets a single prompt.

  Raises `Ecto.NoResultsError` if the Prompt does not exist.

  ## Examples

      iex> get_prompt!(123)
      %Prompt{}

      iex> get_prompt!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prompt!(id), do: Repo.get!(Prompt, id)

  @doc """
  Creates a prompt.

  ## Examples

      iex> create_prompt(%{field: value})
      {:ok, %Prompt{}}

      iex> create_prompt(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prompt(attrs \\ %{}) do
    %Prompt{}
    |> Prompt.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prompt.

  ## Examples

      iex> update_prompt(prompt, %{field: new_value})
      {:ok, %Prompt{}}

      iex> update_prompt(prompt, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prompt(%Prompt{} = prompt, attrs) do
    prompt
    |> Prompt.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a prompt.

  ## Examples

      iex> delete_prompt(prompt)
      {:ok, %Prompt{}}

      iex> delete_prompt(prompt)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prompt(%Prompt{} = prompt) do
    Repo.delete(prompt)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prompt changes.

  ## Examples

      iex> change_prompt(prompt)
      %Ecto.Changeset{data: %Prompt{}}

  """
  def change_prompt(%Prompt{} = prompt, attrs \\ %{}) do
    Prompt.changeset(prompt, attrs)
  end
end
