defmodule Welford.VarianceTest do
  use ExUnit.Case

  alias Welford.{Variance, VarianceState}

  @mean 5.0
  @var 0.2

  def next_value() do
    :rand.normal(@mean, @var)
  end

  test "it returns insufficient count when there have been no updates" do
    state = VarianceState.new()
    assert {:error, :insufficient_count} == Variance.finalize(state)
  end

  test "it returns insufficient count when there has been 1 update" do
    state =
      VarianceState.new()
      |> Variance.update(next_value())

    assert {:error, :insufficient_count} == Variance.finalize(state)
  end

  test "it returns mean, variance, and sample variance when 2 updates have been made" do
    state =
      VarianceState.new()
      |> Variance.update(next_value())
      |> Variance.update(next_value())

    {:ok, stats} = Variance.finalize(state)

    # Using a wide tolerance here since only 2 updates have been made.
    delta = 0.9
    assert_in_delta @mean, stats.mean, delta
    assert_in_delta @var, stats.variance, delta
    assert_in_delta @var, stats.sample_variance, delta
  end

  test "it returns mean, variance, and sample variance when 2+ updates have been made" do
    update_count = 100

    state =
      Enum.reduce(1..update_count, VarianceState.new(), fn _, acc ->
        Variance.update(acc, next_value())
      end)

    {:ok, stats} = Variance.finalize(state)

    # Use a more narrow tolerance since we ran enough updates to converge.
    delta = @var + 0.1
    assert_in_delta @mean, stats.mean, delta
    assert_in_delta @var, stats.variance, delta
    assert_in_delta @var, stats.sample_variance, delta
  end
end
