grammar edu:umn:cs:melt:exts:ableC:checkedc:abstractsyntax;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:overloadable hiding exprInitializer, eqExpr;
imports edu:umn:cs:melt:ableC:abstractsyntax:overloadable as ovrld;
--imports edu:umn:cs:melt:ableC:abstractsyntax:debug;

imports edu:umn:cs:melt:exts:ableC:templating;
imports edu:umn:cs:melt:exts:ableC:string;
imports edu:umn:cs:melt:exts:ableC:constructor;




abstract production checkedPtrTypeExpr
top::BaseTypeExpr ::= q::Qualifiers sub::TypeName loc::Location
{
  top.pp = pp"${terminate(space(), q.pps)}checkedptr<${sub.pp}>";

  top.inferredArgs := sub.inferredArgs;
  sub.argumentType =
    case top.argumentType of
    | extType(_, checkedPtrType(t)) -> t
    | _ -> errorType()
    end;

  sub.env = globalEnv(top.env);

  local localErrors::[Message] =
    sub.errors;

  forwards to
    if !null(localErrors)
    then errorTypeExpr(localErrors)
    else extTypeExpr(q, checkedPtrType(sub.typerep));
}





abstract production checkedPtrType
top::ExtType ::= sub::Type
{
  propagate canonicalType;
  top.pp = pp"checkedPtr<${sub.lpp}${sub.rpp}>";
  top.mangledName = s"checkedPtr_${sub.mangledName}_";
  top.host = pointerType(top.givenQualifiers,sub);
  top.isEqualTo =
    \ other::ExtType ->
      case other of
        | checkedPtrType(otherSub) -> compatibleTypes(sub, otherSub, false, false)
        | _ -> false
      end;


   top.lEqProd = just(assignCheckedPtr(_, _, location=_));
   top.lAddProd = just(addCheckedPtr(_, _, location=_));
   top.rAddProd = just(addCheckedPtr(_, _, location=_));
  -- Overload for += automatically inferred from above
   --top.lEqualsProd = just(equalsCheckedPtr(_, _, location=_));
   --top.rEqualsProd = just(equalsCheckedPtr(_, _, location=_));
   top.exprInitProd = just(initCheckedPtr(_, location=_));
   -- top.dereferenceProd = just(ovrld:pointerType.dereferenceProd(_, location=_));
   top.dereferenceProd = just(dereferenceCheckedPtr(_, location=_));
   -- top.dereferenceProd = top.host.dereferenceProd;
  -- top.addressOfProd = just(addrOfCheckedPtr(_,location=_));
  -- Overload for != automatically inferred from above
  -- top.addressOfArraySubscriptProd = just(addressOfSubscriptVector(_, _, location=_));
  -- Overloads for [], []= automatically inferred from above
  -- top.callMemberProd = just(callMemberVector(_, _, _, _, location=_));
  -- top.memberProd = just(memberVector(_, _, _, location=_));

  -- top.showErrors =
  --   \ l::Location env::Decorated Env ->
  --     sub.showErrors(l, env) ++
  --     checkVectorHeaderDef("show_vector", l, env);
  -- top.showProd =
  --   \ e::Expr -> ableC_Expr { inst show_vector<$directTypeExpr{sub}>($Expr{e}) };


}


-- abstract production arrayTypeExprWithExpr
-- top::TypeModifierExpr ::= element::TypeModifierExpr  indexQualifiers::Qualifiers  sizeModifier::ArraySizeModifier  size::Expr


-- int b[10][10]
-- =>
-- arrayType(
--     arrayType(
--         builtinType(nilQualifier(), signedType(intType())),
--         nilQualifier(),
--         normalArraySize(),
--         constantArrayType(10)
--     ),
--     nilQualifier(),
--     normalArraySize(),
--     constantArrayType(10))

abstract production checkedArrayType
top::ExtType ::= sub::Type
{
  propagate canonicalType;
  -- propagate errors, globalDecls, functionDecls, defs, decls, freeVariables;
  top.pp = pp"checkedArray<${sub.lpp}${sub.rpp}>";
  top.mangledName = s"checkedArray_${sub.mangledName}_";
  top.host = sub;
  top.isEqualTo =
    \ other::ExtType ->
      case other of
        | checkedArrayType(otherSub) -> compatibleTypes(sub, otherSub, false, false)
        | _ -> false
      end;

  top.baseTypeExpr = sub.baseTypeExpr;

  --  top.lEqProd = just(assignCheckedPtr(_, _, location=_));
  --  top.lAddProd = just(addCheckedPtr(_, _, location=_));
  --  top.rAddProd = just(addCheckedPtr(_, _, location=_));
  -- -- Overload for += automatically inferred from above
  --  --top.lEqualsProd = just(equalsCheckedPtr(_, _, location=_));
  --  --top.rEqualsProd = just(equalsCheckedPtr(_, _, location=_));
  --  top.exprInitProd = just(initCheckedPtr(_, location=_));
  --  -- top.dereferenceProd = just(ovrld:pointerType.dereferenceProd(_, location=_));
  --  top.dereferenceProd = just(dereferenceCheckedPtr(_, location=_));
   -- top.dereferenceProd = top.host.dereferenceProd;
  -- top.addressOfProd = just(addrOfCheckedPtr(_,location=_));
  -- Overload for != automatically inferred from above
  -- top.addressOfArraySubscriptProd = just(addressOfSubscriptVector(_, _, location=_));
  -- Overloads for [], []= automatically inferred from above
  -- top.callMemberProd = just(callMemberVector(_, _, _, _, location=_));
  -- top.memberProd = just(memberVector(_, _, _, location=_));

  -- top.showErrors =
  --   \ l::Location env::Decorated Env ->
  --     sub.showErrors(l, env) ++
  --     checkVectorHeaderDef("show_vector", l, env);
  -- top.showProd =
  --   \ e::Expr -> ableC_Expr { inst show_vector<$directTypeExpr{sub}>($Expr{e}) };


}

abstract production checkedArrayTypeExprBase
top::BaseTypeExpr ::= sub::TypeModifierExpr loc::Location
{
  -- top.pp = pp"${terminate(space(), q.pps)}checkedarray<${sub.pp}>";
  -- top.lpp = pp"checked_array${sub.lpp} ${terminate(space(), q.pps)}";
  -- top.rpp = sub.rpp;

  top.inferredArgs := sub.inferredArgs;
  sub.argumentType =
    case top.argumentType of
    | extType(_, checkedArrayType(t)) -> t
    | _ -> errorType()
    end;

  sub.env = globalEnv(top.env);

  local localErrors::[Message] =
    sub.errors;
    -- Spot to add error checking for errors we can detect on construction

  forwards to
    if !null(localErrors)
    then errorTypeExpr(localErrors)
    else extTypeExpr(nilQualifier(), checkedArrayType(sub.typerep));
}

abstract production checkedArrayTypeExprModifier
top::TypeModifierExpr ::= sub::TypeModifierExpr loc::Location
{

  top.lpp = pp"${sub.lpp}";
  top.rpp = sub.rpp;
  -- top.pp = pp"checked_array<${arrayType.pp}>";
  -- top.mangledName = s"checkedArray_${arrayType.mangledName}_";
  forwards to modifiedTypeExpr(checkedArrayTypeExprBase(sub,loc));
    -- if !null(localErrors)
    -- then errorTypeExpr(localErrors)
    -- else extTypeExpr(q, checkedArrayType(q,element, indexQualifiers, sizeModifier, size, loc));
}


-- abstract production checkedArrayType
-- top::ExtType ::= q::Qualifiers element::TypeModifierExpr indexQualifiers::Qualifiers sizeModifier::ArraySizeModifier size::Expr loc::Location
-- {
--   propagate canonicalType;
--   -- top.pp = pp"checkedArray_<${sub.lpp}${sub.rpp}>";
--   -- top.mangledName = s"checkedArray_${sub.mangledName}_";
--   top.host = arrayTypeExprWithExpr(top.givenType, nilQualifier(), normalArraySize(), e.ast);
-- }
