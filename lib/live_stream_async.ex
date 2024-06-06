defmodule LiveStreamAsync do
  @moduledoc ~S'''
  Extends LiveView with `stream_async/4` macro.

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

  Extend your live view module with `use LiveAsyncStream` and you can leverage the `stream_async/4` macro:

  ```elixir
  use MyAppWeb, :live_view
  use LiveAsyncStream

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
  '''

  alias Phoenix.LiveView.AsyncResult

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :async_streams, accumulate: true)
    end
  end

  defmacro __before_compile__(_env) do
    streams = Module.get_attribute(__CALLER__.module, :async_streams)

    for {stream_id, opts} <- streams do
      quote bind_quoted: [stream: stream_id, opts: opts] do
        def handle_async(stream, {:ok, results}, socket) do
          socket =
            socket
            |> assign(stream, AsyncResult.ok(stream))
            |> stream(stream, results, unquote(opts))

          {:noreply, socket}
        end

        def handle_async(stream, {:exit, reason}, socket) do
          {:noreply,
           update(socket, stream, fn async_result ->
             AsyncResult.failed(async_result, {:exit, reason})
           end)}
        end
      end
    end
  end

  @doc ~S'''
  Assigns stream keys asynchronously.

  Wraps your function in a task linked to the caller, errors are wrapped. The key passed to `stream_async/4` will be assigned to an `Phoenix.LiveView.AsyncResult` struct holding the status of the operation and the result - key to the streams assign (socket.assigns.streams) - when the function completes.

  The task is only started when the socket is connected.

  ## Options

  * `:supervisor` - allows you to specify a `Task.Supervisor` to supervise the task.
  * from `Phoenix.LiveView.stream/4` function:
    * `:at` - the index to insert or update the items in the
        collection on the client.
    * `:reset` - the boolean to reset the stream on the client or not. Defaults
      to `false`.
    * `:limit` - the optional positive or negative number of results to limit
      on the UI on the client.

  ## Example
  ```elixir
    use MyAppWeb, :live_view
    use LiveAsyncStream

    def mount(%{"location" => location}, _, socket) do
    {:ok,
    socket
    |> stream_async(:hotels, fn -> Hotels.fetch!(location) end, reset: true)
    }
    end
    ```
  '''

  defmacro stream_async(socket, key, func, opts \\ []) do
    Module.put_attribute(__CALLER__.module, :async_streams, {key, opts})

    quote bind_quoted: [socket: socket, key: key, func: func, opts: opts] do
      socket
      |> assign(key, AsyncResult.loading())
      |> start_async(key, func, opts)
    end
  end
end
