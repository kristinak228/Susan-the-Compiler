(* ERROR: non-integer type for array index *)
program main( input, output );
  var a: array[0..9] of real;
  var b: array[0..9,0..9] of real;
  var x: real;
begin
  x := 4.0;
  b[x,x] := 1.23
end.

