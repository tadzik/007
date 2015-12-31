use v6;
use Test;
use _007::Test;

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "u") (int 3))
          (while (identifier "u") (block (paramlist) (stmtlist
            (stexpr (postfix:<()> (identifier "say") (arglist (identifier "u"))))
            (stexpr (infix:<=> (identifier "u") (infix:<+> (identifier "u") (prefix:<-> (int 1)))))))))
        .

    is-result $ast, "3\n2\n1\n", "while loops stops when the condition is false";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "u") (int 3))
          (while (identifier "u") (block (paramlist (param (identifier "x"))) (stmtlist
            (stexpr (identifier "x"))
            (stexpr (infix:<=> (identifier "u") (infix:<+> (identifier "u") (prefix:<-> (int 1)))))))))
        .

    is-result $ast, "", "the block parameter is available from inside the loop";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "u") (int 3))
          (while (identifier "u") (block (paramlist (param (identifier "x"))) (stmtlist
            (stexpr (postfix:<()> (identifier "say") (arglist (identifier "x"))))
            (stexpr (infix:<=> (identifier "u") (infix:<+> (identifier "u") (prefix:<-> (int 1)))))))))
        .

    is-result $ast, "3\n2\n1\n", "the block parameter has the expected value";
}

{
    my $program = q:to/./;
        my u = 3;
        while u -> {
            u = u + -1;
        }
        say("alive");
        .

    outputs
        $program,
         "alive\n",
        "using -> without parameters in a block is allowed";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "u") (int 3))
          (while (identifier "u") (block (paramlist (param (identifier "a")) (param (identifier "b")) (param (identifier "c"))) (stmtlist
            (stexpr (postfix:<()> (identifier "say") (arglist (identifier "u"))))
            (stexpr (infix:<=> (identifier "u") (infix:<+> (identifier "u") (prefix:<-> (int 1)))))))))
        .

    is-error $ast, X::ParameterMismatch, "while loops don't accept more than one parameter";
}

done-testing;
