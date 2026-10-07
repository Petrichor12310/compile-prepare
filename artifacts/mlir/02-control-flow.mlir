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
    br ^bb1(%c0 : index)
  ^bb1(%3: index):  // 2 preds: ^bb0, ^bb2
    %4 = arith.cmpi slt, %3, %c16 : index
    cond_br %4, ^bb2, ^bb3
  ^bb2:  // pred: ^bb1
    %5 = arith.index_cast %3 : index to i32
    memref.store %5, %0[%3] : memref<16xi32>
    memref.store %c1_i32, %1[%3] : memref<16xi32>
    %6 = arith.addi %3, %c1 : index
    br ^bb1(%6 : index)
  ^bb3:  // pred: ^bb1
    br ^bb4(%c0 : index)
  ^bb4(%7: index):  // 2 preds: ^bb3, ^bb5
    %8 = arith.cmpi slt, %7, %c16 : index
    cond_br %8, ^bb5, ^bb6
  ^bb5:  // pred: ^bb4
    %9 = memref.load %0[%7] : memref<16xi32>
    %10 = memref.load %1[%7] : memref<16xi32>
    %11 = arith.addi %9, %10 : i32
    memref.store %11, %2[%7] : memref<16xi32>
    %12 = arith.addi %7, %c1 : index
    br ^bb4(%12 : index)
  ^bb6:  // pred: ^bb4
    br ^bb7(%c0, %c0_i32 : index, i32)
  ^bb7(%13: index, %14: i32):  // 2 preds: ^bb6, ^bb8
    %15 = arith.cmpi slt, %13, %c16 : index
    cond_br %15, ^bb8, ^bb9
  ^bb8:  // pred: ^bb7
    %16 = memref.load %2[%13] : memref<16xi32>
    call @putint(%16) : (i32) -> ()
    call @putch(%c32_i32) : (i32) -> ()
    %17 = arith.addi %14, %16 : i32
    %18 = arith.addi %13, %c1 : index
    br ^bb7(%18, %17 : index, i32)
  ^bb9:  // pred: ^bb7
    call @putch(%c10_i32) : (i32) -> ()
    call @putint(%14) : (i32) -> ()
    call @putch(%c10_i32) : (i32) -> ()
    memref.dealloc %0 : memref<16xi32>
    memref.dealloc %1 : memref<16xi32>
    memref.dealloc %2 : memref<16xi32>
    return %c0_i32 : i32
  }
}

