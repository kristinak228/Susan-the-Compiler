(* ERROR: procedure passed wrong number/type of arguments *)
program main( input, output );
  var b: integer;
  var y: real;
  {hello}
  procedure boo(a: integer; x: real);
  begin
  end;
begin
  boo(b,10.9)
end.
