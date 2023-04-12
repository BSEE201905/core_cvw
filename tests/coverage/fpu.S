///////////////////////////////////////////
// fpu.S
//
// Written: David_Harris@hmc.edu 28 March 2023
//
// Purpose: Test coverage for FPU
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// 
// Copyright (C) 2021-23 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file 
// except in compliance with the License, or, at your option, the Apache License version 2.0. You 
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the 
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

// load code to initalize stack, handle interrupts, terminate
#include "WALLY-init-lib.h"

main:

    #bseti t0, zero, 14  # turn on FPU
    csrs mstatus, t0

    # Test legal instructions not covered elsewhere
    flq ft0, 0(a0)
    flh ft0, 8(a0)
    fsq ft0, 0(a0)
    fsh ft0, 8(a0)

    # Tests for fpu/fctrl.sv
    fcvt.h.s ft1, ft0
    fcvt.q.s ft2, ft0
    fcvt.h.w ft3, a0
    fcvt.h.wu ft3, a0
    fcvt.h.l ft3, a0
    fcvt.h.lu ft3, a0
    fcvt.w.h a0, ft3
    fcvt.wu.h a0, ft3
    fcvt.l.h a0, ft3
    fcvt.lu.h a0, ft3
    fcvt.q.w ft3, a0
    fcvt.q.wu ft3, a0
    fcvt.q.l ft3, a0
    fcvt.q.lu ft3, a0
    fcvt.w.q a0, ft3
    fcvt.wu.q a0, ft3
    fcvt.l.q a0, ft3
    fcvt.lu.q a0, ft3


    // Tests verfying that half and quad floating point convertion instructions are not supported by rv64gc
    # fcvt.h.d ft3, ft0 // Somehow this instruction is taking the route on line 124
                      // idea: enable the Q extension for this to work properly? A: Q and halfs not supported in rv64gc
    # fcvt.h.w ft3, a0
    # fcvt.w.h a0, ft0
    # fcvt.q.w ft3, a0
    # fcvt.w.q a0, ft0
    # fcvt.q.d ft3, ft0

    # Completing branch coverage in fctrl.sv
    .word 0x38007553    // Testing the all False case for 119 - funct7 under, op = 101 0011
    .word 0x40000053    // Line 145 All False Test case - illegal instruction?
    .word 0xd0400053    // Line 156 All False Test case - illegal instruction?
    .word 0xc0400053    // Line 162 All False Test case - illegal instruction?
    .word 0xd2400053    // Line 168 All False Test case - illegal instruction?
    .word 0xc2400053    // Line 174 All False Test case - illegal instruction?

    # Increasing conditional coverage in fctrl.sv
    .word 0xc5000007    // Attempting to toggle (Op7 != 7) to 0 on line 97 in fctrl, not sure what instruction this works out to
    .word 0xe0101053    // toggling (Rs2D == 0) to 0 on line 139 in fctrl. Illegal Intsr (like fclass but incorrect rs2)
    .word 0xe0100053    // toggling (Rs2D == 0) to 0 on line 141 in fctrl. Illegal Intsr (like fmv but incorrect rs2)
    .word 0x40500053    // toggling (Rs2D[4:2] == 0) to 0 on line 145 in fctrl. 
    .word 0x40300053    // toggling SupportFmt2 to 0 on line 145 in fctrl.
    .word 0x42100053    // toggling (Rs2D[1:0] != 1) to 0 on line 147 in fctrl. Illegal Instr
    .word 0xf0100053    // toggling (Rs2D == 0) to 0 on line 143 in fctrl. Illegal Instr

    # Test illegal instructions are detected
    .word 0x00000007 // illegal floating-point load (bad Funct3)
    .word 0x00000027 // illegal floating-point store (bad Funct3)
    .word 0x58F00053 // illegal fsqrt (bad Rs2D)
    .word 0x20007053 // illegal fsgnj (bad Funct3)
    .word 0x28007053 // illegal fmin/max (bad Funct3)
    .word 0xA0007053 // illegal fcmp (bad Funct3)
    .word 0xE0007053 // illegal fclass/fmv (bad Funct3)
    .word 0xF0007053 // illegal fmv (bad Funct3)
    .word 0x43007053 // illegal fcvt.d.* (bad Rs2D)
    .word 0x42207053 // illegal fcvt.d.* (bad Rs2D[1])

    j done
