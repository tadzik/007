use v6;
use Test;
use _007::Test;

{
    my $program = q:to/./;
        sub infix:<*>(left, right) {
        }
        .

    my $ast = q:to/./;
        (statements
          (sub (ident "infix:<*>") (parameters (ident "left") (ident "right")) (statements)))
        .

    parses-to $program, $ast, "custom operator parses to the right thing";
}

{
    my $program = q:to/./;
        sub infix:<*>(left, right) {
            return 20;
        }

        say(4 * 5);
        .

    outputs $program, "20\n", "using an operator after defining it works";
}

{
    my $program = q:to/./;
        say(4 * 5);
        .

    parse-error $program, X::AdHoc, "infix:<*> should not be defined unless we define it";
}

{
    my $program = q:to/./;
        {
            sub infix:<*>(left, right) {
                return 7;
            }
        }
        say(4 * 5);
        .

    parse-error $program, X::AdHoc, "infix:<*> should not be usable outside of its scope";
}

{
    my $program = q:to/./;
        sub infix:<+>(left, right) {
            return 14;
        }

        say(1 + 4);
        .

    outputs $program, "14\n", "can override a built-in operator";
}

{
    my $program = q:to/./;
        sub infix:<~~>(left, right) {
            return "wrong";
        }

        sub infix:<~~~>(left, right) {
            return "right";
        }

        say(4 ~~~ 5);
        .

    outputs $program, "right\n", "longest token wins, not first";
}

{
    my $program = q:to/./;
        sub infix:<***>(left, right) {
            return "right";
        }

        sub infix:<**>(left, right) {
            return "wrong";
        }

        say(4 *** 5);
        .

    outputs $program, "right\n", "longest token wins, not last";
}

{
    my $program = q:to/./;
        sub infix:<!>(left, right) {
            say(left ~ " " ~ right);
        }

        BEGIN { "OH" ! "HAI" }
        .

    outputs $program, "OH HAI\n", "defined operators work from within BEGIN blocks";
}

{
    my $program = q:to/./;
        sub infix:<*!>(left, right) {
            return 10;
        }

        say(1 + 5 *! 5);
        .

    outputs $program, "11\n", "new operators bind maximally tightly";
}

{
    my $program = q:to/./;
        sub infix:<~?>(left, right) is looser(infix:<+>) {
            return 6;
        }

        say(1 + 9 ~? 12);
        .

    outputs $program, "6\n", "can specify trait to bind loose";
}

{
    my $program = q:to/./;
        sub infix:<~?>(left, right) is tighter(infix:<+>) {
            return 6;
        }

        say(1 + 9 ~? 12);
        .

    outputs $program, "7\n", "can specify trait to bind tight";
}

{
    my $program = q:to/./;
        sub infix:<*>(left, right) {
            return 18;
        }

        sub infix:<~@>(left, right) is tighter(infix:<+>) {
            return 30;
        }

        say(1 ~@ 2 * 9);
        .

    outputs $program, "30\n", "the new op is tighter than +, but not *";
}

{
    my $program = q:to/./;
        sub infix:<!?!>(left, right) is tighter(infix:<+>) is looser(infix:<+>) {
        }
        .

    parse-error $program, X::Trait::Conflict, "can't have both tighter and looser traits";
}

{
    my $program = q:to/./;
        sub infix:<@>(left, right) {
            return "@";
        }

        sub infix:<!>(left, right) is equal(infix:<@>) {
            return "!";
        }

        say(10 @ 2 ! 3);
        say(30 ! 2 @ 14);
        .

    outputs $program, "!\n@\n", "can specify trait to bind equal";
}

{
    my $program = q:to/./;
        sub infix:<!?!>(left, right) is tighter(infix:<+>) is equal(infix:<+>) {
        }
        .

    parse-error $program, X::Trait::Conflict, "can't have both tighter and equal traits";
}

{
    my $program = q:to/./;
        sub infix:<!++>(left, right) is looser(infix:<+>) is equal(infix:<+>) {
        }
        .

    parse-error $program, X::Trait::Conflict, "can't have both looser and equal traits";
}

{
    my $program = q:to/./;
        sub infix:<@>(left, right) is assoc("right") {
            return "(" ~ left ~ ", " ~ right ~ ")";
        }

        say("A" @ "B" @ "C");
        .

    outputs $program, "(A, (B, C))\n", "associativity means we can control the shape of the expr tree";
}

{
    my $program = q:to/./;
        sub infix:<%>(left, right) is assoc("left") {
            return "(" ~ left ~ ", " ~ right ~ ")";
        }

        say("A" % "B" % "C");
        .

    outputs $program, "((A, B), C)\n", "left associativity can be specified";
}

{
    my $program = q:to/./;
        sub infix:</>(left, right) {
            return "(" ~ left ~ ", " ~ right ~ ")";
        }

        say("x" / "y" / "z");
        .

    outputs $program, "((x, y), z)\n", "left associativity is the default";
}

{
    my $program = q:to/./;
        sub infix:<!>(left, right) is assoc("non") {
            return "oh, James";
        }

        say(0 ! 7);
        .

    outputs $program, "oh, James\n", "can define an operator to be non-associative";
}

{
    my $program = q:to/./;
        sub infix:<!>(left, right) is assoc("non") {
            return "oh, James";
        }

        say(0 ! 0 ! 7);
        .

    parse-error $program, X::Op::Nonassociative, "a non-associative operator can't associate";
}

{
    my $program = q:to/./;
        sub infix:<&-&>(left, right) is assoc("salamander") {
        }
        .

    parse-error $program, X::Trait::IllegalValue, "you can't just put any old value in an assoc trait";
}

# also test that re-affirming the associativity of an "is equal" declaration is fine

# also test for error on contradicting the associativity of an "is equal" declaration

# also test for declaring a prefix op

# also test for declaring a postfix op

# also test for tighter/looser/equal prefix/postfix ops

# also test for associativity with prefix/postfix ops (a prefix and a postfix can tie on prec; "left" prefers the prefix and "right" the postfix)

done;
