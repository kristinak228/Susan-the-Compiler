(* ERROR: objects of different types appear in the same expression *)
program main( input, output );
  var a: integer;
  var x: real;
  (*var n: array [1..10] of integer;*)
begin
  (*n[1] := 3;*)
  (*x := n[1]*)
  a := a + 123;
  x := x + 123
end.

