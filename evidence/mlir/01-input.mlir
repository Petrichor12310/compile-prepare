module {
  func private @putint(i32)
  func private @putch(i32)
  func @main() -> i32 {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c16 = arith.constant 16 : index
    %c0_i32 = arith.constant 0 : i32
    %c1_i32 = arith.constant 1 : i32
    %c10_i32 = arith.constant 10 : i32
    %c32_i32 = arith.constant 32 : i32
    %0 = memref.alloc() : memref<16xi32>
    %1 = memref.alloc() : memref<16xi32>
    %2 = memref.alloc() : memref<16xi32>
    scf.for %arg0 = %c0 to %c16 step %c1 {
      %4 = arith.index_cast %arg0 : index to i32
      memref.store %4, %0[%arg0] : memref<16xi32>
      memref.store %c1_i32, %1[%arg0] : memref<16xi32>
    }
    scf.for %arg0 = %c0 to %c16 step %c1 {
      %4 = memref.load %0[%arg0] : memref<16xi32>
      %5 = memref.load %1[%arg0] : memref<16xi32>
      %6 = arith.addi %4, %5 : i32
      memref.store %6, %2[%arg0] : memref<16xi32>
    }
    %3 = scf.for %arg0 = %c0 to %c16 step %c1 iter_args(%arg1 = %c0_i32) -> (i32) {
      %4 = memref.load %2[%arg0] : memref<16xi32>
      call @putint(%4) : (i32) -> ()
      call @putch(%c32_i32) : (i32) -> ()
      %5 = arith.addi %arg1, %4 : i32
      scf.yield %5 : i32
    }
    call @putch(%c10_i32) : (i32) -> ()
    call @putint(%3) : (i32) -> ()
    call @putch(%c10_i32) : (i32) -> ()
    memref.dealloc %0 : memref<16xi32>
    memref.dealloc %1 : memref<16xi32>
    memref.dealloc %2 : memref<16xi32>
    return %c0_i32 : i32
  }
}

