defmodule RGBMonitor.Const do
 
  defmacro address, do: 0x29 
  
  defmacro command_bit, do: 0x80

  defmacro id, do: 0x12

  defmacro atime, do: 0x01

  defmacro control, do: 0x0F

  defmacro enable, do: 0x00

  defmacro enable_pon, do: 0x01

  defmacro enable_aen, do: 0x02

  defmacro cdatal, do: 0x14
  
  defmacro rdatal, do: 0x16

  defmacro gdatal, do: 0x18

  defmacro bdatal, do: 0x1A

  defmacro integration_time_2_4ms, do: 0xFF # 1 cycle - max count: 1024
  
  defmacro integration_time_24ms, do: 0xF6  # 10 cycles - max count: 10240
  
  defmacro integration_time_50ms, do: 0xEB  # 20 cycles - max count: 20480
  
  defmacro integration_time_101ms, do: 0xD5 # 42 cycles - max count: 43008
  
  defmacro integration_time_154ms, do: 0xC0 # 64 cycles - max count: 65535
  
  defmacro integration_time_700ms, do: 0x00 # 256 cycles - max count: 65535
  
  defmacro gain_1x, do: 0x00

  defmacro gain_4x, do: 0x01
  
  defmacro gain_16x, do: 0x02
  
  defmacro gain_60x, do: 0x03
end
