defmodule DataBackup.DataMasterTest do
  use ExUnit.Case
  alias DataBackup.DataMaster

  @table_name :data

  describe "init/1" do
    test "starts correctly" do
      assert :erlang.whereis(DataMaster) == :undefined

      assert {:ok, pid} = DataMaster.start_link()
      assert is_pid(pid)
    end

    test "creates ets table with itself as heir" do
      DataMaster.start_link()
      assert info = :ets.info(@table_name)
      assert info[:owner] == :erlang.whereis(DataMaster)
      assert info[:heir] == :erlang.whereis(DataMaster)
    end

    test "stores table name in state" do
      DataMaster.start_link()
      assert %{ets: @table_name} = DataMaster.get_state
    end
  end

  describe "get_ets/0" do
    setup :start_server

    test "returns table name" do
      assert @table_name == DataMaster.get_ets()
    end

    test "clears state" do
      DataMaster.get_ets()
      assert nil == DataMaster.get_state()
    end

    test "gives me ownership of ets" do
      assert :ets.info(@table_name)[:owner] == :erlang.whereis(DataMaster)
      DataMaster.get_ets()
      assert :ets.info(@table_name)[:owner] == self()
    end

    test "returns nil if no ets available" do
      DataMaster.get_ets()
      refute DataMaster.get_ets()
    end
  end

  describe "handle_info :ETS-TRANSFER" do
    setup :start_server

    test "takes ownership if table name matches expectations" do
      ets = DataMaster.get_ets()
      assert :ets.info(@table_name)[:owner] == self()
      transfer_ets(ets)
      assert :ets.info(@table_name)[:owner] == :erlang.whereis(DataMaster)
      assert %{ets: @table_name} = DataMaster.get_state
    end

    test "kills ets table name doesn't match" do
      :ets.new(:not_correct, [:set, :protected, :named_table])
      assert :ets.info(:not_correct)[:owner] == self()
      transfer_ets(:not_correct)
      assert %{ets: @table_name} = DataMaster.get_state
      assert :ets.info(:not_correct) == :undefined
    end
  end

  ###################
  # Setup Functions #
  ###################

  def start_server(_context) do
    DataMaster.start_link()

    {:ok, %{}}
  end

  #####################
  # Private Functions #
  #####################

  def transfer_ets(table_name) do
    :ets.give_away(table_name, :erlang.whereis(DataMaster), nil)
  end
end
