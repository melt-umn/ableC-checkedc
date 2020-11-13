grammar edu:umn:cs:melt:exts:ableC:checkedc:abstractsyntax;

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

  local fwrd::Expr =
  ableC_Expr {
  ((unsigned int)$Expr{e1}) == ((unsigned int)$Expr{e2})
  };

  forwards to mkErrorCheck(localErrors, fwrd);
}


function verifyCheckedPtrType
[Message] ::= sub::Type t::Type op::String loc::Location
{
  return
    if typeAssignableTo(extType(nilQualifier(), checkedPtrType(sub)), t)
    then []
    else [err(loc, s"Operand to ${op} expected ptr<${showType(sub)}> (got ${showType(t)})")];
}

abstract production assignCheckedPtr
top::Expr ::= lhs::Expr rhs::Expr
{
  top.pp = pp"${lhs.pp} = ${rhs.pp}";

  local pSubType::Type = ptrSubType(rhs.typerep);
  local ptrSubTypeName::TypeName = typeName(directTypeExpr(pSubType), baseTypeExpr());
  local subType::Type = checkedPtrSubType(lhs.typerep);

  local q::Qualifiers = checkedPtrQualifiers(lhs.typerep);
  local regPointerType::Type = pointerType(q,pSubType);
  -- local checkedPointerType::ExtType = checkedPtrType(subType);
  -- local typeExpr::Expr = checkedPtrTypeExpr(foldQualifier(rhs.typerep.qualifiers),
  --                                                   ptrSubTypeName,
  --                                                   top.location);
  local castExpr::Expr = explicitCastExpr(
                         typeName(checkedPtrTypeExpr(foldQualifier(rhs.typerep.qualifiers),
                                                     ptrSubTypeName,
                                                     top.location),
                                  baseTypeExpr()),
                         rhs,
                         location=builtin);
  -- local typeExpr::Expr = BaseTypeExpr(directTypeExpr(regPointerType));


  local localErrors::[Message] =
     lhs.errors ++ rhs.errors;
     -- verifyCheckedPtrType(subType, pSubType, "assign", top.location);



  local fwrd::Expr =
    ableC_Expr {
      ($Expr{lhs} host::= $Expr{castExpr}
      )

    };


  forwards to mkErrorCheck(localErrors, fwrd);
}


abstract production initCheckedPtr
top::Initializer ::= e::Expr
{

  local subType::Type = ptrSubType(e.typerep);
  local subTypeName::TypeName = typeName(directTypeExpr(subType), baseTypeExpr());
  forwards to exprInitializer(
                explicitCastExpr(
                        typeName(checkedPtrTypeExpr(foldQualifier(e.typerep.qualifiers),
                                                    subTypeName,
                                                    top.location),
                                 baseTypeExpr()),
                        e,
                        location=builtin),
                        location=builtin);
}


-- abstract production addrOfCheckedPtr
-- top::Expr ::= e::Expr
-- {
--   top.pp = pp"&${e.pp}";

--   local subType::Type = checkedPtrSubType(e1.typerep);

--   local localErrors::[Message] =
--      e1.errors ++ e2.errors;
--      -- checkVectorHeaderDef("copy_vector", top.location, top.env) ++
--      -- checkVectorType(subType, e1.typerep, "concat", top.location) ++
--      -- checkVectorType(subType, e2.typerep, "concat", top.location);

--   local fwrd::Expr = addExpr(e1, e2, location=builtin);

--   forwards to mkErrorCheck(localErrors, fwrd);
-- }

abstract production dereferenceCheckedPtr
top::Expr ::= e::Expr
{
  top.pp = parens( cat(text("*"), e.pp) );

  local subType::Type = checkedPtrSubType(e.typerep);
  local q::Qualifiers = checkedPtrQualifiers(e.typerep);
  local regPointerType::Type = pointerType(q,subType);

  -- top.typerep =
  --   case e.typerep.defaultFunctionArrayLvalueConversion of
  --   | checkedPtrType( innerty) -> innerty
  --   | _ -> errorType()
  --   end;
  -- top.isLValue = true;

  local localErrors::[Message] = e.errors;
     -- checkVectorHeaderDef("copy_vector", top.location, top.env) ++
     -- checkVectorType(subType, e1.typerep, "concat", top.location) ++
     -- checkVectorType(subType, e2.typerep, "concat", top.location);

  -- local fwrd::Expr = ovrld:dereferenceExpr(e.host,location=builtin);
  -- local fwrd::Expr = ovrld:dereferenceExpr(e.host,location=builtin);

        -- ($directTypeExpr{extType(nilQualifier(), closureType(params.typereps, res.typerep))})_result;

  local fwrd::Expr =
    ableC_Expr {
        ({if ($Expr{e} == 0){
        printf("Dereferencing null checked pointer is not allowed.\n");
        exit(1);
        }; ({ *(($directTypeExpr{regPointerType})$Expr{e});});})
    };

  forwards to mkErrorCheck(localErrors, fwrd);

}

function ptrSubType
Type ::= t::Type
{
  return
    case t of
      pointerType(_, sub) -> sub
    | _ -> errorType()
    end;
}

-- Find the sub-type of a checked ptr type
function checkedPtrSubType
Type ::= t::Type
{
  return
    case t of
      extType(_, checkedPtrType(sub)) -> sub
    | _ -> errorType()
    end;
}

-- Find the qualifiers of a checked ptr type
function checkedPtrQualifiers
Qualifiers ::= t::Type
{
  return
    case t of
      extType(q, checkedPtrType(_)) -> q
    | _ -> nilQualifier()
    end;
}
