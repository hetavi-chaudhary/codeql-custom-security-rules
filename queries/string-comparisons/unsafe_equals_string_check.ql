/**
 * @id unsafe-string-equals-check
 * @name Unsafe Equals usage
 * @kind problem
 * @problem.severity warning
 */

import csharp

from BinaryOperation comparison
where
  comparison.getOperator() = "==" and
  comparison.getLeftOperand().getType().getName() = "String" and
  comparison.getRightOperand().getType().getName() = "String" and
  not exists(MethodCall call |
    call.getTarget().getName().matches("ToUpper|ToLower") and
    (call.getQualifier() = comparison.getLeftOperand() or
     call.getQualifier() = comparison.getRightOperand())
  )
select comparison, "String comparison without ToUpper or ToLower."