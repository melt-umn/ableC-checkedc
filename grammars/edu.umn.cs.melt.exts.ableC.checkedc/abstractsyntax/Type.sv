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
    sub.errors; -- ++ checkVectorHeaderDef("_vector_s", loc, top.env)

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

