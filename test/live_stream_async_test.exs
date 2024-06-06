defmodule LiveStreamAsyncTest do
  use ExUnit.Case
  doctest LiveStreamAsync

  test "greets the world" do
    assert LiveStreamAsync.hello() == :world
  end
end
