(******************************************************************************
 * Protocol Constants
 *****************************************************************************)

(* RFC5905 *)

open Printf
open Operators
open Name
open Cstruct

(* Local clock process return codes *)
cenum local_clock {
  IGNORE = 0; (* ignore *)
  SLEW = 1;   (* slew adjustment *)
  STEP = 2;   (* step adjustment *)
  PANIC = 3   (* panic - no adjustment *)
} as uint8_t


