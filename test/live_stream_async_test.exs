defmodule LiveStreamDemoLive do
  use Phoenix.LiveView
  use LiveStreamAsync

  def mount(_, _, socket) do
    {:ok,
     socket
     |> stream_configure(:hotels, dom_id: &"hotel-#{&1.id}")
     |> stream_async(
       :hotels,
       fn ->
         Process.sleep(300)
         list_hotels()
       end,
       reset: true
     )}
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
end

defmodule LiveStreamAsyncTest do
  use ExUnit.Case
  use PhoenixPlayground.Test, live: LiveStreamDemoLive
  import AssertHelpers

  test "returns stream async after some time" do
    {:ok, view, html} = live(build_conn(), "/")
    IO.inspect(view, label: "view")
    assert eventually(fn -> render(view) =~ "Belo Horizonte Palace" end)
    assert eventually(fn -> render(view) =~ "Amazonas Jungle Lodge" end)
  end
end
