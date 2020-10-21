grammar edu:umn:cs:melt:exts:ableC:checkedc:abstractsyntax;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:ableC:abstractsyntax:host hiding checkedPtrType;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:overloadable;
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
    sub.errors; -- ++ checkVectorHeaderDef("_vector_s", loc, top.env)

  forwards to
    if !null(localErrors)
    then errorTypeExpr(localErrors)
    else extTypeExpr(q, checkedPtrType(sub.typerep));
}

abstract production addCheckedPtr
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.pp} + ${e2.pp}";


  local localErrors::[Message] =
     e1.errors ++ e2.errors ++
     [err(e1.location, s"Arithmetic on Checked pointer not allowed.")];

  local fwrd::Expr = errorExpr(localErrors, location=builtin);

  forwards to mkErrorCheck(localErrors, fwrd);
}


abstract production equalsCheckedPtr
top::Expr ::= e1::Expr e2::Expr
{
  top.pp = pp"${e1.pp} + ${e2.pp}";

  local subType::Type = checkedPtrSubType(e1.typerep);

  local localErrors::[Message] =
     e1.errors ++ e2.errors;
     -- checkVectorHeaderDef("copy_vector", top.location, top.env) ++
     -- checkVectorType(subType, e1.typerep, "concat", top.location) ++
     -- checkVectorType(subType, e2.typerep, "concat", top.location);

  local fwrd::Expr = addExpr(e1, e2, location=builtin);

  forwards to mkErrorCheck(localErrors, fwrd);
}


abstract production assignCheckedPtr
top::Expr ::= lhs::Expr rhs::Expr
{
  top.pp = pp"${lhs.pp} = ${rhs.pp}";

  local subType::Type = checkedPtrSubType(lhs.typerep);

  local localErrors::[Message] =
     lhs.errors ++ rhs.errors;

  -- local fwrd::Expr = eqExpr(lhs, pointerExpr(rhs, location=builtin)
  --                              ,location=builtin);

  -- local fwrd::Expr = ableC_Expr {$Expr{lhs} = $Expr{rhs};};

  local fwrd::Expr = eqExpr(lhs, decExpr(rhs, location=builtin), location=builtin);


  forwards to mkErrorCheck(localErrors, fwrd);
}


abstract production initCheckedPtr
top::Initializer ::= e::Expr
{
  forwards to exprInitializer(decExpr(e, location=builtin), location=top.location);
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
  -- TODO: Figure out what these mean
   top.lAddProd = just(addCheckedPtr(_, _, location=_));
   top.rAddProd = just(addCheckedPtr(_, _, location=_));
  -- Overload for += automatically inferred from above
   top.lEqualsProd = just(equalsCheckedPtr(_, _, location=_));
   top.rEqualsProd = just(equalsCheckedPtr(_, _, location=_));
   top.exprInitProd = just(initCheckedPtr(_, location=_));
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

-- abstract production vectorType
-- top::ExtType ::= sub::Type
-- {
--   propagate canonicalType;
--   top.pp = pp"vector<${sub.lpp}${sub.rpp}>";
--   top.host = pointerType(top.givenQualifiers,sub);
--   top.mangledName = s"vector_${sub.mangledName}_";
--   top.isEqualTo =
--     \ other::ExtType ->
--       case other of
--         vectorType(otherSub) -> compatibleTypes(sub, otherSub, false, false)
--       | _ -> false
--       end;

--   -- TODO: Figure out what these mean
--   -- top.newProd = just(newVector(sub, _, location=_));
--   -- top.deleteProd = just(deleteVector(_));
--   top.lAddProd = just(concatVector(_, _, location=_));
--   top.rAddProd = just(concatVector(_, _, location=_));
--   -- Overload for += automatically inferred from above
--   top.lEqualsProd = just(equalsVector(_, _, location=_));
--   top.rEqualsProd = just(equalsVector(_, _, location=_));
--   -- Overload for != automatically inferred from above
--   top.addressOfArraySubscriptProd = just(addressOfSubscriptVector(_, _, location=_));
--   -- Overloads for [], []= automatically inferred from above
--   top.callMemberProd = just(callMemberVector(_, _, _, _, location=_));
--   top.memberProd = just(memberVector(_, _, _, location=_));

--   -- top.showErrors =
--   --   \ l::Location env::Decorated Env ->
--   --     sub.showErrors(l, env) ++
--   --     checkVectorHeaderDef("show_vector", l, env);
--   -- top.showProd =
--   --   \ e::Expr -> ableC_Expr { inst show_vector<$directTypeExpr{sub}>($Expr{e}) };
-- }

-- Find the sub-type of a vector type
function checkedPtrSubType
Type ::= t::Type
{
  return
    case t of
      extType(_, checkedPtrType(sub)) -> sub
    | _ -> errorType()
    end;
}
