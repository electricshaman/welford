defmodule Welford.TwinTest do
  use ExUnit.Case

  alias Welford.Twin

  @mean 5.0
  @var 0.2

  def next_value() do
    :rand.normal(@mean, @var)
  end

  setup do
    id = UUID.uuid4()
    {:ok, pid} = Twin.start_link(id)
    %{id: id, pid: pid}
  end

  test "it returns insufficient count when there have been no updates", %{id: id} do
    assert {:error, :insufficient_count} == Twin.finalize(id)
  end

  test "it returns insufficient count when there has been 1 update", %{id: id} do
    :ok = Twin.update(id, next_value())
    assert {:error, :insufficient_count} == Twin.finalize(id)
  end

  test "it returns mean, variance, and sample variance when 2 updates have been made", %{id: id} do
    :ok = Twin.update(id, next_value())
    :ok = Twin.update(id, next_value())
    {:ok, stats} = Twin.finalize(id)

    # Using a wide tolerance here since only 2 updates have been made.
    delta = 0.7
    assert_in_delta @mean, stats.mean, delta
    assert_in_delta @var, stats.variance, delta
    assert_in_delta @var, stats.sample_variance, delta
  end

  test "it returns mean, variance, and sample variance when 2+ updates have been made", %{id: id} do
    update_count = 100

    :ok = Enum.each(1..update_count, fn _ -> :ok = Twin.update(id, next_value()) end)
    {:ok, stats} = Twin.finalize(id)

    # Use a more narrow tolerance since we ran enough updates to converge.
    delta = @var + 0.1
    assert_in_delta @mean, stats.mean, delta
    assert_in_delta @var, stats.variance, delta
    assert_in_delta @var, stats.sample_variance, delta
  end
end
