(**
 * Copyright (c) 2015, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the "hack" directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 *)

let with_pipe f =
  let fd_r, fd_w = Unix.pipe () in
  try
    let res = f fd_r fd_w in
    Unix.close fd_r;
    Unix.close fd_w;
    res
  with exn ->
    Unix.close fd_r;
    Unix.close fd_w;
    raise exn

let with_in_channel filename f =
  let ic = open_in_bin filename in
  try let res = f ic in close_in ic; res
  with exn -> close_in ic; raise exn

let with_out_channel filename f =
  let oc = open_out_bin filename in
  try let res = f oc in close_out oc; res
  with exn -> close_out oc; raise exn

(* Read the first line in stdout or stderr of an external command. *)
let read_process_output name args =
  with_pipe @@ fun in_r in_w ->
  with_pipe @@ fun out_r out_w ->
  let pid = Unix.create_process name args in_r out_w out_w in
  match Unix.waitpid [] pid with
  | _, Unix.WEXITED 0 ->
      input_line (Unix.in_channel_of_descr out_r)
  | _, Unix.WEXITED 127 ->
      raise (Failure (name ^ ": command not found"))
  | _, Unix.WEXITED 128 ->
      raise (Failure (input_line (Unix.in_channel_of_descr out_r)))
  | _, Unix.WEXITED code ->
      raise (Failure (name ^ ": exited code "^(string_of_int code)))
  | _, Unix.WSIGNALED signal ->
      raise (Failure (name ^ ": killed by signal " ^ (string_of_int signal)))
  | _, Unix.WSTOPPED signal ->
      raise (Failure (name ^ ": stopped by signal " ^ (string_of_int signal)))

let string_of_file filename =
  with_in_channel filename @@ fun ic ->
  let s = String.create 32759 in
  let b = Buffer.create 1000 in
  let rec iter ic b s =
    let nread = input ic s 0 32759 in
    if nread > 0 then begin
      Buffer.add_substring b s 0 nread;
      iter ic b s
    end in
  iter ic b s;
  Buffer.contents b
