module attributes {llvm.data_layout = ""} {
  llvm.func @free(!llvm.ptr<i8>)
  llvm.func @malloc(i64) -> !llvm.ptr<i8>
  llvm.func @putint(i32) attributes {sym_visibility = "private"}
  llvm.func @putch(i32) attributes {sym_visibility = "private"}
  llvm.func @main() -> i32 {
    %0 = llvm.mlir.constant(0 : index) : i64
    %1 = llvm.mlir.constant(1 : index) : i64
    %2 = llvm.mlir.constant(16 : index) : i64
    %3 = llvm.mlir.constant(0 : i32) : i32
    %4 = llvm.mlir.constant(1 : i32) : i32
    %5 = llvm.mlir.constant(10 : i32) : i32
    %6 = llvm.mlir.constant(32 : i32) : i32
    %7 = llvm.mlir.constant(16 : index) : i64
    %8 = llvm.mlir.constant(1 : index) : i64
    %9 = llvm.mlir.null : !llvm.ptr<i32>
    %10 = llvm.getelementptr %9[%7] : (!llvm.ptr<i32>, i64) -> !llvm.ptr<i32>
    %11 = llvm.ptrtoint %10 : !llvm.ptr<i32> to i64
    %12 = llvm.call @malloc(%11) : (i64) -> !llvm.ptr<i8>
    %13 = llvm.bitcast %12 : !llvm.ptr<i8> to !llvm.ptr<i32>
    %14 = llvm.mlir.undef : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %15 = llvm.insertvalue %13, %14[0] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %16 = llvm.insertvalue %13, %15[1] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.insertvalue %17, %16[2] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %19 = llvm.insertvalue %7, %18[3, 0] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %20 = llvm.insertvalue %8, %19[4, 0] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %21 = llvm.mlir.constant(16 : index) : i64
    %22 = llvm.mlir.constant(1 : index) : i64
    %23 = llvm.mlir.null : !llvm.ptr<i32>
    %24 = llvm.getelementptr %23[%21] : (!llvm.ptr<i32>, i64) -> !llvm.ptr<i32>
    %25 = llvm.ptrtoint %24 : !llvm.ptr<i32> to i64
    %26 = llvm.call @malloc(%25) : (i64) -> !llvm.ptr<i8>
    %27 = llvm.bitcast %26 : !llvm.ptr<i8> to !llvm.ptr<i32>
    %28 = llvm.mlir.undef : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %29 = llvm.insertvalue %27, %28[0] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %30 = llvm.insertvalue %27, %29[1] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %31 = llvm.mlir.constant(0 : index) : i64
    %32 = llvm.insertvalue %31, %30[2] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %33 = llvm.insertvalue %21, %32[3, 0] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %34 = llvm.insertvalue %22, %33[4, 0] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %35 = llvm.mlir.constant(16 : index) : i64
    %36 = llvm.mlir.constant(1 : index) : i64
    %37 = llvm.mlir.null : !llvm.ptr<i32>
    %38 = llvm.getelementptr %37[%35] : (!llvm.ptr<i32>, i64) -> !llvm.ptr<i32>
    %39 = llvm.ptrtoint %38 : !llvm.ptr<i32> to i64
    %40 = llvm.call @malloc(%39) : (i64) -> !llvm.ptr<i8>
    %41 = llvm.bitcast %40 : !llvm.ptr<i8> to !llvm.ptr<i32>
    %42 = llvm.mlir.undef : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %43 = llvm.insertvalue %41, %42[0] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %44 = llvm.insertvalue %41, %43[1] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %45 = llvm.mlir.constant(0 : index) : i64
    %46 = llvm.insertvalue %45, %44[2] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %47 = llvm.insertvalue %35, %46[3, 0] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    %48 = llvm.insertvalue %36, %47[4, 0] : !llvm.struct<(ptr<i32>, ptr<i32>, i64, array<1 x i64>, array<1 x i64>)>
    llvm.br ^bb1(%0 : i64)
  ^bb1(%49: i64):  // 2 preds: ^bb0, ^bb2
    %50 = llvm.icmp "slt" %49, %2 : i64
    llvm.cond_br %50, ^bb2, ^bb3
  ^bb2:  // pred: ^bb1
    %51 = llvm.trunc %49 : i64 to i32
    %52 = llvm.getelementptr %13[%49] : (!llvm.ptr<i32>, i64) -> !llvm.ptr<i32>
    llvm.store %51, %52 : !llvm.ptr<i32>
    %53 = llvm.getelementptr %27[%49] : (!llvm.ptr<i32>, i64) -> !llvm.ptr<i32>
    llvm.store %4, %53 : !llvm.ptr<i32>
    %54 = llvm.add %49, %1  : i64
    llvm.br ^bb1(%54 : i64)
  ^bb3:  // pred: ^bb1
    llvm.br ^bb4(%0 : i64)
  ^bb4(%55: i64):  // 2 preds: ^bb3, ^bb5
    %56 = llvm.icmp "slt" %55, %2 : i64
    llvm.cond_br %56, ^bb5, ^bb6
  ^bb5:  // pred: ^bb4
    %57 = llvm.getelementptr %13[%55] : (!llvm.ptr<i32>, i64) -> !llvm.ptr<i32>
    %58 = llvm.load %57 : !llvm.ptr<i32>
    %59 = llvm.getelementptr %27[%55] : (!llvm.ptr<i32>, i64) -> !llvm.ptr<i32>
    %60 = llvm.load %59 : !llvm.ptr<i32>
    %61 = llvm.add %58, %60  : i32
    %62 = llvm.getelementptr %41[%55] : (!llvm.ptr<i32>, i64) -> !llvm.ptr<i32>
    llvm.store %61, %62 : !llvm.ptr<i32>
    %63 = llvm.add %55, %1  : i64
    llvm.br ^bb4(%63 : i64)
  ^bb6:  // pred: ^bb4
    llvm.br ^bb7(%0, %3 : i64, i32)
  ^bb7(%64: i64, %65: i32):  // 2 preds: ^bb6, ^bb8
    %66 = llvm.icmp "slt" %64, %2 : i64
    llvm.cond_br %66, ^bb8, ^bb9
  ^bb8:  // pred: ^bb7
    %67 = llvm.getelementptr %41[%64] : (!llvm.ptr<i32>, i64) -> !llvm.ptr<i32>
    %68 = llvm.load %67 : !llvm.ptr<i32>
    llvm.call @putint(%68) : (i32) -> ()
    llvm.call @putch(%6) : (i32) -> ()
    %69 = llvm.add %65, %68  : i32
    %70 = llvm.add %64, %1  : i64
    llvm.br ^bb7(%70, %69 : i64, i32)
  ^bb9:  // pred: ^bb7
    llvm.call @putch(%5) : (i32) -> ()
    llvm.call @putint(%65) : (i32) -> ()
    llvm.call @putch(%5) : (i32) -> ()
    %71 = llvm.bitcast %13 : !llvm.ptr<i32> to !llvm.ptr<i8>
    llvm.call @free(%71) : (!llvm.ptr<i8>) -> ()
    %72 = llvm.bitcast %27 : !llvm.ptr<i32> to !llvm.ptr<i8>
    llvm.call @free(%72) : (!llvm.ptr<i8>) -> ()
    %73 = llvm.bitcast %41 : !llvm.ptr<i32> to !llvm.ptr<i8>
    llvm.call @free(%73) : (!llvm.ptr<i8>) -> ()
    llvm.return %3 : i32
  }
}

