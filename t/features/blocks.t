use v6;
use Test;
use _007::Test;

{
    my $ast = q:to/./;
        (stmtlist
          (stblock (block (parameterlist) (stmtlist
            (stexpr (postfix:<()> (identifier "say") (arglist (str "OH HAI from inside block"))))))))
        .

    is-result $ast, "OH HAI from inside block\n", "immediate blocks work";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "x") (str "one"))
          (stexpr (postfix:<()> (identifier "say") (arglist (identifier "x"))))
          (stblock (block (parameterlist) (stmtlist
            (my (identifier "x") (str "two"))
            (stexpr (postfix:<()> (identifier "say") (arglist (identifier "x")))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (identifier "x")))))
        .

    is-result $ast, "one\ntwo\none\n", "blocks have their own variable scope";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "b") (block (parameterlist (param (identifier "name"))) (stmtlist
            (stexpr (postfix:<()> (identifier "say") (arglist (infix:<~> (str "Good evening, Mr ") (identifier "name"))))))))
          (stexpr (postfix:<()> (identifier "b") (arglist (str "Bond")))))
        .

    is-result $ast, "Good evening, Mr Bond\n", "calling a block with parameters works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "b") (block (parameterlist (param (identifier "X")) (param (identifier "Y"))) (stmtlist
            (stexpr (postfix:<()> (identifier "say") (arglist (infix:<~> (identifier "X") (identifier "Y"))))))))
          (my (identifier "X") (str "y"))
          (stexpr (postfix:<()> (identifier "b") (arglist (str "X") (infix:<~> (identifier "X") (identifier "X"))))))
        .

    is-result $ast, "Xyy\n", "arguments are evaluated before parameters are bound";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "b") (block (parameterlist (param (identifier "callback"))) (stmtlist
            (my (identifier "scoping") (str "dynamic"))
            (stexpr (postfix:<()> (identifier "callback") (arglist))))))
          (my (identifier "scoping") (str "lexical"))
          (stexpr (postfix:<()> (identifier "b") (arglist (block (parameterlist) (stmtlist
            (stexpr (postfix:<()> (identifier "say") (arglist (identifier "scoping"))))))))))
        .

    is-result $ast, "lexical\n", "scoping is lexical";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "b") (block (parameterlist (param (identifier "count"))) (stmtlist
            (if (identifier "count") (block (parameterlist) (stmtlist
              (stexpr (postfix:<()> (identifier "b") (arglist (infix:<+> (identifier "count") (prefix:<-> (int 1))))))
              (stexpr (postfix:<()> (identifier "say") (arglist (identifier "count"))))))))))
          (stexpr (postfix:<()> (identifier "b") (arglist (int 4)))))
        .

    is-result $ast, "1\n2\n3\n4\n", "each block invocation gets its own callframe/scope";
}

done-testing;
