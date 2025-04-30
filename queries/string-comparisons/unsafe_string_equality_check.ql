/**
 * @id unsafe-string-equality-check
 * @name Unsafe Equality usage
 * @kind problem
 * @problem.severity warning
 */

import csharp

predicate isToUpperOrLower(string name) {
  name = "ToUpper" or name = "ToLower"
}

/**
 * Recursively checks if any part of the expression contains ToUpper/ToLower.
 */
predicate containsToUpperOrLower(Expr e) {
  exists(MethodCall mc |
    mc = e and isToUpperOrLower(mc.getTarget().getName())
  ) or
  exists(MethodCall mc |
    e = mc.getQualifier() and containsToUpperOrLower(mc)
  ) or
  exists(PropertyAccess pa |
    e = pa.getQualifier() and containsToUpperOrLower(pa)
  ) or
  exists(ElementAccess ea |
    e = ea.getQualifier() and containsToUpperOrLower(ea)
  )
}

/**
 * Whether a method call uses StringComparison as second argument.
 */
predicate usesStringComparison(MethodCall call) {
  call.getNumberOfArguments() >= 2 and
  call.getArgument(1).getType().hasName("StringComparison")
}

/**
 * Basic string type check
 */
predicate isString(Expr e) {
  e.getType().hasName("String")
}

from MethodCall call, Expr qualifier, Expr arg0
where
  call.getTarget().getName().matches("Equals") and
  qualifier = call.getQualifier() and
  arg0 = call.getArgument(0) and

  isString(qualifier) and isString(arg0) and

  // Only flag if both sides are NOT normalized
  not (containsToUpperOrLower(qualifier) and containsToUpperOrLower(arg0)) and

  // And doesn't use StringComparison
  not usesStringComparison(call)

select call, "Potential case-sensitive string comparison. Use StringComparison or normalize both sides with ToUpper/ToLower."