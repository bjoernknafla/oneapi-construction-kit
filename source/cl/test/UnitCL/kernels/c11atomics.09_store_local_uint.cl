// Copyright (C) Codeplay Software Limited. All Rights Reserved.
// CL_STD: 3.0
__kernel void store_local_uint(__global uint *input_buffer,
                          __global uint *output_buffer,
                          volatile __local atomic_uint *local_buffer) {
  uint gid = get_global_id(0);
  uint lid = get_local_id(0);

  atomic_store_explicit(local_buffer + lid, input_buffer[gid],
                        memory_order_relaxed, memory_scope_work_item);
  output_buffer[gid] = atomic_load_explicit(
      local_buffer + lid, memory_order_relaxed, memory_scope_work_item);
}