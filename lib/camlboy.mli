open Uints

type t [@@deriving show]

val create : echo_flag:bool -> t

val create_with_rom : echo_flag:bool -> rom_bytes:bytes -> t

type result =
  | In_frame
  | Frame_ended of [`White | `Light_gray | `Dark_gray | `Black ] array array

val run_instruction : t -> result

module For_tests : sig

  val prev_inst : t -> Instruction.t

  val get_ly : t -> int

  val get_lcd_stat : t -> uint8

  val get_mcycles_in_mode : t -> int

end
