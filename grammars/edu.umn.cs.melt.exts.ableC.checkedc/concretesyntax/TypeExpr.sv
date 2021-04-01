grammar edu:umn:cs:melt:exts:ableC:checkedc:concretesyntax;

imports edu:umn:cs:melt:ableC:concretesyntax;
imports silver:langutil only ast;

imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
--imports edu:umn:cs:melt:ableC:abstractsyntax:debug;

imports edu:umn:cs:melt:exts:ableC:checkedc:abstractsyntax;



marking terminal Checked_ptr_t 'ptr' lexer classes {Type, Global};

concrete productions top::TypeSpecifier_c
| 'ptr' '<' sub::TypeName_c '>'
{
  top.realTypeSpecifiers = [checkedPtrTypeExpr(top.givenQualifiers, sub.ast, top.location)];
  top.preTypeSpecifiers = [];
}
marking terminal Checked_array_t 'checked' lexer classes {Type, Global};
terminal Checked_array_dim_t 'offff' lexer classes {Type, Global};


concrete productions top::PostfixModifier_c
| 'checked'
{
    top.declaredParamIdents = nothing();
    top.ast = checkedArrayTypeExprModifier(top.givenType, top.location);
}

