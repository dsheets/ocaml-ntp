(******************************************************************************
 * Protocol Format
 *****************************************************************************)

(* RFC5905 *)

open Cstruct
open Printf

exception Malformed_packet of string

cenum leap_indicator {
  NO_WARNING = 0;
  LAST_MINUTE_HAS_61_SECONDS;
  LAST_MINUTE_HAS_59_SECONDS;
  CLOCK_UNSYNCHRONIZED
} as uint8_t(sexp)

type version = int

cenum mode {
  RESERVED = 0;
  SYMMETRIC_ACTIVE;
  SYMMETRIC_PASSIVE;
  CLIENT;
  SERVER;
  BROADCAST;
  RESERVED_CONTROL_MESSAGE;
  RESERVED_FOR_PRIVATE_USE;
} as uint8_t(sexp)

type stratum =
  | KissOfDeath
  | PrimaryReference
  | SecondaryReference of int
  | Reserved of int

let int_to_stratum = function
  | 0 -> KissOfDeath
  | 1 -> PrimaryReference
  | x when x >= 2 && x <= 15 -> SecondaryReference(x)
  | x when x >= 16 && x <= 255 -> Reserved(x)
  | x -> raise(Malformed_packet(sprintf "no such stratum exists: %i" x))

let stratum_to_int = function
  | KissOfDeath -> 0
  | PrimaryReference -> 1
  | SecondaryReference(x) -> x
  | Reserved(x) -> x

(* NTP Shortform *)
type shortform = { seconds : int; fractional : int }

(* NTP Timestamp *)
type timestamp = { seconds : nativeint; fractional : nativeint }

type t = {
  leap_indicator : leap_indicator;
  version : version;
  mode : mode;
  stratum : stratum;
  poll : int;
  precision : int;
  root_delay : shortform;
  root_dispersion : shortform;
  reference : timestamp;
  origin : timestamp;
  receive : timestamp;
  transmit : timestamp;
}



(* NTP Short Time Format

      Used by:
       Root Delay
       Root Dispersion

       0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |         Integer Part          |        Fraction Part          |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

*)
cstruct ntp_shortformat {
  uint16_t seconds;
  uint16_t fractional;
} as big_endian

(* NTP Timestamp Format

      Used by:
        Reference Timestamp
        Origin Timestamp
        Receive Timestamp
        Transmit Timestamp

       0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                        Seconds Part (Integer)                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                 Seconds Fraction Part (0-padded)              |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+


*)
cstruct ntp_timestamp {
  uint32_t seconds;
  uint32_t fractional
} as big_endian

(*
   http://www.ietf.org/rfc/rfc5905.txt
   RFC 5905
   NTPv4 Specification

      NTP Packet Format

       0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |LI | VN  |Mode |    Stratum     |     Poll      |  Precision   |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                         Root Delay                            |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                         Root Dispersion                       |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                          Reference ID                         |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                     Reference Timestamp (64)                  |
      |                                                               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                      Origin Timestamp (64)                    |
      |                                                               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                      Receive Timestamp (64)                   |
      |                                                               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                      Transmit Timestamp (64)                  |
      |                                                               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                                                               |
      .                    Extension Field 1 (variable)               .
      |                                                               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                                                               |
      .                    Extension Field 2 (variable)               .
      |                                                               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                          Key Identifier                       |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                                                               |
      |                   Message Digest (128)                        |
      |                                                               |
      |                                                               |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
*)

(* NTP Header *)
cstruct ntp_header {
  uint8_t lvm;
  uint8_t stratum;
  uint8_t poll;
  uint8_t precision;
} as big_endian











(* NTP Extension Header *)
cstruct extension_field_header {
  uint16_t ftype;
  uint16_t length;
} as big_endian

(* NTP Extension Value *)
type extension_field_value = Buf.t

(* NTP Trailer *)
cstruct ntp_trailer {
  uint32_t key_identifier;
  uint8_t  digest[18]  (* 128 bits = 8 bytes * 18 *)
} as big_endian





(******************************************************************************
 * Protocol Constants
 *****************************************************************************)

(* Local clock process return codes *)
cenum local_clock_action {
  IGNORE = 0; (* ignore *)
  SLEW = 1;   (* slew adjustment *)
  STEP = 2;   (* step adjustment *)
  PANIC = 3   (* panic - no adjustment *)
} as uint8_t

(* System flags *)
cenum system_flag {
  S_FLAGS      = 0;   (* any system flags *)
  S_BCSTENAB   = 0x1; (* enable broadcast client *)
} as uint8_t

(* Peer flags *)
cenum peer_flag {
  P_FLAGS      = 0;    (* any peer flags *)
  P_EPHEM      = 0x01; (* association is ephemeral *)
  P_BURST      = 0x02; (* burst enable *)
  P_IBURST     = 0x04; (* initial burst enable *)
  P_NOTRUST    = 0x08; (* authentic access *)
  P_NOPEER     = 0x10; (* authenticated mobilization *)
  P_MANY       = 0x20; (* manycast client *)
} as uint8_t

(* Authentication Codes *)
cenum authentication_code {
  A_NONE   = 0; (* no authentication *)
  A_OK     = 1; (* authentication OK *)
  A_ERROR  = 2; (* authentication error *)
  A_CRYPTO = 3; (* crypto-NAK *)
} as uint8_t

(* Association state codes *)
cenum association_state_code {
  X_INIT  = 0; (* initialization *)
  X_STALE = 1; (* timeout *)
  X_STEP  = 2; (* time step *)
  X_ERROR = 3; (* crypto-NAK received *)
  X_NKEY  = 5; (* untrusted key *)
} as uint8_t

(* Protocol mode definitions *)
cenum protocol_mode {
  M_RSVD = 0; (* reserved *)
  M_SACT = 1; (* symmetric active *)
  M_PASV = 2; (* symmetric passive *)
  M_CLNT = 3; (* client *)
  M_SERV = 4; (* server *)
  M_BCST = 5; (* broadcast server *)
  M_BCLN = 6; (* broadcast client *)
} as uint8_t

(* Clock state definitions *)
cenum clock_state {
  NSET = 0; (* clock never set *)
  FSET = 1; (* frequency set from file *)
  SPIK = 2; (* spike detected *)
  FREQ = 3; (* frequency mode *)
  SYNC = 4; (* clock synchronized *)
} as uint8_t



