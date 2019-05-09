(* Error on last expr: expr must return a typed-value *)
program main(input,output);
  (* breaks on mult. vars declared at once *)
 var a,b,c: integer;
 var x,y,z: real;
begin
 a := b + c;
 x := y + z;
 a := x
end.

