class-pool .
*"* class pool for class ZBP_I_PYM_DDL_PAY_CUS_UPDATE

*"* local type definitions
include ZBP_I_PYM_DDL_PAY_CUS_UPDATE==ccdef.

*"* class ZBP_I_PYM_DDL_PAY_CUS_UPDATE definition
*"* public declarations
  include ZBP_I_PYM_DDL_PAY_CUS_UPDATE==cu.
*"* protected declarations
  include ZBP_I_PYM_DDL_PAY_CUS_UPDATE==co.
*"* private declarations
  include ZBP_I_PYM_DDL_PAY_CUS_UPDATE==ci.
endclass. "ZBP_I_PYM_DDL_PAY_CUS_UPDATE definition

*"* macro definitions
include ZBP_I_PYM_DDL_PAY_CUS_UPDATE==ccmac.
*"* local class implementation
include ZBP_I_PYM_DDL_PAY_CUS_UPDATE==ccimp.

*"* test class
include ZBP_I_PYM_DDL_PAY_CUS_UPDATE==ccau.

class ZBP_I_PYM_DDL_PAY_CUS_UPDATE implementation.
*"* method's implementations
  include methods.
endclass. "ZBP_I_PYM_DDL_PAY_CUS_UPDATE implementation
