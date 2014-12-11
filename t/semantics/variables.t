use v6;
use Test;
use _007::Test;

{
    my $ast = q:to/./;
        (statements
          (vardecl (ident "u"))
          (stexpr (call (ident "say") (arguments (ident "u")))))
        .

    is-result $ast, "None\n", "variables can be declared without being assigned";
}

done;
