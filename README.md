# LiveStreamAsync

Extends LiveView with `stream_async/4` macro.

## Installation

The package can be installed by adding `live_stream_async` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:live_stream_async, "~> 0.1.0", runtime: false}
  ]
end
```

The docs can be found at <https://hexdocs.pm/live_stream_async>.

## New asynchronous operations in LiveView v.20

  New release of [LiveView library - v 0.20](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) - introduced built-in functions for [asynchronous work](https://hexdocs.pm/phoenix_live_view/0.20.14/Phoenix.LiveView.html#module-async-operations).  It's a perfect solution to deliver a snappy user experience by delegating some time-consuming tasks (ex. fetching from external services) to background jobs without blocking the UI or event handlers. New operations include:

  - `assign_sync/3`: a straight forward way to load the results asynchronously into socket assigns.
  - `start_async/4`: allows lower level control of asynchronous operations with `handle_async` callbacks.
  - `<.async_result ...>` - function component to handle the asynchronous operation state on the UI side (for success, loading and errors).

  ## Async streams

  Streams in LiveView allow working with large collections without keeping them on the server. In case you want to work with `streams` assigns asynchronously you may need to resort to low level control functions.

  This library provides a convenient macro `stream_async/4` that auto-generates all the necessary boilerplate behind the scenes and injects it into your LiveView module.

  ## Usage

  ### Extending LiveView

  Extend your live view module with `use LiveStreamAsync` and you can leverage the `stream_async/4` macro:

  ```elixir
  use MyAppWeb, :live_view
  use LiveStreamAsync

  def mount(%{"location" => location}, _, socket) do
  {:ok,
  socket
  |> stream_async(:hotels, fn -> Hotels.fetch!(location) end, reset: true)
  }
  end
  ```

  ### Accessing the result

  The `<.async_result ...>` component is designed to work with the `%Phoenix.LiveView.AsyncResult{}` structs. The struct is passed via "`assign={}`" attribute of the component. The component's inner block receives the `@streams` assign key through `:let={}` attribute. Example:
  ```elixir
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
  ```


