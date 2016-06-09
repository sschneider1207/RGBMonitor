defmodule RGBMonitor.Sensor do
  alias RGBMonitor.Const
  require Const
  use Bitwise

  @doc """
  Tests the connection to the sensor.
  """
  def available?(pid) do
    case I2c.write_read(pid, <<Const.id ||| Const.command_bit>>, 1) do
      <<0x44>> -> true
      <<0x10>> -> true 
      _ -> false 
    end
  end

  @doc """
  Sets the integration time for the sensor.
  """
  def set_integration_time(pid, it) do
    reg = Const.atime ||| Const.command_bit
    val = it &&& 0xFF
    I2c.write(pid, <<reg, val>>)
  end

  @doc """
  Sets the gain for the sensor (sensitivity to light).
  """
  def set_gain(pid, gain) do
    reg = Const.control ||| Const.command_bit
    val = gain &&& 0xFF
    I2c.write(pid, <<reg, val>>)
  end

  @doc """
  Enables the sensor.
  """
  def enable(pid) do
    reg = Const.enable ||| Const.command_bit
    val1 = Const.enable_pon &&& 0xFF
    val2 = (Const.enable_pon ||| Const.enable_aen) &&& 0xFF
    I2c.write(pid, <<reg, val1>>)
    :timer.sleep(3)
    I2c.write(pid, <<reg, val2>>)
  end

  @doc """
  Disables the sensor (putting it into a low power sleep state).
  """
  def disable(pid) do
    reg = <<Const.enable ||| Const.command_bit>>
    <<enable_reg>> = I2c.write_read(pid, reg, 1)
    val = (enable_reg &&& ~~~(Const.enable_pon ||| Const.enable_aen)) &&& 0xFF
    I2c.write(pid, reg, val)
  end

  @doc """
  Reads the raw RGB and clear channel values.
  """
  def read(pid) do
    c = read16(pid, Const.cdatal)
    r = read16(pid, Const.rdatal)
    g = read16(pid, Const.gdatal)
    b = read16(pid, Const.bdatal) 
    {c, r, g, b}
  end

  defp read16(pid, reg) do
    I2c.write_read(pid, <<reg ||| Const.command_bit>>, 2)
    |> :binary.decode_unsigned(:little)
  end

  @doc """
  Gets the ms delay for an integration time byte value.
  """
  def delay(Const.integration_time_2_4ms), do: 3
  def delay(Const.integration_time_24ms), do: 24
  def delay(Const.integration_time_50ms), do: 50
  def delay(Const.integration_time_154ms), do: 154
  def delay(Const.integration_time_700ms), do: 700
end
