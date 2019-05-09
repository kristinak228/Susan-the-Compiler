(* LEGAL: set array value on both sides *)
program main( input, output );
  var c : array[0..9,0..9] of integer;
  var d : array[0..9] of integer;
  var x : integer;
  var y: real;
  function foo(a,b : array[0..9,0..9] of integer): integer;
  begin
	a[1,1] := 4
  end;	

begin
  foo(c,c);
  c[x,x] := 4;
  d[3] := 4
end.
