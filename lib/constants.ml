(******************************************************************************
 * Global Constants
 *****************************************************************************)

(* NTP Version number *)
let _VERSION = 4

(* NTP Port number *)
let _PORT = 123

(* % of minimum dispersions *)
let _MINDISP = 0.01

(* maximum dispersions *)
let _MAXDISP = 16

(* % distance threshold *)
let _MAXDIST = 1

(* leap unsync *)
let _NOSYNC  = 0x3

(* maximum stratum (infinity metric) *)
let _MAXSTRAT = 16

(* % minimum poll interval (64 s) *)
let _MINPOLL = 6

(* % maximum poll interval (36.4 h) *)
let _MAXPOLL = 17

(* minimum manycast survivors *)
let _MINCLOCK = 3

(* maximum manycast candidates *)
let _MAXCLOCK = 10

(* max ttl manycast *)
let _TTLMAX = 8

(* max interval between beacons *)
let _BEACON = 15

(* % frequency tolerance (15 ppm) *)
let _PHI = 15e-6

(* clock register stages *)
let _NSTAGE = 8

(* maximum number of peers *)
let _NMAX = 50

(* % minimum intersection survivors *)
let _NSANE = 1

(* % minimum cluster survivors *)
let _NMIN = 3


