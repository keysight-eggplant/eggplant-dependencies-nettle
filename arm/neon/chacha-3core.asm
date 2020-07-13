C arm/neon/chacha-3core.asm

ifelse(<
   Copyright (C) 2020 Niels Möller

   This file is part of GNU Nettle.

   GNU Nettle is free software: you can redistribute it and/or
   modify it under the terms of either:

     * the GNU Lesser General Public License as published by the Free
       Software Foundation; either version 3 of the License, or (at your
       option) any later version.

   or

     * the GNU General Public License as published by the Free
       Software Foundation; either version 2 of the License, or (at your
       option) any later version.

   or both in parallel, as here.

   GNU Nettle is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received copies of the GNU General Public License and
   the GNU Lesser General Public License along with this program.  If
   not, see http://www.gnu.org/licenses/.
>)

	.file "chacha-3core.asm"
	.fpu	neon

define(<DST>, <r0>)
define(<SRC>, <r1>)
define(<ROUNDS>, <r2>)

C State, X, Y and Z representing consecutive blocks
define(<X0>, <q0>)
define(<X1>, <q1>)
define(<X2>, <q2>)
define(<X3>, <q3>)
define(<Y0>, <q8>)
define(<Y1>, <q9>)
define(<Y2>, <q10>)
define(<Y3>, <q11>)
define(<Z0>, <q12>)
define(<Z1>, <q13>)
define(<Z2>, <q14>)
define(<Z3>, <q15>)

define(<T0>, <q4>)
define(<T1>, <q5>)
define(<T2>, <q6>)
define(<T3>, <q7>)

	.text
	.align 4
.Lcount1:
	.int 1,0,0,0

	C _chacha_3core(uint32_t *dst, const uint32_t *src, unsigned rounds)

PROLOGUE(_nettle_chacha_3core)
	vldm	SRC, {X0,X1,X2,X3}
	vpush	{q4,q5,q6,q7}
	adr	r12, .Lcount1
	vld1.64 {Z3}, [r12]

	vadd.i64	Y3, X3, Z3	C Increment 64-bit counter
	vadd.i64	Z3, Y3, Z3

.Lshared_entry:
	vmov	Y0, X0
	vmov	Z0, X0
	vmov	Y1, X1
	vmov	Z1, X1
	vmov	Y2, X2
	vmov	Z2, X2
	vpush	{Z3}
	vpush	{Y3}

.Loop:
	C Interleave three blocks. Note that with this scheduling,
	C only two temporaries, T0 and T1, are needed.
	vadd.i32	X0, X0, X1
	veor		X3, X3, X0
	vrev32.16	X3, X3		C lrot 16
	 vadd.i32	Y0, Y0, Y1
	vadd.i32	X2, X2, X3
	 veor		Y3, Y3, Y0
	veor		T0, X1, X2
	 vrev32.16	Y3, Y3		C lrot 16
	  vadd.i32	Z0, Z0, Z1
	vshl.i32	X1, T0, #12
	 vadd.i32	Y2, Y2, Y3
	  veor		Z3, Z3, Z0
	vsri.u32	X1, T0, #20
	 veor		T0, Y1, Y2
	  vrev32.16	Z3, Z3		C lrot 16
	vadd.i32	X0, X0, X1
	 vshl.i32	Y1, T0, #12
	  vadd.i32	Z2, Z2, Z3
	veor		T1, X3, X0
	 vsri.u32	Y1, T0, #20
	  veor		T0, Z1, Z2
	vshl.i32	X3, T1, #8
	vsri.u32	X3, T1, #24
	 vadd.i32	Y0, Y0, Y1
	  vshl.i32	Z1, T0, #12
	vadd.i32	X2, X2, X3
	 veor		T1, Y3, Y0
	  vsri.u32	Z1, T0, #20
	veor		T0, X1, X2
	 vshl.i32	Y3, T1, #8
	 vsri.u32	Y3, T1, #24
	  vadd.i32	Z0, Z0, Z1
	vshl.i32	X1, T0, #7
	 vadd.i32	Y2, Y2, Y3
	  veor		T1, Z3, Z0
	vsri.u32	X1, T0, #25
	 veor		T0, Y1, Y2
	  vshl.i32	Z3, T1, #8
	  vsri.u32	Z3, T1, #24
	 vshl.i32	Y1, T0, #7
	  vadd.i32	Z2, Z2, Z3
	 vsri.u32	Y1, T0, #25
	  veor		T0, Z1, Z2
	  vshl.i32	Z1, T0, #7
	  vsri.u32	Z1, T0, #25

	vext.32	X1, X1, X1, #1
	vext.32	X2, X2, X2, #2
	vext.32	X3, X3, X3, #3

	vext.32	Y1, Y1, Y1, #1
	vext.32	Y2, Y2, Y2, #2
	vext.32	Y3, Y3, Y3, #3

	vext.32	Z1, Z1, Z1, #1
	vext.32	Z2, Z2, Z2, #2
	vext.32	Z3, Z3, Z3, #3

	vadd.i32	X0, X0, X1
	veor		X3, X3, X0
	vrev32.16	X3, X3		C lrot 16
	 vadd.i32	Y0, Y0, Y1
	vadd.i32	X2, X2, X3
	 veor		Y3, Y3, Y0
	veor		T0, X1, X2
	 vrev32.16	Y3, Y3		C lrot 16
	  vadd.i32	Z0, Z0, Z1
	vshl.i32	X1, T0, #12
	 vadd.i32	Y2, Y2, Y3
	  veor		Z3, Z3, Z0
	vsri.u32	X1, T0, #20
	 veor		T0, Y1, Y2
	  vrev32.16	Z3, Z3		C lrot 16
	vadd.i32	X0, X0, X1
	 vshl.i32	Y1, T0, #12
	  vadd.i32	Z2, Z2, Z3
	veor		T1, X3, X0
	 vsri.u32	Y1, T0, #20
	  veor		T0, Z1, Z2
	vshl.i32	X3, T1, #8
	vsri.u32	X3, T1, #24
	 vadd.i32	Y0, Y0, Y1
	  vshl.i32	Z1, T0, #12
	vadd.i32	X2, X2, X3
	 veor		T1, Y3, Y0
	  vsri.u32	Z1, T0, #20
	veor		T0, X1, X2
	 vshl.i32	Y3, T1, #8
	 vsri.u32	Y3, T1, #24
	  vadd.i32	Z0, Z0, Z1
	vshl.i32	X1, T0, #7
	 vadd.i32	Y2, Y2, Y3
	  veor		T1, Z3, Z0
	vsri.u32	X1, T0, #25
	 veor		T0, Y1, Y2
	  vshl.i32	Z3, T1, #8
	  vsri.u32	Z3, T1, #24
	 vshl.i32	Y1, T0, #7
	  vadd.i32	Z2, Z2, Z3
	 vsri.u32	Y1, T0, #25
	  veor		T0, Z1, Z2
	  vshl.i32	Z1, T0, #7
	  vsri.u32	Z1, T0, #25

	subs	ROUNDS, ROUNDS, #2

	vext.32	X1, X1, X1, #3
	vext.32	X2, X2, X2, #2
	vext.32	X3, X3, X3, #1

	vext.32	Y1, Y1, Y1, #3
	vext.32	Y2, Y2, Y2, #2
	vext.32	Y3, Y3, Y3, #1

	vext.32	Z1, Z1, Z1, #3
	vext.32	Z2, Z2, Z2, #2
	vext.32	Z3, Z3, Z3, #1

	bhi	.Loop

	vldm	SRC, {T0,T1,T2,T3}
	vadd.i32	X0, X0, T0
	vadd.i32	Y0, Y0, T0
	vadd.i32	Z0, Z0, T0
	vadd.i32	X1, X1, T1
	vadd.i32	Y1, Y1, T1
	vadd.i32	Z1, Z1, T1
	vadd.i32	X2, X2, T2
	vadd.i32	Y2, Y2, T2
	vadd.i32	Z2, Z2, T2

	vpop	{T0, T1}	C updated counters
	vadd.i32	X3, X3, T3
	vadd.i32	Y3, Y3, T0
	vadd.i32	Z3, Z3, T1

	vpop	{q4,q5,q6,q7}

	vstmia	DST!, {X0,X1,X2,X3}
	vstmia	DST!, {Y0,Y1,Y2,Y3}
	vstm	DST, {Z0,Z1,Z2,Z3}
	bx	lr
EPILOGUE(_nettle_chacha_3core)

PROLOGUE(_nettle_chacha_3core32)
	vldm	SRC, {X0,X1,X2,X3}
	vpush	{q4,q5,q6,q7}
	adr	r12, .Lcount1
	vld1.64 {Z3}, [r12]
	vadd.i32	Z3, Y3, Y3

	vadd.i32	Y3, X3, Z3	C Increment 32-bit counter
	vadd.i32	Z3, Y3, Z3
	b .Lshared_entry
EPILOGUE(_nettle_chacha_3core32)
