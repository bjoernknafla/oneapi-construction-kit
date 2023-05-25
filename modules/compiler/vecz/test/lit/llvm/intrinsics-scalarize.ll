; Copyright (C) Codeplay Software Limited
;
; Licensed under the Apache License, Version 2.0 (the "License") with LLVM
; Exceptions; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     https://github.com/codeplaysoftware/oneapi-construction-kit/blob/main/LICENSE.txt
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
; WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
; License for the specific language governing permissions and limitations
; under the License.
;
; SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

; RUN: veczc -k ctpop -vecz-simd-width=2 -vecz-choices=FullScalarization -S < %s | FileCheck %s --check-prefix CTPOP
; RUN: veczc -k ctlz -vecz-simd-width=4 -vecz-choices=FullScalarization -S < %s | FileCheck %s --check-prefix CTLZ
; RUN: veczc -k cttz -vecz-simd-width=8 -vecz-choices=FullScalarization -S < %s | FileCheck %s --check-prefix CTTZ
; RUN: veczc -k sadd_sat -vecz-simd-width=2 -vecz-choices=FullScalarization -S < %s | FileCheck %s --check-prefix SADD_SAT
; RUN: veczc -k uadd_sat -vecz-simd-width=2 -vecz-choices=FullScalarization -S < %s | FileCheck %s --check-prefix UADD_SAT
; RUN: veczc -k ssub_sat -vecz-simd-width=2 -vecz-choices=FullScalarization -S < %s | FileCheck %s --check-prefix SSUB_SAT
; RUN: veczc -k usub_sat -vecz-simd-width=2 -vecz-choices=FullScalarization -S < %s | FileCheck %s --check-prefix USUB_SAT

target triple = "spir64-unknown-unknown"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

; It checks that the scalar intrinsics get vectorized,
; and the vector intrinsics get scalarized and then re-vectorized.

define spir_kernel void @ctpop(i32* %aptr, <2 x i8>* %bptr, i32* %yptr, <2 x i8>* %zptr) {
entry:
  %idx = call spir_func i64 @_Z13get_global_idj(i32 0)
  %arrayidxa = getelementptr inbounds i32, i32* %aptr, i64 %idx
  %arrayidxb = getelementptr inbounds <2 x i8>, <2 x i8>* %bptr, i64 %idx
  %arrayidxy = getelementptr inbounds i32, i32* %yptr, i64 %idx
  %arrayidxz = getelementptr inbounds <2 x i8>, <2 x i8>* %zptr, i64 %idx
  %a = load i32, i32* %arrayidxa, align 4
  %b = load <2 x i8>, <2 x i8>* %arrayidxb, align 2
  %ctpopi32 = call i32 @llvm.ctpop.i32(i32 %a)
  %ctpopv2i8 = call <2 x i8> @llvm.ctpop.v2i8(<2 x i8> %b)
  store i32 %ctpopi32, i32* %arrayidxy, align 4
  store <2 x i8> %ctpopv2i8, <2 x i8>* %arrayidxz, align 2
  ret void
}

define spir_kernel void @ctlz(i32* %aptr, <2 x i8>* %bptr, i32* %yptr, <2 x i8>* %zptr) {
entry:
  %idx = call spir_func i64 @_Z13get_global_idj(i32 0)
  %arrayidxa = getelementptr inbounds i32, i32* %aptr, i64 %idx
  %arrayidxb = getelementptr inbounds <2 x i8>, <2 x i8>* %bptr, i64 %idx
  %arrayidxy = getelementptr inbounds i32, i32* %yptr, i64 %idx
  %arrayidxz = getelementptr inbounds <2 x i8>, <2 x i8>* %zptr, i64 %idx
  %a = load i32, i32* %arrayidxa, align 4
  %b = load <2 x i8>, <2 x i8>* %arrayidxb, align 2
  %ctlzi32 = call i32 @llvm.ctlz.i32(i32 %a, i1 false)
  %ctlzv2i8 = call <2 x i8> @llvm.ctlz.v2i8(<2 x i8> %b, i1 false)
  store i32 %ctlzi32, i32* %arrayidxy, align 4
  store <2 x i8> %ctlzv2i8, <2 x i8>* %arrayidxz, align 2
  ret void
}

define spir_kernel void @cttz(i32* %aptr, <2 x i8>* %bptr, i32* %yptr, <2 x i8>* %zptr) {
entry:
  %idx = call spir_func i64 @_Z13get_global_idj(i32 0)
  %arrayidxa = getelementptr inbounds i32, i32* %aptr, i64 %idx
  %arrayidxb = getelementptr inbounds <2 x i8>, <2 x i8>* %bptr, i64 %idx
  %arrayidxy = getelementptr inbounds i32, i32* %yptr, i64 %idx
  %arrayidxz = getelementptr inbounds <2 x i8>, <2 x i8>* %zptr, i64 %idx
  %a = load i32, i32* %arrayidxa, align 4
  %b = load <2 x i8>, <2 x i8>* %arrayidxb, align 2
  %cttzi32 = call i32 @llvm.cttz.i32(i32 %a, i1 false)
  %cttzv2i8 = call <2 x i8> @llvm.cttz.v2i8(<2 x i8> %b, i1 false)
  store i32 %cttzi32, i32* %arrayidxy, align 4
  store <2 x i8> %cttzv2i8, <2 x i8>* %arrayidxz, align 2
  ret void
}

define spir_kernel void @sadd_sat(i32* %aptr, <2 x i8>* %bptr, i32* %yptr, <2 x i8>* %zptr) {
entry:
  %idx = call spir_func i64 @_Z13get_global_idj(i32 0)
  %arrayidxa = getelementptr inbounds i32, i32* %aptr, i64 %idx
  %arrayidxy = getelementptr inbounds i32, i32* %yptr, i64 %idx
  %a = load i32, i32* %arrayidxa, align 4
  %y = load i32, i32* %arrayidxy, align 4
  %v_i32 = call i32 @llvm.sadd.sat.i32(i32 %a, i32 %y)
  %arrayidxb = getelementptr inbounds <2 x i8>, <2 x i8>* %bptr, i64 %idx
  %arrayidxz = getelementptr inbounds <2 x i8>, <2 x i8>* %zptr, i64 %idx
  %b = load <2 x i8>, <2 x i8>* %arrayidxb, align 2
  %z = load <2 x i8>, <2 x i8>* %arrayidxz, align 2
  %v_v2i8 = call <2 x i8> @llvm.sadd.sat.v2i8(<2 x i8> %b, <2 x i8> %z)
  store i32 %v_i32, i32* %arrayidxy, align 4
  store <2 x i8> %v_v2i8, <2 x i8>* %arrayidxz, align 2
  ret void
}

define spir_kernel void @uadd_sat(i32* %aptr, <2 x i8>* %bptr, i32* %yptr, <2 x i8>* %zptr) {
entry:
  %idx = call spir_func i64 @_Z13get_global_idj(i32 0)
  %arrayidxa = getelementptr inbounds i32, i32* %aptr, i64 %idx
  %arrayidxy = getelementptr inbounds i32, i32* %yptr, i64 %idx
  %a = load i32, i32* %arrayidxa, align 4
  %y = load i32, i32* %arrayidxy, align 4
  %v_i32 = call i32 @llvm.uadd.sat.i32(i32 %a, i32 %y)
  %arrayidxb = getelementptr inbounds <2 x i8>, <2 x i8>* %bptr, i64 %idx
  %arrayidxz = getelementptr inbounds <2 x i8>, <2 x i8>* %zptr, i64 %idx
  %b = load <2 x i8>, <2 x i8>* %arrayidxb, align 2
  %z = load <2 x i8>, <2 x i8>* %arrayidxz, align 2
  %v_v2i8 = call <2 x i8> @llvm.uadd.sat.v2i8(<2 x i8> %b, <2 x i8> %z)
  store i32 %v_i32, i32* %arrayidxy, align 4
  store <2 x i8> %v_v2i8, <2 x i8>* %arrayidxz, align 2
  ret void
}

define spir_kernel void @ssub_sat(i32* %aptr, <2 x i8>* %bptr, i32* %yptr, <2 x i8>* %zptr) {
entry:
  %idx = call spir_func i64 @_Z13get_global_idj(i32 0)
  %arrayidxa = getelementptr inbounds i32, i32* %aptr, i64 %idx
  %arrayidxy = getelementptr inbounds i32, i32* %yptr, i64 %idx
  %a = load i32, i32* %arrayidxa, align 4
  %y = load i32, i32* %arrayidxy, align 4
  %v_i32 = call i32 @llvm.ssub.sat.i32(i32 %a, i32 %y)
  %arrayidxb = getelementptr inbounds <2 x i8>, <2 x i8>* %bptr, i64 %idx
  %arrayidxz = getelementptr inbounds <2 x i8>, <2 x i8>* %zptr, i64 %idx
  %b = load <2 x i8>, <2 x i8>* %arrayidxb, align 2
  %z = load <2 x i8>, <2 x i8>* %arrayidxz, align 2
  %v_v2i8 = call <2 x i8> @llvm.ssub.sat.v2i8(<2 x i8> %b, <2 x i8> %z)
  store i32 %v_i32, i32* %arrayidxy, align 4
  store <2 x i8> %v_v2i8, <2 x i8>* %arrayidxz, align 2
  ret void
}

define spir_kernel void @usub_sat(i32* %aptr, <2 x i8>* %bptr, i32* %yptr, <2 x i8>* %zptr) {
entry:
  %idx = call spir_func i64 @_Z13get_global_idj(i32 0)
  %arrayidxa = getelementptr inbounds i32, i32* %aptr, i64 %idx
  %arrayidxy = getelementptr inbounds i32, i32* %yptr, i64 %idx
  %a = load i32, i32* %arrayidxa, align 4
  %y = load i32, i32* %arrayidxy, align 4
  %v_i32 = call i32 @llvm.usub.sat.i32(i32 %a, i32 %y)
  %arrayidxb = getelementptr inbounds <2 x i8>, <2 x i8>* %bptr, i64 %idx
  %arrayidxz = getelementptr inbounds <2 x i8>, <2 x i8>* %zptr, i64 %idx
  %b = load <2 x i8>, <2 x i8>* %arrayidxb, align 2
  %z = load <2 x i8>, <2 x i8>* %arrayidxz, align 2
  %v_v2i8 = call <2 x i8> @llvm.usub.sat.v2i8(<2 x i8> %b, <2 x i8> %z)
  store i32 %v_i32, i32* %arrayidxy, align 4
  store <2 x i8> %v_v2i8, <2 x i8>* %arrayidxz, align 2
  ret void
}

declare i32 @llvm.ctpop.i32(i32)
declare <2 x i8> @llvm.ctpop.v2i8(<2 x i8>)

declare i32 @llvm.ctlz.i32(i32, i1)
declare <2 x i8> @llvm.ctlz.v2i8(<2 x i8>, i1)

declare i32 @llvm.cttz.i32(i32, i1)
declare <2 x i8> @llvm.cttz.v2i8(<2 x i8>, i1)

declare i32 @llvm.sadd.sat.i32(i32, i32)
declare <2 x i8> @llvm.sadd.sat.v2i8(<2 x i8>, <2 x i8>)

declare i32 @llvm.uadd.sat.i32(i32, i32)
declare <2 x i8> @llvm.uadd.sat.v2i8(<2 x i8>, <2 x i8>)

declare i32 @llvm.ssub.sat.i32(i32, i32)
declare <2 x i8> @llvm.ssub.sat.v2i8(<2 x i8>, <2 x i8>)

declare i32 @llvm.usub.sat.i32(i32, i32)
declare <2 x i8> @llvm.usub.sat.v2i8(<2 x i8>, <2 x i8>)

declare spir_func i64 @_Z13get_global_idj(i32)

; CTPOP: void @__vecz_v2_ctpop
; CTPOP: = call <2 x i32> @llvm.ctpop.v2i32(<2 x i32> %{{.*}})
; CTPOP: = call <2 x i8> @llvm.ctpop.v2i8(<2 x i8> %{{.*}})
; CTPOP: = call <2 x i8> @llvm.ctpop.v2i8(<2 x i8> %{{.*}})

; CTLZ: void @__vecz_v4_ctlz
; CTLZ: = call <4 x i32> @llvm.ctlz.v4i32(<4 x i32> %{{.*}}, i1 false)
; CTLZ: = call <4 x i8> @llvm.ctlz.v4i8(<4 x i8> %{{.*}}, i1 false)
; CTLZ: = call <4 x i8> @llvm.ctlz.v4i8(<4 x i8> %{{.*}}, i1 false)

; CTTZ: void @__vecz_v8_cttz
; CTTZ: = call <8 x i32> @llvm.cttz.v8i32(<8 x i32> %{{.*}}, i1 false)
; CTTZ: = call <8 x i8> @llvm.cttz.v8i8(<8 x i8> %{{.*}}, i1 false)
; CTTZ: = call <8 x i8> @llvm.cttz.v8i8(<8 x i8> %{{.*}}, i1 false)

; SADD_SAT: void @__vecz_v2_sadd_sat
; SADD_SAT: = call <2 x i32> @llvm.sadd.sat.v2i32(
; SADD_SAT: = call <2 x i8> @llvm.sadd.sat.v2i8(
; SADD_SAT: = call <2 x i8> @llvm.sadd.sat.v2i8(

; UADD_SAT: void @__vecz_v2_uadd_sat
; UADD_SAT: = call <2 x i32> @llvm.uadd.sat.v2i32(
; UADD_SAT: = call <2 x i8> @llvm.uadd.sat.v2i8(
; UADD_SAT: = call <2 x i8> @llvm.uadd.sat.v2i8(

; SSUB_SAT: void @__vecz_v2_ssub_sat
; SSUB_SAT: = call <2 x i32> @llvm.ssub.sat.v2i32(
; SSUB_SAT: = call <2 x i8> @llvm.ssub.sat.v2i8(
; SSUB_SAT: = call <2 x i8> @llvm.ssub.sat.v2i8(

; USUB_SAT: void @__vecz_v2_usub_sat
; USUB_SAT: = call <2 x i32> @llvm.usub.sat.v2i32(
; USUB_SAT: = call <2 x i8> @llvm.usub.sat.v2i8(
; USUB_SAT: = call <2 x i8> @llvm.usub.sat.v2i8(
