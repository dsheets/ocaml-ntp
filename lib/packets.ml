(******************************************************************************
 * Protocol Constants
 *****************************************************************************)

(* RFC5905 *)

open Cstruct

(* Local clock process return codes *)
cenum local_clock_action {
  IGNORE = 0; (* ignore *)
  SLEW = 1;   (* slew adjustment *)
  STEP = 2;   (* step adjustment *)
  PANIC = 3   (* panic - no adjustment *)
} as uint8_t

(* System flags *)
cenum system_flags {
  FLAGS = 0;  (* any system flags *)
  BCSTENAB = 0x1; (* enable broadcast client *)
}

(* Peer flags *)
cenum peer_flags {
  FLAGS = 0;
}
