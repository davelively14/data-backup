defmodule DataBackup do
  @moduledoc """
  Documentation for DataBackup.
  """

  @doc """
  Starts our OTP system

  ## Examples

      iex> DataBackup.start
      nil

  """
  def start do
    DataBackup.Supervisor.start_link()
  end
end
