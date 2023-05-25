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

; RUN: veczc -k noreduce2 -vecz-choices=PacketizeUniformInLoops -vecz-simd-width=4 -S < %s | FileCheck %s

; ModuleID = 'kernel.opencl'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "spir64-unknown-unknown"

declare spir_func i64 @_Z12get_local_idj(i32)
declare spir_func i64 @_Z13get_global_idj(i32)
declare spir_func i64 @_Z14get_local_sizej(i32)

; Function Attrs: nounwind
define spir_kernel void @noreduce2(i32 addrspace(3)* %in, i32 addrspace(3)* %out) {
entry:
  %call = call spir_func i64 @_Z12get_local_idj(i32 0)
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %storemerge = phi i32 [ 1, %entry ], [ %mul, %for.inc ]
  %conv = zext i32 %storemerge to i64
  %call1 = call spir_func i64 @_Z14get_local_sizej(i32 0)
  %cmp = icmp ult i64 %conv, %call1
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %0 = icmp eq i32 %storemerge, 8
  %1 = select i1 %0, i32 17, i32 %storemerge
  %rem = urem i32 37, %1
  %cmp3 = icmp eq i32 %rem, 0
  br i1 %cmp3, label %if.then, label %for.inc

if.then:                                          ; preds = %for.body
  %idxprom = zext i32 %storemerge to i64
  %arrayidx = getelementptr inbounds i32, i32 addrspace(3)* %out, i64 %idxprom
  store i32 5, i32 addrspace(3)* %arrayidx, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body, %if.then
  %mul = shl i32 %storemerge, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

; This test checks if the "packetize uniform in loops" Vecz choice works on
; uniform values used by varying values in loops, but not on uniform values used
; by other uniform values only.

; CHECK: define spir_kernel void @__vecz_v4_noreduce2(ptr addrspace(3) %in, ptr addrspace(3) %out)
; CHECK: icmp ugt i64
; CHECK: phi i32
; CHECK: icmp eq i32
; CHECK: urem i32 37
; CHECK: icmp eq i32
; CHECK: store i32 5
; CHECK: shl i32 %{{.+}}, 1
; CHECK: ret void
