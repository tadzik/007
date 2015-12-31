use v6;
use Test;
use _007::Test;

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (int 1)))))
        .

    is-result $ast, "1\n", "say() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "abs") (arglist (prefix:<-> (int 1)))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "abs") (arglist (int 1)))))))
        .

    is-result $ast, "1\n1\n", "abs() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "min") (arglist (prefix:<-> (int 1)) (int 2))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "min") (arglist (int 2) (prefix:<-> (int 1))))))))
        .

    is-result $ast, "-1\n-1\n", "min() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "max") (arglist (prefix:<-> (int 1)) (int 2))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "max") (arglist (int 2) (prefix:<-> (int 1))))))))
        .

    is-result $ast, "2\n2\n", "max() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "chr") (arglist (int 97)))))))
        .

    is-result $ast, "a\n", "chr() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "ord") (arglist (str "a")))))))
        .

    is-result $ast, "97\n", "ord() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "type") (arglist (postfix:<()> (identifier "int") (arglist (str "6"))))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "type") (arglist (postfix:<()> (identifier "int") (arglist (str "-6")))))))))
        .

    is-result $ast, "<type Int>\n<type Int>\n", "int() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "type") (arglist (postfix:<()> (identifier "str") (arglist (int 6)))))))))
        .

    is-result $ast, "<type Str>\n", "str() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "chars") (arglist (str "007")))))))
        .

    is-result $ast, "3\n", "chars() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "uc") (arglist (str "test")))))))
        .

    is-result $ast, "TEST\n", "uc() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "lc") (arglist (str "TEST")))))))
        .

    is-result $ast, "test\n", "lc() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "trim") (arglist (str "  test  ")))))))
        .

    is-result $ast, "test\n", "trim() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "elems") (arglist (array (int 1) (int 2))))))))
        .

    is-result $ast, "2\n", "elems() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "reversed") (arglist (array (int 1) (int 2))))))))
        .

    is-result $ast, "[2, 1]\n", "reversed() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "sorted") (arglist (array (int 2) (int 1))))))))
        .

    is-result $ast, "[1, 2]\n", "sorted() works";
}

{
    my $ast = q:to/./;
        (stmtlist
         (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()>
          (identifier "concat") (arglist
                           (array (int 1) (int 2))
                           (array (int 3) (int 4))))))))
        .

    is-result $ast, "[1, 2, 3, 4]\n", "concat() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "join") (arglist (array (int 1) (int 2)) (str "|")))))))
        .

    is-result $ast, "1|2\n", "join() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "split") (arglist (str "a|b") (str "|")))))))
        .

    is-result $ast, qq|["a", "b"]\n|, "split() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "index") (arglist (str "abc") (str "bc"))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "index") (arglist (str "abc") (str "a"))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "index") (arglist (str "abc") (str "d")))))))
        .

    is-result $ast, "1\n0\n-1\n", "index() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "substr") (arglist (str "abc") (int 0) (int 1))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "substr") (arglist (str "abc") (int 1))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "substr") (arglist (str "abc") (int 0) (int 5)))))))
        .

    is-result $ast, "a\nbc\nabc\n", "substr() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "charat") (arglist (str "abc") (int 0)))))))
        .

    is-result $ast, "a\n", "charat() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "charat") (arglist (str "abc") (int 3)))))))
        .

    is-error $ast, X::Subscript::TooLarge, "charat() dies";
}

{
    my $ast = q:to/./;
        (stmtlist
          (sub (identifier "f") (block (parameterlist (param (identifier "n"))) (stmtlist
              (return (infix:<==> (identifier "n") (int 2))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "filter") (arglist (identifier "f") (array (int 1) (int 2) (int 3) (int 2))))))))
        .

    is-result $ast, "[2, 2]\n", "filter() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (sub (identifier "f") (block (parameterlist (param (identifier "n"))) (stmtlist
              (return (infix:<+> (identifier "n") (int 1))))))
          (my (identifier "a") (array (int 1) (int 2) (int 3)))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "map") (arglist (identifier "f") (identifier "a"))))))
          (stexpr (postfix:<()> (identifier "say") (arglist (identifier "a")))))
        .

    is-result $ast, "[2, 3, 4]\n[1, 2, 3]\n", "map() works";
}

{
    my $program = q:to/./;
        my q = Q::Literal::Int { value: 7 };

        say(melt(q));
        .

    outputs
        $program,
        qq[7\n],
        "melt() on literal int";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "q")
            (object (identifier "Q::Statement::My") (proplist
              (property "identifier" (object (identifier "Q::Identifier") (proplist
                (property "name" (str "agent")))))
              (property "expr" (str "James Bond")))))
          (stexpr (postfix:<()> (identifier "melt") (arglist (identifier "q")))))
        .

    is-error
        $ast,
        X::TypeCheck,
        "cannot melt() a statement";
}

{
    my $program = q:to/./;
        my x = "Bond";
        my q = Q::Identifier { name: "x" };

        say(melt(q));
        .

    outputs
        $program,
        qq[Bond\n],
        "melt() on a variable";
}

{
    my $program = q:to/./;
        sub foo() {
            my lookup = "hygienic";
            return Q::Identifier { name: "lookup" };
        }

        my lookup = "unhygienic";
        my identifier = foo();
        say(melt(identifier));
        .

    outputs
        $program,
        qq[unhygienic\n],
        "melted identifier lookup is unhygienic";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "n"))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "type") (arglist (identifier "n")))))))
        .

    is-result $ast, "<type None>\n", "none type() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "n") (int 7))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "type") (arglist (identifier "n")))))))
        .

    is-result $ast, "<type Int>\n", "int type() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "s") (str "Bond"))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "type") (arglist (identifier "s")))))))
        .

    is-result $ast, "<type Str>\n", "str type() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (my (identifier "a") (array (int 1) (int 2)))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "type") (arglist (identifier "a")))))))
        .

    is-result $ast, "<type Array>\n", "array type() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (sub (identifier "f") (block (parameterlist) (stmtlist)))
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "type") (arglist (identifier "f")))))))
        .

    is-result $ast, "<type Sub>\n", "sub type() works";
}

{
    my $ast = q:to/./;
        (stmtlist
          (stexpr (postfix:<()> (identifier "say") (arglist (postfix:<()> (identifier "type") (arglist (identifier "say")))))))
        .

    is-result $ast, "<type Sub>\n", "builtin sub type() returns the same as ordinary sub";
}

done-testing;
