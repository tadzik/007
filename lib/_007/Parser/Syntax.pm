use _007::Val;
use _007::Q;
use _007::Parser::Exceptions;

grammar _007::Parser::Syntax {
    token TOP { <compunit> }

    token compunit {
        <.newpad>
        <statementlist>
        <.finishpad>
    }

    token newpad { <?> {
        $*parser.push-oplevel;
        @*declstack.push(@*declstack ?? @*declstack[*-1].clone !! {});
        my $block = Val::Block.new(
            :parameterlist(Q::ParameterList.new),
            :statementlist(Q::StatementList.new),
            :outer-frame($*runtime.current-frame));
        $*runtime.enter($block)
    } }

    token finishpad { <?> {
        @*declstack.pop;
        $*parser.pop-oplevel;
    } }

    rule statementlist {
        '' [<statement><.eat_terminator> ]*
    }

    method panic($what) {
        die X::Syntax::Missing.new(:$what);
    }

    our sub declare(Q::Declaration $decltype, $symbol) {
        die X::Redeclaration.new(:$symbol)
            if $*runtime.declared-locally($symbol);
        my $frame = $*runtime.current-frame();
        die X::Redeclaration::Outer.new(:$symbol)
            if %*assigned{$frame ~ $symbol};
        my $identifier = Q::Identifier.new(
            :name(Val::Str.new(:value($symbol))),
            :$frame);
        $*runtime.declare-var($identifier);
        @*declstack[*-1]{$symbol} = $decltype;
    }

    proto token statement {*}
    rule statement:my {
        my [<identifier> || <.panic("identifier")>]
        { declare(Q::Statement::My, $<identifier>.Str); }
        ['=' <EXPR>]?
    }
    rule statement:constant {
        constant <identifier>
        {
            my $symbol = $<identifier>.Str;
            # XXX: a suspicious lack of redeclaration checks here
            declare(Q::Statement::Constant, $symbol);
        }
        ['=' <EXPR>]?
    }
    token statement:expr {
        <![{]>       # }], you're welcome vim
        <EXPR>
    }
    token statement:block { <pblock> }
    rule statement:sub-or-macro {
        $<routine>=(sub|macro) [<identifier> || <.panic("identifier")>]
        :my $*insub = True;
        {
            declare($<routine> eq "sub"
                        ?? Q::Statement::Sub
                        !! Q::Statement::Macro,
                    $<identifier>.Str);
        }
        <.newpad>
        '(' ~ ')' <parameterlist>
        <traitlist>
        <blockoid>:!s
        <.finishpad>
    }
    token statement:return {
        return [<.ws> <EXPR>]?
        {
            die X::ControlFlow::Return.new
                unless $*insub;
        }
    }
    token statement:if {
        if <.ws> <xblock>
        [  <.ws> else <.ws>
            [
                | <else=block>
                | <else=statement:if>
            ]
        ] ?
    }

    token statement:for {
        for <.ws> <xblock>
    }
    token statement:while {
        while <.ws> <xblock>
    }
    token statement:BEGIN {
        BEGIN <.ws> <block>
    }

    rule traitlist {
        <trait> *
    }
    token trait {
        'is' <.ws> <identifier> '(' <EXPR> ')'
    }

    # requires a <.newpad> before invocation
    # and a <.finishpad> after
    token blockoid {
        '{' ~ '}' <statementlist>
    }
    token block {
        <?[{]> <.newpad> <blockoid> <.finishpad>    # }], vim
    }

    # "pointy block"
    token pblock {
        | <lambda> <.newpad> <.ws>
            <parameterlist>
            <blockoid>
            <.finishpad>
        | <block>
    }
    token lambda { '->' }

    # "eXpr block"
    token xblock {
        <EXPR> <pblock>
    }

    token eat_terminator {
        || <.ws> ';'
        || <?after '}'> $$
        || <.ws> <?before '}'>
        || <.ws> $
    }

    rule EXPR { <termish> +% [<infix> | <infix=infix-unquote>] }

    token termish { [<prefix> | <prefix=prefix-unquote>]* [<term>|<term=unquote>] <postfix>* }

    method prefix {
        my @ops = $*parser.oplevel.ops<prefix>.keys;
        if /@ops/(self) -> $cur {
            return $cur."!reduce"("prefix");
        }
        return /<!>/(self);
    }

    token str { '"' ([<-["]> | '\\\\' | '\\"']*) '"' }

    proto token term {*}
    token term:none { None >> <!before <.ws> '{'> }
    token term:int { \d+ }
    token term:array { '[' ~ ']' [<.ws> <EXPR>]* %% [\h* ','] }
    token term:str { <str> }
    token term:parens { '(' ~ ')' <EXPR> }
    token term:quasi { quasi <.ws>
        [
            || "@" <.ws> "Q::Infix" <.ws> '{' <.ws> <infix> <.ws> '}'
            || "@" <.ws> "Q::Prefix" <.ws> '{' <.ws> <prefix> <.ws> '}'
            || "@" <.ws> "Q::Postfix" <.ws> '{' <.ws> <postfix> <.ws> '}'
            || "@" <.ws> "Q::Expr" <.ws> '{' <.ws> <EXPR> <.ws> '}'
            || "@" <.ws> "Q::Identifier" <.ws> '{' <.ws> <term:identifier> <.ws> '}'
            || "@" <.ws> "Q::Block" <.ws> '{' <.ws> <block> <.ws> '}'
            || "@" <.ws> "Q::CompUnit" <.ws> '{' <.ws> <compunit> <.ws> '}'
            || "@" <.ws> "Q::Literal" <.ws> '{' <.ws> [<term:int> | <term:none> | <term:str>] <.ws> '}'
            || "@" <.ws> "Q::Literal::Int" <.ws> '{' <.ws> <term:int> <.ws> '}'
            || "@" <.ws> "Q::Literal::None" <.ws> '{' <.ws> <term:none> <.ws> '}'
            || "@" <.ws> "Q::Literal::Str" <.ws> '{' <.ws> <term:str> <.ws> '}'
            || "@" <.ws> "Q::Property" <.ws> '{' <.ws> <property> <.ws> '}'
            || "@" <.ws> "Q::PropertyList" <.ws> '{' <.ws> <propertylist> <.ws> '}'
            || "@" <.ws> "Q::Term" <.ws> '{' <.ws> <term> <.ws> '}'
            || "@" <.ws> "Q::Term::Array" <.ws> '{' <.ws> <term:array> <.ws> '}'
            || "@" <.ws> "Q::Term::Object" <.ws> '{' <.ws> <term:object> <.ws> '}'
            || "@" <.ws> "Q::Term::Quasi" <.ws> '{' <.ws> <term:quasi> <.ws> '}'
            || "@" <.ws> "Q::Trait" <.ws> '{' <.ws> <trait> <.ws> '}'
            || "@" <.ws> "Q::TraitList" <.ws> '{' <.ws> <traitlist> <.ws> '}'
            || "@" <.ws> "Q::Statement" <.ws> '{' <.ws> <statement><.eat_terminator> <.ws> '}'
            || "@" <.ws> "Q::StatementList" <.ws> '{' <.ws> <statementlist> <.ws> '}'
            || "@" <.ws> "Q::Parameter" <.ws> '{' <.ws> <parameter> <.ws> '}'
            || "@" <.ws> "Q::ParameterList" <.ws> '{' <.ws> <parameterlist> <.ws> '}'
            || "@" <.ws> "Q::ArgumentList" <.ws> '{' <.ws> <argumentlist> <.ws> '}'
            || "@" <.ws> "Q::Unquote" <.ws> '{' <.ws> <unquote> <.ws> '}'
            || "@" <.ws> (\S+) { die "Unknown Q type $0" } # XXX: turn into X::
            || <block>
            || <.panic("quasi")>
        ]
    }
    token term:object {
        [<identifier> <?{ $*runtime.maybe-get-var(~$<identifier>) ~~ Val::Type }> <.ws>]?
        '{' ~ '}' <propertylist>
    }
    token term:identifier {
        <identifier>
        {
            my $name = $<identifier>.Str;
            if !$*runtime.declared($name) {
                my $frame = $*runtime.current-frame;
                $*parser.postpone: sub checking-postdeclared {
                    my $value = $*runtime.get-var($name, $frame);
                    die X::Macro::Postdeclared.new(:$name)
                        if $value ~~ Val::Macro;
                    die X::Undeclared.new(:symbol($name))
                        unless $value ~~ Val::Sub;
                };
            }
        }
    }
    token term:sub {
        sub <.ws> <identifier>?
        :my $*insub = True;
        <.newpad>
        {
            if $<identifier> {
                declare(Q::Term::Sub, $<identifier>.Str);
            }
        }
        '(' ~ ')' <parameterlist>
        <traitlist>
        <blockoid>:!s
        <.finishpad>
    }

    token propertylist { [<.ws> <property>]* %% [\h* ','] <.ws> }

    token unquote { '{{{' <EXPR> [:s "@" <identifier> ]? '}}}' }

    proto token property {*}
    rule property:str-expr { <key=str> ':' <value=term> }
    rule property:identifier-expr { <identifier> ':' <value=term> }
    rule property:method {
        <identifier>
        <.newpad>
        '(' ~ ')' <parameterlist>
        <trait> *
        <blockoid>:!s
        <.finishpad>
    }
    token property:identifier { <identifier> }

    method infix {
        my @ops = $*parser.oplevel.ops<infix>.keys;
        if /@ops/(self) -> $cur {
            return $cur."!reduce"("infix");
        }
        return /<!>/(self);
    }

    rule infix-unquote {
        <unquote>
    }

    rule prefix-unquote {
        <unquote> <?{ ($<unquote><identifier> // "") eq "Q::Prefix" }>
    }

    method postfix {
        # XXX: should find a way not to special-case [] and () and .
        if /$<index>=[ <.ws> '[' ~ ']' [<.ws> <EXPR>] ]/(self) -> $cur {
            return $cur."!reduce"("postfix");
        }
        elsif /$<call>=[ <.ws> '(' ~ ')' [<.ws> <argumentlist>] ]/(self) -> $cur {
            return $cur."!reduce"("postfix");
        }
        elsif /$<prop>=[ <.ws> '.' <identifier> ]/(self) -> $cur {
            return $cur."!reduce"("postfix");
        }

        my @ops = $*parser.oplevel.ops<postfix>.keys;
        if /@ops/(self) -> $cur {
            return $cur."!reduce"("postfix");
        }
        return /<!>/(self);
    }

    token identifier {
        <!before \d> [\w+]+ % '::'
            [ <?after \w> [':<' <-[>]>+ '>']?  || <.panic("identifier")> ]
    }

    rule argumentlist {
        <EXPR> *%% ','
    }

    rule parameterlist {
        [<parameter>
        { declare(Q::Parameter, $<parameter>[*-1]<identifier>.Str); }
        ]* %% ','
    }

    rule parameter {
        <identifier>
    }

    token ws {
        [ \s+ | '#' \N* ]*
    }
}
