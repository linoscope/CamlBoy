open Uints
open Instruction

module Make (Mmu : Word_addressable.S) = struct

  module RST_offset = struct
    let x00 = 0x00 |> Uint16.of_int
    let x08 = 0x08 |> Uint16.of_int
    let x10 = 0x10 |> Uint16.of_int
    let x18 = 0x18 |> Uint16.of_int
    let x20 = 0x20 |> Uint16.of_int
    let x28 = 0x28 |> Uint16.of_int
    let x30 = 0x30 |> Uint16.of_int
    let x38 = 0x38 |> Uint16.of_int
  end

  module Bit_pos = struct
    let b0 = 0 |> Uint8.of_int
    let b1 = 1 |> Uint8.of_int
    let b2 = 2 |> Uint8.of_int
    let b3 = 3 |> Uint8.of_int
    let b4 = 4 |> Uint8.of_int
    let b5 = 5 |> Uint8.of_int
    let b6 = 6 |> Uint8.of_int
    let b7 = 7 |> Uint8.of_int
  end

  module Instruction_length = struct
    let l1 = 1 |> Uint16.of_int
    let l2 = 2 |> Uint16.of_int
    let l3 = 3 |> Uint16.of_int
  end

  let f mmu ~pc : uint16 * (int * int) * Instruction.t =
    let open Instruction_length in
    let next_byte () = Mmu.read_byte mmu Uint16.(succ pc) in
    let next_word () = Mmu.read_word mmu Uint16.(succ pc) in
    let op = Mmu.read_byte mmu pc |> Uint8.to_int in
    match op with
    | 0x00 -> l1, (1, 1), NOP
    | 0x01 -> l3, (3, 3), LD16 (RR BC, Immediate16 (next_word ()))
    | 0x02 -> l1, (2, 2), LD8 (RR_indirect BC, R A)
    | 0x03 -> l1, (2, 2), INC16 (RR BC)
    | 0x04 -> l1, (1, 1), INC (R B)
    | 0x05 -> l1, (1, 1), DEC (R B)
    | 0x06 -> l2, (2, 2), LD8 (R B, Immediate8 (next_byte ()))
    | 0x07 -> l1, (1, 1), RLCA
    | 0x08 -> l3, (5, 5), LD16 (Direct16 (next_word ()), SP)
    | 0x09 -> l1, (2, 2), ADD16 (RR HL, RR BC)
    | 0x0A -> l1, (2, 2), LD8 (R A, RR_indirect BC)
    | 0x0B -> l1, (2, 2), DEC16 (RR BC)
    | 0x0C -> l1, (1, 1), INC (R C)
    | 0x0D -> l1, (1, 1), DEC (R C)
    | 0x0E -> l2, (2, 2), LD8 (R C, Immediate8 (next_byte ()))
    | 0x0F -> l1, (1, 1), RRCA
    | 0x10 -> ignore(next_byte ()); l2, (1, 1), STOP
    | 0x11 -> l3, (3, 3), LD16 (RR DE, Immediate16 (next_word ()))
    | 0x12 -> l1, (2, 2), LD8 (RR_indirect DE, R A)
    | 0x13 -> l1, (2, 2), INC16 (RR DE)
    | 0x14 -> l1, (1, 1), INC (R D)
    | 0x15 -> l1, (1, 1), DEC (R D)
    | 0x16 -> l2, (2, 2), LD8 (R D, Immediate8 (next_byte ()))
    | 0x17 -> l1, (1, 1), RLA
    | 0x18 -> l2, (3, 3), JR (None, (Int8.of_byte @@ next_byte ()))
    | 0x19 -> l1, (2, 2), ADD16 (RR HL, RR DE)
    | 0x1A -> l1, (2, 2), LD8 (R A, RR_indirect DE)
    | 0x1B -> l1, (2, 2), DEC16 (RR DE)
    | 0x1C -> l1, (1, 1), INC (R E)
    | 0x1D -> l1, (1, 1), DEC (R E)
    | 0x1E -> l2, (2, 2), LD8 (R E, Immediate8 (next_byte ()))
    | 0x1F -> l1, (1, 1), RRA
    | 0x20 -> l2, (2, 3), JR (NZ, Int8.of_byte @@ next_byte ())
    | 0x21 -> l3, (3, 3), LD16 (RR HL, Immediate16 (next_word ()))
    | 0x22 -> l1, (2, 2), LD8 (HL_inc, R A)
    | 0x23 -> l1, (2, 2), INC16 (RR HL)
    | 0x24 -> l1, (1, 1), INC (R H)
    | 0x25 -> l1, (1, 1), DEC (R H)
    | 0x26 -> l2, (2, 2), LD8 (R H, Immediate8 (next_byte ()))
    | 0x27 -> l1, (1, 1), DAA
    | 0x28 -> l2, (2, 3), JR (Z, Int8.of_byte @@ next_byte ())
    | 0x29 -> l1, (2, 2), ADD16 (RR HL,RR HL)
    | 0x2A -> l1, (2, 2), LD8 (R A, HL_inc)
    | 0x2B -> l1, (2, 2), DEC16 (RR HL)
    | 0x2C -> l1, (1, 1), INC (R L)
    | 0x2D -> l1, (1, 1), DEC (R L)
    | 0x2E -> l2, (2, 2), LD8 (R L, Immediate8 (next_byte ()))
    | 0x2F -> l1, (1, 1), CPL
    | 0x30 -> l2, (2, 3), JR (NC, Int8.of_byte @@ next_byte ())
    | 0x31 -> l3, (3, 3), LD16 (SP, Immediate16 (next_word ()))
    | 0x32 -> l1, (2, 2), LD8 (HL_dec, R A)
    | 0x33 -> l1, (2, 2), INC16 SP
    | 0x34 -> l1, (3, 3), INC (RR_indirect HL)
    | 0x35 -> l1, (3, 3), DEC (RR_indirect HL)
    | 0x36 -> l2, (3, 3), LD8 (RR_indirect HL, Immediate8 (next_byte ()))
    | 0x37 -> l1, (1, 1), SCF
    | 0x38 -> l2, (2, 3), JR (C, Int8.of_byte @@ next_byte ())
    | 0x39 -> l1, (2, 2), ADD16 (RR HL, SP)
    | 0x3A -> l1, (2, 2), LD8 (R A, HL_dec)
    | 0x3B -> l1, (2, 2), DEC16 SP
    | 0x3C -> l1, (1, 1), INC (R A)
    | 0x3D -> l1, (1, 1), DEC (R A)
    | 0x3E -> l2, (2, 2), LD8 (R A, Immediate8 (next_byte ()))
    | 0x3F -> l1, (1, 1), CCF
    | 0x40 -> l1, (1, 1), LD8 (R B, R B)
    | 0x41 -> l1, (1, 1), LD8 (R B, R C)
    | 0x42 -> l1, (1, 1), LD8 (R B, R D)
    | 0x43 -> l1, (1, 1), LD8 (R B, R E)
    | 0x44 -> l1, (1, 1), LD8 (R B, R H)
    | 0x45 -> l1, (1, 1), LD8 (R B, R F)
    | 0x46 -> l1, (2, 2), LD8 (R B, RR_indirect HL)
    | 0x47 -> l1, (1, 1), LD8 (R B, R A)
    | 0x48 -> l1, (1, 1), LD8 (R C, R B)
    | 0x49 -> l1, (1, 1), LD8 (R C, R C)
    | 0x4A -> l1, (1, 1), LD8 (R C, R D)
    | 0x4B -> l1, (1, 1), LD8 (R C, R E)
    | 0x4C -> l1, (1, 1), LD8 (R C, R H)
    | 0x4D -> l1, (1, 1), LD8 (R C, R L)
    | 0x4E -> l1, (2, 2), LD8 (R C, RR_indirect HL)
    | 0x4F -> l1, (1, 1), LD8 (R C, R A)
    | 0x50 -> l1, (1, 1), LD8 (R D, R B)
    | 0x51 -> l1, (1, 1), LD8 (R D, R C)
    | 0x52 -> l1, (1, 1), LD8 (R D, R D)
    | 0x53 -> l1, (1, 1), LD8 (R D, R E)
    | 0x54 -> l1, (1, 1), LD8 (R D, R H)
    | 0x55 -> l1, (1, 1), LD8 (R D, R L)
    | 0x56 -> l1, (2, 2), LD8 (R D, RR_indirect HL)
    | 0x57 -> l1, (1, 1), LD8 (R D, R A)
    | 0x58 -> l1, (1, 1), LD8 (R E, R B)
    | 0x59 -> l1, (1, 1), LD8 (R E, R C)
    | 0x5A -> l1, (1, 1), LD8 (R E, R D)
    | 0x5B -> l1, (1, 1), LD8 (R E, R E)
    | 0x5C -> l1, (1, 1), LD8 (R E, R H)
    | 0x5D -> l1, (1, 1), LD8 (R E, R L)
    | 0x5E -> l1, (1, 1), LD8 (R E, RR_indirect HL)
    | 0x5F -> l1, (1, 1), LD8 (R E, R A)
    | 0x60 -> l1, (1, 1), LD8 (R H, R B)
    | 0x61 -> l1, (1, 1), LD8 (R H, R C)
    | 0x62 -> l1, (1, 1), LD8 (R H, R D)
    | 0x63 -> l1, (1, 1), LD8 (R H, R E)
    | 0x64 -> l1, (1, 1), LD8 (R H, R H)
    | 0x65 -> l1, (1, 1), LD8 (R H, R L)
    | 0x66 -> l1, (1, 1), LD8 (R H, RR_indirect HL)
    | 0x67 -> l1, (1, 1), LD8 (R H, R A)
    | 0x68 -> l1, (1, 1), LD8 (R L, R B)
    | 0x69 -> l1, (1, 1), LD8 (R L, R C)
    | 0x6A -> l1, (1, 1), LD8 (R L, R D)
    | 0x6B -> l1, (1, 1), LD8 (R L, R E)
    | 0x6C -> l1, (1, 1), LD8 (R L, R H)
    | 0x6D -> l1, (1, 1), LD8 (R L, R L)
    | 0x6E -> l1, (1, 1), LD8 (R L, R E)
    | 0x6F -> l1, (1, 1), LD8 (R L, R A)
    | 0x70 -> l1, (2, 2), LD8 (RR_indirect HL, R B)
    | 0x71 -> l1, (2, 2), LD8 (RR_indirect HL, R C)
    | 0x72 -> l1, (2, 2), LD8 (RR_indirect HL, R D)
    | 0x73 -> l1, (2, 2), LD8 (RR_indirect HL, R E)
    | 0x74 -> l1, (2, 2), LD8 (RR_indirect HL, R H)
    | 0x75 -> l1, (2, 2), LD8 (RR_indirect HL, R L)
    | 0x76 -> l1, (1, 1), HALT
    | 0x77 -> l1, (2, 2), LD8 (RR_indirect HL, R A)
    | 0x78 -> l1, (1, 1), LD8 (R A, R B)
    | 0x79 -> l1, (1, 1), LD8 (R A, R C)
    | 0x7A -> l1, (1, 1), LD8 (R A, R D)
    | 0x7B -> l1, (1, 1), LD8 (R A, R E)
    | 0x7C -> l1, (1, 1), LD8 (R A, R H)
    | 0x7D -> l1, (1, 1), LD8 (R A, R L)
    | 0x7E -> l1, (2, 2), LD8 (R A, RR_indirect HL)
    | 0x7F -> l1, (1, 1), LD8 (R A, R A)
    | 0x80 -> l1, (1, 1), ADD8 (R A, R B)
    | 0x81 -> l1, (1, 1), ADD8 (R A, R C)
    | 0x82 -> l1, (1, 1), ADD8 (R A, R D)
    | 0x83 -> l1, (1, 1), ADD8 (R A, R E)
    | 0x84 -> l1, (1, 1), ADD8 (R A, R H)
    | 0x85 -> l1, (1, 1), ADD8 (R A, R L)
    | 0x86 -> l1, (2, 2), ADD8 (R A, RR_indirect HL)
    | 0x87 -> l1, (1, 1), ADD8 (R A, (R A))
    | 0x88 -> l1, (1, 1), ADC (R A, R B)
    | 0x89 -> l1, (1, 1), ADC (R A, R C)
    | 0x8A -> l1, (1, 1), ADC (R A, R D)
    | 0x8B -> l1, (1, 1), ADC (R A, R E)
    | 0x8C -> l1, (1, 1), ADC (R A, R H)
    | 0x8D -> l1, (1, 1), ADC (R A, R L)
    | 0x8E -> l1, (2, 2), ADC (R A, RR_indirect HL)
    | 0x8F -> l1, (1, 1), ADC (R A, R A)
    | 0x90 -> l1, (1, 1), SUB (R A, R B)
    | 0x91 -> l1, (1, 1), SUB (R A, R C)
    | 0x92 -> l1, (1, 1), SUB (R A, R D)
    | 0x93 -> l1, (1, 1), SUB (R A, R E)
    | 0x94 -> l1, (1, 1), SUB (R A, R H)
    | 0x95 -> l1, (1, 1), SUB (R A, R L)
    | 0x96 -> l1, (2, 2), SUB (R A, RR_indirect HL)
    | 0x97 -> l1, (1, 1), SUB (R A, R A)
    | 0x98 -> l1, (1, 1), SBC (R A, R B)
    | 0x99 -> l1, (1, 1), SBC (R A, R C)
    | 0x9A -> l1, (1, 1), SBC (R A, R D)
    | 0x9B -> l1, (1, 1), SBC (R A, R E)
    | 0x9C -> l1, (1, 1), SBC (R A, R H)
    | 0x9D -> l1, (1, 1), SBC (R A, R L)
    | 0x9E -> l1, (2, 2), SBC (R A, RR_indirect HL)
    | 0x9F -> l1, (1, 1), SBC (R A, R A)
    | 0xA0 -> l1, (1, 1), AND (R A, R B)
    | 0xA1 -> l1, (1, 1), AND (R A, R C)
    | 0xA2 -> l1, (1, 1), AND (R A, R D)
    | 0xA3 -> l1, (1, 1), AND (R A, R E)
    | 0xA4 -> l1, (1, 1), AND (R A, R H)
    | 0xA5 -> l1, (1, 1), AND (R A, R L)
    | 0xA6 -> l1, (2, 2), AND (R A, RR_indirect HL)
    | 0xA7 -> l1, (1, 1), AND (R A, R A)
    | 0xA8 -> l1, (1, 1), XOR (R A, R B)
    | 0xA9 -> l1, (1, 1), XOR (R A, R C)
    | 0xAA -> l1, (1, 1), XOR (R A, R D)
    | 0xAB -> l1, (1, 1), XOR (R A, R E)
    | 0xAC -> l1, (1, 1), XOR (R A, R H)
    | 0xAD -> l1, (1, 1), XOR (R A, R L)
    | 0xAE -> l1, (2, 2), XOR (R A, RR_indirect HL)
    | 0xAF -> l1, (1, 1), XOR (R A, R A)
    | 0xB0 -> l1, (1, 1), OR (R A, R B)
    | 0xB1 -> l1, (1, 1), OR (R A, R C)
    | 0xB2 -> l1, (1, 1), OR (R A, R D)
    | 0xB3 -> l1, (1, 1), OR (R A, R E)
    | 0xB4 -> l1, (1, 1), OR (R A, R H)
    | 0xB5 -> l1, (1, 1), OR (R A, R L)
    | 0xB6 -> l1, (2, 2), OR (R A, RR_indirect HL)
    | 0xB7 -> l1, (1, 1), OR (R A, R A)
    | 0xB8 -> l1, (1, 1), CP (R A, R B)
    | 0xB9 -> l1, (1, 1), CP (R A, R C)
    | 0xBA -> l1, (1, 1), CP (R A, R D)
    | 0xBB -> l1, (1, 1), CP (R A, R E)
    | 0xBC -> l1, (1, 1), CP (R A, R H)
    | 0xBD -> l1, (1, 1), CP (R A, R L)
    | 0xBE -> l1, (2, 2), CP (R A, RR_indirect HL)
    | 0xBF -> l1, (1, 1), CP (R A, R A)
    | 0xC0 -> l1, (2, 5), RET NZ
    | 0xC1 -> l1, (3, 3), POP BC
    | 0xC2 -> l3, (3, 4), JP (NZ, Immediate16 (next_word ()))
    | 0xC3 -> l3, (4, 4), JP (None, Immediate16 (next_word ()))
    | 0xC4 -> l3, (3, 6), CALL (NZ, next_word ())
    | 0xC5 -> l1, (1, 4), PUSH BC
    | 0xC6 -> l2, (2, 2), ADD8 (R A, (Immediate8 (next_byte ())))
    | 0xC7 -> l1, (4, 4), RST RST_offset.x00
    | 0xC8 -> l1, (2, 5), RET Z
    | 0xC9 -> l1, (4, 4), RET None
    | 0xCA -> l3, (3, 4), JP (Z, Immediate16 (next_word ()))
    | 0xCC -> l3, (3, 6), CALL (Z, next_word ())
    | 0xCD -> l3, (6, 6), CALL (None, next_word ())
    | 0xCE -> l2, (2, 2), ADC (R A, Immediate8 (next_byte ()))
    | 0xCF -> l1, (4, 4), RST RST_offset.x08
    | 0xD0 -> l1, (2, 5), RET NC
    | 0xD1 -> l1, (3, 3), POP DE
    | 0xD2 -> l3, (3, 4), JP (NC, Immediate16 (next_word ()))
    | 0xD3 -> l1, (1, 1), NOP
    | 0xD4 -> l3, (3, 6), CALL (NC, next_word ())
    | 0xD5 -> l1, (1, 4), PUSH DE
    | 0xD6 -> l2, (2, 2), SUB (R A, Immediate8 (next_byte ()))
    | 0xD7 -> l1, (4, 4), RST RST_offset.x10
    | 0xD8 -> l1, (2, 5), RET C
    | 0xD9 -> l1, (4, 4), RETI
    | 0xDA -> l3, (3, 4), JP (C, Immediate16 (next_word ()))
    | 0xDB -> l1, (1, 1), NOP
    | 0xDC -> l3, (3, 6), CALL (C, next_word ())
    | 0xDD -> l1, (1, 1), NOP
    | 0xDE -> l2, (2, 2), SBC (R A, Immediate8 (next_byte ()))
    | 0xDF -> l1, (4, 4), RST RST_offset.x18
    | 0xE0 -> l2, (3, 3), LD8 (FF00_offset (next_byte ()), R A)
    | 0xE1 -> l1, (3, 3), POP HL
    | 0xE2 -> l1, (2, 2), LD8 (FF00_C, R A)
    | 0xE3 -> l1, (1, 1), NOP
    | 0xE4 -> l1, (1, 1), NOP
    | 0xE5 -> l1, (4, 4), PUSH HL
    | 0xE6 -> l2, (2, 2), AND (R A, Immediate8 (next_byte ()))
    | 0xE7 -> l1, (4, 4), RST RST_offset.x20
    | 0xE8 -> l2, (4, 4), ADDSP (next_byte ())
    | 0xE9 -> l1, (1, 1), JP (None, RR HL)
    | 0xEA -> l3, (4, 4), LD8 (Direct8 (next_word ()), R A)
    | 0xEB -> l1, (1, 1), NOP
    | 0xEC -> l1, (1, 1), NOP
    | 0xED -> l1, (1, 1), NOP
    | 0xEE -> l2, (2, 2), XOR (R A, Immediate8 (next_byte ()))
    | 0xEF -> l1, (4, 4), RST RST_offset.x28
    | 0xF0 -> l2, (3, 3), LD8 (R A, FF00_offset (next_byte ()))
    | 0xF1 -> l1, (3, 3), POP AF
    | 0xF2 -> l1, (2, 2), LD8 (R A, FF00_C)
    | 0xF3 -> l1, (1, 1), DI
    | 0xF4 -> l1, (1, 1), NOP
    | 0xF5 -> l1, (4, 4), PUSH AF
    | 0xF6 -> l2, (2, 2), OR (R A, Immediate8 (next_byte ()))
    | 0xF7 -> l1, (4, 4), RST RST_offset.x30
    | 0xF8 -> l2, (3, 3), LD16 (RR HL, SP_offset (Int8.of_byte @@ next_byte ()))
    | 0xF9 -> l1, (2, 2), LD16 (SP, RR HL)
    | 0xFA -> l3, (4, 4), LD8 (R A, Direct8 (next_word ()))
    | 0xFB -> l1, (1, 1), EI
    | 0xFC -> l1, (1, 1), NOP
    | 0xFD -> l1, (1, 1), NOP
    | 0xFE -> l2, (2, 2), CP (R A, Immediate8 (next_byte ()))
    | 0xFF -> l1, (4, 4), RST RST_offset.x38
    | 0xCB -> begin
        let op = next_byte () |> Uint8.to_int in
        match op with
        | 0x00 -> l2, (2, 2), RLC (R B)
        | 0x01 -> l2, (2, 2), RLC (R C)
        | 0x02 -> l2, (2, 2), RLC (R D)
        | 0x03 -> l2, (2, 2), RLC (R E)
        | 0x04 -> l2, (2, 2), RLC (R H)
        | 0x05 -> l2, (2, 2), RLC (R L)
        | 0x06 -> l2, (4, 4), RLC (RR_indirect HL)
        | 0x07 -> l2, (2, 2), RRC (R A)
        | 0x08 -> l2, (2, 2), RRC (R B)
        | 0x09 -> l2, (2, 2), RRC (R C)
        | 0x0A -> l2, (2, 2), RRC (R D)
        | 0x0B -> l2, (2, 2), RRC (R E)
        | 0x0C -> l2, (2, 2), RRC (R H)
        | 0x0D -> l2, (2, 2), RRC (R L)
        | 0x0E -> l2, (4, 4), RRC (RR_indirect HL)
        | 0x0F -> l2, (2, 2), RRC (R A)
        | 0x10 -> l2, (2, 2), RL (R B)
        | 0x11 -> l2, (2, 2), RL (R C)
        | 0x12 -> l2, (2, 2), RL (R D)
        | 0x13 -> l2, (2, 2), RL (R E)
        | 0x14 -> l2, (2, 2), RL (R H)
        | 0x15 -> l2, (2, 2), RL (R L)
        | 0x16 -> l2, (4, 4), RL (RR_indirect HL)
        | 0x17 -> l2, (2, 2), RR (R A)
        | 0x18 -> l2, (2, 2), RR (R B)
        | 0x19 -> l2, (2, 2), RR (R C)
        | 0x1A -> l2, (2, 2), RR (R D)
        | 0x1B -> l2, (2, 2), RR (R E)
        | 0x1C -> l2, (2, 2), RR (R H)
        | 0x1D -> l2, (2, 2), RR (R L)
        | 0x1E -> l2, (4, 4), RR (RR_indirect HL)
        | 0x1F -> l2, (2, 2), RR (R A)
        | 0x20 -> l2, (2, 2), SLA (R B)
        | 0x21 -> l2, (2, 2), SLA (R C)
        | 0x22 -> l2, (2, 2), SLA (R D)
        | 0x23 -> l2, (2, 2), SLA (R E)
        | 0x24 -> l2, (2, 2), SLA (R H)
        | 0x25 -> l2, (2, 2), SLA (R L)
        | 0x26 -> l2, (4, 4), SLA (RR_indirect HL)
        | 0x27 -> l2, (2, 2), SRA (R A)
        | 0x28 -> l2, (2, 2), SRA (R B)
        | 0x29 -> l2, (2, 2), SRA (R C)
        | 0x2A -> l2, (2, 2), SRA (R D)
        | 0x2B -> l2, (2, 2), SRA (R E)
        | 0x2C -> l2, (2, 2), SRA (R H)
        | 0x2D -> l2, (2, 2), SRA (R L)
        | 0x2E -> l2, (4, 4), SRA (RR_indirect HL)
        | 0x2F -> l2, (2, 2), SRA (R A)
        | 0x30 -> l2, (2, 2), SWAP (R B)
        | 0x31 -> l2, (2, 2), SWAP (R C)
        | 0x32 -> l2, (2, 2), SWAP (R D)
        | 0x33 -> l2, (2, 2), SWAP (R E)
        | 0x34 -> l2, (2, 2), SWAP (R H)
        | 0x35 -> l2, (2, 2), SWAP (R L)
        | 0x36 -> l2, (4, 4), SWAP (RR_indirect HL)
        | 0x37 -> l2, (2, 2), SRL (R A)
        | 0x38 -> l2, (2, 2), SRL (R B)
        | 0x39 -> l2, (2, 2), SRL (R C)
        | 0x3A -> l2, (2, 2), SRL (R D)
        | 0x3B -> l2, (2, 2), SRL (R E)
        | 0x3C -> l2, (2, 2), SRL (R H)
        | 0x3D -> l2, (2, 2), SRL (R L)
        | 0x3E -> l2, (4, 4), SRL (RR_indirect HL)
        | 0x3F -> l2, (2, 2), SRL (R A)
        | 0x40 -> l2, (2, 2), BIT (Bit_pos.b0, R B)
        | 0x41 -> l2, (2, 2), BIT (Bit_pos.b0, R C)
        | 0x42 -> l2, (2, 2), BIT (Bit_pos.b0, R D)
        | 0x43 -> l2, (2, 2), BIT (Bit_pos.b0, R E)
        | 0x44 -> l2, (2, 2), BIT (Bit_pos.b0, R H)
        | 0x45 -> l2, (2, 2), BIT (Bit_pos.b0, R L)
        | 0x46 -> l2, (4, 4), BIT (Bit_pos.b0, RR_indirect HL)
        | 0x47 -> l2, (2, 2), BIT (Bit_pos.b1, R A)
        | 0x48 -> l2, (2, 2), BIT (Bit_pos.b1, R B)
        | 0x49 -> l2, (2, 2), BIT (Bit_pos.b1, R C)
        | 0x4A -> l2, (2, 2), BIT (Bit_pos.b1, R D)
        | 0x4B -> l2, (2, 2), BIT (Bit_pos.b1, R E)
        | 0x4C -> l2, (2, 2), BIT (Bit_pos.b1, R H)
        | 0x4D -> l2, (2, 2), BIT (Bit_pos.b1, R L)
        | 0x4E -> l2, (4, 4), BIT (Bit_pos.b1, RR_indirect HL)
        | 0x4F -> l2, (2, 2), BIT (Bit_pos.b1, R A)
        | 0x50 -> l2, (2, 2), BIT (Bit_pos.b2, R B)
        | 0x51 -> l2, (2, 2), BIT (Bit_pos.b2, R C)
        | 0x52 -> l2, (2, 2), BIT (Bit_pos.b2, R D)
        | 0x53 -> l2, (2, 2), BIT (Bit_pos.b2, R E)
        | 0x54 -> l2, (2, 2), BIT (Bit_pos.b2, R H)
        | 0x55 -> l2, (2, 2), BIT (Bit_pos.b2, R L)
        | 0x56 -> l2, (4, 4), BIT (Bit_pos.b2, RR_indirect HL)
        | 0x57 -> l2, (2, 2), BIT (Bit_pos.b3, R A)
        | 0x58 -> l2, (2, 2), BIT (Bit_pos.b3, R B)
        | 0x59 -> l2, (2, 2), BIT (Bit_pos.b3, R C)
        | 0x5A -> l2, (2, 2), BIT (Bit_pos.b3, R D)
        | 0x5B -> l2, (2, 2), BIT (Bit_pos.b3, R E)
        | 0x5C -> l2, (2, 2), BIT (Bit_pos.b3, R H)
        | 0x5D -> l2, (2, 2), BIT (Bit_pos.b3, R L)
        | 0x5E -> l2, (4, 4), BIT (Bit_pos.b3, RR_indirect HL)
        | 0x5F -> l2, (2, 2), BIT (Bit_pos.b3, R A)
        | 0x60 -> l2, (2, 2), BIT (Bit_pos.b4, R B)
        | 0x61 -> l2, (2, 2), BIT (Bit_pos.b4, R C)
        | 0x62 -> l2, (2, 2), BIT (Bit_pos.b4, R D)
        | 0x63 -> l2, (2, 2), BIT (Bit_pos.b4, R E)
        | 0x64 -> l2, (2, 2), BIT (Bit_pos.b4, R H)
        | 0x65 -> l2, (2, 2), BIT (Bit_pos.b4, R L)
        | 0x66 -> l2, (4, 4), BIT (Bit_pos.b4, RR_indirect HL)
        | 0x67 -> l2, (2, 2), BIT (Bit_pos.b5, R A)
        | 0x68 -> l2, (2, 2), BIT (Bit_pos.b5, R B)
        | 0x69 -> l2, (2, 2), BIT (Bit_pos.b5, R C)
        | 0x6A -> l2, (2, 2), BIT (Bit_pos.b5, R D)
        | 0x6B -> l2, (2, 2), BIT (Bit_pos.b5, R E)
        | 0x6C -> l2, (2, 2), BIT (Bit_pos.b5, R H)
        | 0x6D -> l2, (2, 2), BIT (Bit_pos.b5, R L)
        | 0x6E -> l2, (4, 4), BIT (Bit_pos.b5, RR_indirect HL)
        | 0x6F -> l2, (2, 2), BIT (Bit_pos.b5, R A)
        | 0x70 -> l2, (2, 2), BIT (Bit_pos.b6, R B)
        | 0x71 -> l2, (2, 2), BIT (Bit_pos.b6, R C)
        | 0x72 -> l2, (2, 2), BIT (Bit_pos.b6, R D)
        | 0x73 -> l2, (2, 2), BIT (Bit_pos.b6, R E)
        | 0x74 -> l2, (2, 2), BIT (Bit_pos.b6, R H)
        | 0x75 -> l2, (2, 2), BIT (Bit_pos.b6, R L)
        | 0x76 -> l2, (4, 4), BIT (Bit_pos.b6, RR_indirect HL)
        | 0x77 -> l2, (2, 2), BIT (Bit_pos.b7, R A)
        | 0x78 -> l2, (2, 2), BIT (Bit_pos.b7, R B)
        | 0x79 -> l2, (2, 2), BIT (Bit_pos.b7, R C)
        | 0x7A -> l2, (2, 2), BIT (Bit_pos.b7, R D)
        | 0x7B -> l2, (2, 2), BIT (Bit_pos.b7, R E)
        | 0x7C -> l2, (2, 2), BIT (Bit_pos.b7, R H)
        | 0x7D -> l2, (2, 2), BIT (Bit_pos.b7, R L)
        | 0x7E -> l2, (4, 4), BIT (Bit_pos.b7, RR_indirect HL)
        | 0x7F -> l2, (2, 2), BIT (Bit_pos.b7, R A)
        | 0x80 -> l2, (2, 2), RES (Bit_pos.b0, R B)
        | 0x81 -> l2, (2, 2), RES (Bit_pos.b0, R C)
        | 0x82 -> l2, (2, 2), RES (Bit_pos.b0, R D)
        | 0x83 -> l2, (2, 2), RES (Bit_pos.b0, R E)
        | 0x84 -> l2, (2, 2), RES (Bit_pos.b0, R H)
        | 0x85 -> l2, (2, 2), RES (Bit_pos.b0, R L)
        | 0x86 -> l2, (4, 4), RES (Bit_pos.b0, RR_indirect HL)
        | 0x87 -> l2, (2, 2), RES (Uint8.one, R A)
        | 0x88 -> l2, (2, 2), RES (Uint8.one, R B)
        | 0x89 -> l2, (2, 2), RES (Uint8.one, R C)
        | 0x8A -> l2, (2, 2), RES (Uint8.one, R D)
        | 0x8B -> l2, (2, 2), RES (Uint8.one, R E)
        | 0x8C -> l2, (2, 2), RES (Uint8.one, R H)
        | 0x8D -> l2, (2, 2), RES (Uint8.one, R L)
        | 0x8E -> l2, (4, 4), RES (Uint8.one, RR_indirect HL)
        | 0x8F -> l2, (2, 2), RES (Uint8.one, R A)
        | 0x90 -> l2, (2, 2), RES (Bit_pos.b2, R B)
        | 0x91 -> l2, (2, 2), RES (Bit_pos.b2, R C)
        | 0x92 -> l2, (2, 2), RES (Bit_pos.b2, R D)
        | 0x93 -> l2, (2, 2), RES (Bit_pos.b2, R E)
        | 0x94 -> l2, (2, 2), RES (Bit_pos.b2, R H)
        | 0x95 -> l2, (2, 2), RES (Bit_pos.b2, R L)
        | 0x96 -> l2, (4, 4), RES (Bit_pos.b2, RR_indirect HL)
        | 0x97 -> l2, (2, 2), RES (Bit_pos.b3, R A)
        | 0x98 -> l2, (2, 2), RES (Bit_pos.b3, R B)
        | 0x99 -> l2, (2, 2), RES (Bit_pos.b3, R C)
        | 0x9A -> l2, (2, 2), RES (Bit_pos.b3, R D)
        | 0x9B -> l2, (2, 2), RES (Bit_pos.b3, R E)
        | 0x9C -> l2, (2, 2), RES (Bit_pos.b3, R H)
        | 0x9D -> l2, (2, 2), RES (Bit_pos.b3, R L)
        | 0x9E -> l2, (4, 4), RES (Bit_pos.b3, RR_indirect HL)
        | 0x9F -> l2, (2, 2), RES (Bit_pos.b3, R A)
        | 0xA0 -> l2, (2, 2), RES (Bit_pos.b4, R B)
        | 0xA1 -> l2, (2, 2), RES (Bit_pos.b4, R C)
        | 0xA2 -> l2, (2, 2), RES (Bit_pos.b4, R D)
        | 0xA3 -> l2, (2, 2), RES (Bit_pos.b4, R E)
        | 0xA4 -> l2, (2, 2), RES (Bit_pos.b4, R H)
        | 0xA5 -> l2, (2, 2), RES (Bit_pos.b4, R L)
        | 0xA6 -> l2, (4, 4), RES (Bit_pos.b4, RR_indirect HL)
        | 0xA7 -> l2, (2, 2), RES (Bit_pos.b5, R A)
        | 0xA8 -> l2, (2, 2), RES (Bit_pos.b5, R B)
        | 0xA9 -> l2, (2, 2), RES (Bit_pos.b5, R C)
        | 0xAA -> l2, (2, 2), RES (Bit_pos.b5, R D)
        | 0xAB -> l2, (2, 2), RES (Bit_pos.b5, R E)
        | 0xAC -> l2, (2, 2), RES (Bit_pos.b5, R H)
        | 0xAD -> l2, (2, 2), RES (Bit_pos.b5, R L)
        | 0xAE -> l2, (4, 4), RES (Bit_pos.b5, RR_indirect HL)
        | 0xAF -> l2, (2, 2), RES (Bit_pos.b5, R A)
        | 0xB0 -> l2, (2, 2), RES (Bit_pos.b6, R B)
        | 0xB1 -> l2, (2, 2), RES (Bit_pos.b6, R C)
        | 0xB2 -> l2, (2, 2), RES (Bit_pos.b6, R D)
        | 0xB3 -> l2, (2, 2), RES (Bit_pos.b6, R E)
        | 0xB4 -> l2, (2, 2), RES (Bit_pos.b6, R H)
        | 0xB5 -> l2, (2, 2), RES (Bit_pos.b6, R L)
        | 0xB6 -> l2, (4, 4), RES (Bit_pos.b6, RR_indirect HL)
        | 0xB7 -> l2, (2, 2), RES (Bit_pos.b7, R A)
        | 0xB8 -> l2, (2, 2), RES (Bit_pos.b7, R B)
        | 0xB9 -> l2, (2, 2), RES (Bit_pos.b7, R C)
        | 0xBA -> l2, (2, 2), RES (Bit_pos.b7, R D)
        | 0xBB -> l2, (2, 2), RES (Bit_pos.b7, R E)
        | 0xBC -> l2, (2, 2), RES (Bit_pos.b7, R H)
        | 0xBD -> l2, (2, 2), RES (Bit_pos.b7, R L)
        | 0xBE -> l2, (4, 4), RES (Bit_pos.b7, RR_indirect HL)
        | 0xBF -> l2, (2, 2), RES (Bit_pos.b7, R A)
        | 0xC0 -> l2, (2, 2), SET (Bit_pos.b0, R B)
        | 0xC1 -> l2, (2, 2), SET (Bit_pos.b0, R C)
        | 0xC2 -> l2, (2, 2), SET (Bit_pos.b0, R D)
        | 0xC3 -> l2, (2, 2), SET (Bit_pos.b0, R E)
        | 0xC4 -> l2, (2, 2), SET (Bit_pos.b0, R H)
        | 0xC5 -> l2, (2, 2), SET (Bit_pos.b0, R L)
        | 0xC6 -> l2, (4, 4), SET (Bit_pos.b0, RR_indirect HL)
        | 0xC7 -> l2, (2, 2), SET (Bit_pos.b1, R A)
        | 0xC8 -> l2, (2, 2), SET (Bit_pos.b1, R B)
        | 0xC9 -> l2, (2, 2), SET (Bit_pos.b1, R C)
        | 0xCA -> l2, (2, 2), SET (Bit_pos.b1, R D)
        | 0xCB -> l2, (2, 2), SET (Bit_pos.b1, R E)
        | 0xCC -> l2, (2, 2), SET (Bit_pos.b1, R H)
        | 0xCD -> l2, (2, 2), SET (Bit_pos.b1, R L)
        | 0xCE -> l2, (4, 4), SET (Bit_pos.b1, RR_indirect HL)
        | 0xCF -> l2, (2, 2), SET (Bit_pos.b1, R A)
        | 0xD0 -> l2, (2, 2), SET (Bit_pos.b2, R B)
        | 0xD1 -> l2, (2, 2), SET (Bit_pos.b2, R C)
        | 0xD2 -> l2, (2, 2), SET (Bit_pos.b2, R D)
        | 0xD3 -> l2, (2, 2), SET (Bit_pos.b2, R E)
        | 0xD4 -> l2, (2, 2), SET (Bit_pos.b2, R H)
        | 0xD5 -> l2, (2, 2), SET (Bit_pos.b2, R L)
        | 0xD6 -> l2, (4, 4), SET (Bit_pos.b2, RR_indirect HL)
        | 0xD7 -> l2, (2, 2), SET (Bit_pos.b3, R A)
        | 0xD8 -> l2, (2, 2), SET (Bit_pos.b3, R B)
        | 0xD9 -> l2, (2, 2), SET (Bit_pos.b3, R C)
        | 0xDA -> l2, (2, 2), SET (Bit_pos.b3, R D)
        | 0xDB -> l2, (2, 2), SET (Bit_pos.b3, R E)
        | 0xDC -> l2, (2, 2), SET (Bit_pos.b3, R H)
        | 0xDD -> l2, (2, 2), SET (Bit_pos.b3, R L)
        | 0xDE -> l2, (4, 4), SET (Bit_pos.b3, RR_indirect HL)
        | 0xDF -> l2, (2, 2), SET (Bit_pos.b3, R A)
        | 0xE0 -> l2, (2, 2), SET (Bit_pos.b4, R B)
        | 0xE1 -> l2, (2, 2), SET (Bit_pos.b4, R C)
        | 0xE2 -> l2, (2, 2), SET (Bit_pos.b4, R D)
        | 0xE3 -> l2, (2, 2), SET (Bit_pos.b4, R E)
        | 0xE4 -> l2, (2, 2), SET (Bit_pos.b4, R H)
        | 0xE5 -> l2, (2, 2), SET (Bit_pos.b4, R L)
        | 0xE6 -> l2, (4, 4), SET (Bit_pos.b4, RR_indirect HL)
        | 0xE7 -> l2, (2, 2), SET (Bit_pos.b5, R A)
        | 0xE8 -> l2, (2, 2), SET (Bit_pos.b5, R B)
        | 0xE9 -> l2, (2, 2), SET (Bit_pos.b5, R C)
        | 0xEA -> l2, (2, 2), SET (Bit_pos.b5, R D)
        | 0xEB -> l2, (2, 2), SET (Bit_pos.b5, R E)
        | 0xEC -> l2, (2, 2), SET (Bit_pos.b5, R H)
        | 0xED -> l2, (2, 2), SET (Bit_pos.b5, R L)
        | 0xEE -> l2, (4, 4), SET (Bit_pos.b5, RR_indirect HL)
        | 0xEF -> l2, (2, 2), SET (Bit_pos.b5, R A)
        | 0xF0 -> l2, (2, 2), SET (Bit_pos.b6, R B)
        | 0xF1 -> l2, (2, 2), SET (Bit_pos.b6, R C)
        | 0xF2 -> l2, (2, 2), SET (Bit_pos.b6, R D)
        | 0xF3 -> l2, (2, 2), SET (Bit_pos.b6, R E)
        | 0xF4 -> l2, (2, 2), SET (Bit_pos.b6, R H)
        | 0xF5 -> l2, (2, 2), SET (Bit_pos.b6, R L)
        | 0xF6 -> l2, (4, 4), SET (Bit_pos.b6, RR_indirect HL)
        | 0xF7 -> l2, (2, 2), SET (Bit_pos.b7, R A)
        | 0xF8 -> l2, (2, 2), SET (Bit_pos.b7, R B)
        | 0xF9 -> l2, (2, 2), SET (Bit_pos.b7, R C)
        | 0xFA -> l2, (2, 2), SET (Bit_pos.b7, R D)
        | 0xFB -> l2, (2, 2), SET (Bit_pos.b7, R E)
        | 0xFC -> l2, (2, 2), SET (Bit_pos.b7, R H)
        | 0xFD -> l2, (2, 2), SET (Bit_pos.b7, R L)
        | 0xFE -> l2, (4, 4), SET (Bit_pos.b7, RR_indirect HL)
        | 0xFF -> l2, (2, 2), SET (Bit_pos.b7, R A)
        | _ -> failwith (Printf.sprintf "Unrecognized opcode after 0xCB: 0x%02x" op)
      end
    | _ -> failwith (Printf.sprintf "Unrecognized opcode: 0x%02x" op)
end
