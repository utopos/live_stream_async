defmodule LiveStreamDemoLive do
  use Phoenix.LiveView
  use LiveStreamAsync

  def mount(_, _, socket) do
    {:ok,
     socket
     |> stream_configure(:hotels, dom_id: &"hotel-#{&1.id}")
     |> stream_configure(:restaurants, dom_id: &"resta-#{&1.id}")
     |> stream_async(
       :hotels,
       fn ->
         Process.sleep(300)
         list_hotels()
       end,
       reset: true,
       limit: 5
     )
     |> stream_async(:restaurants, fn -> list_restaurants() end, reset: true, limit: 3)}
  end

  def render(assigns) do
    ~H"""
    <.async_result :let={stream_key} assign={@hotels}>
    <:loading>Loading hotels...</:loading>
    <:failed :let={_failure}>There was an error loading the hotels. Please try again later.</:failed>
      <ul id="hotels_stream" phx-update="stream">
        <li :for={{id, hotel} <- @streams[stream_key]} id={id}>
        <%= hotel.name %>
        </li>
      </ul>
    </.async_result>
    <!-- Break -->
    <.async_result :let={stream_key} assign={@restaurants}>
    <:loading>Loading hotels...</:loading>
    <:failed :let={_failure}>There was an error loading the hotels. Please try again later.</:failed>
      <ul id="restaurant_stream" phx-update="stream">
        <li :for={{id, hotel} <- @streams[stream_key]} id={id}>
        <%= hotel.name %>
        </li>
      </ul>
    </.async_result>
    """
  end

  def list_hotels() do
    [
      %{id: "hotel_01", name: "Belo Horizonte Palace"},
      %{id: "hotel_02", name: "Copacabana Beach Resort"},
      %{id: "hotel_03", name: "São Paulo Grand Hotel"},
      %{id: "hotel_04", name: "Rio Marina Bay"},
      %{id: "hotel_05", name: "Manaus Rainforest Lodge"},
      %{id: "hotel_06", name: "Salvador Seaside Hotel"},
      %{id: "hotel_07", name: "Brasília Executive Suites"},
      %{id: "hotel_08", name: "Florianópolis Beach Hotel"},
      %{id: "hotel_09", name: "Recife Ocean View"},
      %{id: "hotel_10", name: "Curitiba Business Center"},
      %{id: "hotel_11", name: "Fortaleza Paradise Resort"},
      %{id: "hotel_12", name: "Porto Alegre City Hotel"},
      %{id: "hotel_13", name: "Natal Sun Palace"},
      %{id: "hotel_14", name: "Gramado Mountain Resort"},
      %{id: "hotel_15", name: "Amazonas Jungle Lodge"}
    ]
  end

  def list_restaurants() do
    [
      %{id: "rest_01", name: "Fogo de Chão - São Paulo"},
      %{id: "rest_02", name: "Marius Degustare - Rio"},
      %{id: "rest_03", name: "D.O.M. - São Paulo"},
      %{id: "rest_04", name: "Oro - Rio de Janeiro"},
      %{id: "rest_05", name: "Casa do Porco - São Paulo"},
      %{id: "rest_06", name: "Maní - São Paulo"},
      %{id: "rest_07", name: "Mocotó - São Paulo"},
      %{id: "rest_08", name: "Lasai - Rio de Janeiro"},
      %{id: "rest_09", name: "Manga - Recife"},
      %{id: "rest_10", name: "Glouton - Belo Horizonte"},
      %{id: "rest_11", name: "Soeta - Curitiba"},
      %{id: "rest_12", name: "Aconchego Carioca - Rio"},
      %{id: "rest_13", name: "Banzeiro - Manaus"},
      %{id: "rest_14", name: "Casa do Saulo - Salvador"},
      %{id: "rest_15", name: "Origem - Salvador"}
    ]
  end
end

defmodule LiveStreamAsyncTest do
  use ExUnit.Case
  use PhoenixPlayground.Test, live: LiveStreamDemoLive
  import AssertHelpers

  test "returns stream async after some time" do
    {:ok, view, _html} = live(build_conn(), "/")
    assert eventually(fn -> render(view) =~ "Belo Horizonte Palace" end)

    assert render(view) =~ "Manaus Rainforest Lodge"
  end

  test "evaluates opts correctly (limit)" do
    {:ok, view, _html} = live(build_conn(), "/")
    assert eventually(fn -> render(view) =~ "Fogo de Chão - São Paulo" end)
    rendered = render(view)
    assert rendered =~ "D.O.M. - São Paulo"
    refute rendered =~ "Oro - Rio de Janeiro"
    refute rendered =~ "Maní - São Paulo"
  end
end
