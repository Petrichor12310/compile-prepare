// Executable upstream MLIR 14 example, independent of Ascend dialects.
// Inputs A[i]=i and B[i]=1, so C contains 1..16 and checksum is 136.
module {
  func private @putint(i32)
  func private @putch(i32)
  func @main() -> i32 {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c16 = arith.constant 16 : index
    %zero = arith.constant 0 : i32
    %one = arith.constant 1 : i32
    %newline = arith.constant 10 : i32
    %space = arith.constant 32 : i32
    %a = memref.alloc() : memref<16xi32>
    %b = memref.alloc() : memref<16xi32>
    %c = memref.alloc() : memref<16xi32>
    scf.for %i = %c0 to %c16 step %c1 {
      %value = arith.index_cast %i : index to i32
      memref.store %value, %a[%i] : memref<16xi32>
      memref.store %one, %b[%i] : memref<16xi32>
    }
    scf.for %i = %c0 to %c16 step %c1 {
      %av = memref.load %a[%i] : memref<16xi32>
      %bv = memref.load %b[%i] : memref<16xi32>
      %added = arith.addi %av, %bv : i32
      memref.store %added, %c[%i] : memref<16xi32>
    }
    %total = scf.for %i = %c0 to %c16 step %c1 iter_args(%sum = %zero) -> (i32) {
      %value = memref.load %c[%i] : memref<16xi32>
      call @putint(%value) : (i32) -> ()
      call @putch(%space) : (i32) -> ()
      %next = arith.addi %sum, %value : i32
      scf.yield %next : i32
    }
    call @putch(%newline) : (i32) -> ()
    call @putint(%total) : (i32) -> ()
    call @putch(%newline) : (i32) -> ()
    memref.dealloc %a : memref<16xi32>
    memref.dealloc %b : memref<16xi32>
    memref.dealloc %c : memref<16xi32>
    return %zero : i32
  }
}
