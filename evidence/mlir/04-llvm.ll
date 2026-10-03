; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare i8* @malloc(i64)

declare void @free(i8*)

declare void @putint(i32)

declare void @putch(i32)

define i32 @main() !dbg !3 {
  %1 = call i8* @malloc(i64 ptrtoint (i32* getelementptr (i32, i32* null, i64 16) to i64)), !dbg !7
  %2 = bitcast i8* %1 to i32*, !dbg !9
  %3 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } undef, i32* %2, 0, !dbg !10
  %4 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %3, i32* %2, 1, !dbg !11
  %5 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %4, i64 0, 2, !dbg !12
  %6 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %5, i64 16, 3, 0, !dbg !13
  %7 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %6, i64 1, 4, 0, !dbg !14
  %8 = call i8* @malloc(i64 ptrtoint (i32* getelementptr (i32, i32* null, i64 16) to i64)), !dbg !15
  %9 = bitcast i8* %8 to i32*, !dbg !16
  %10 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } undef, i32* %9, 0, !dbg !17
  %11 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %10, i32* %9, 1, !dbg !18
  %12 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %11, i64 0, 2, !dbg !19
  %13 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %12, i64 16, 3, 0, !dbg !20
  %14 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %13, i64 1, 4, 0, !dbg !21
  %15 = call i8* @malloc(i64 ptrtoint (i32* getelementptr (i32, i32* null, i64 16) to i64)), !dbg !22
  %16 = bitcast i8* %15 to i32*, !dbg !23
  %17 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } undef, i32* %16, 0, !dbg !24
  %18 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %17, i32* %16, 1, !dbg !25
  %19 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %18, i64 0, 2, !dbg !26
  %20 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %19, i64 16, 3, 0, !dbg !27
  %21 = insertvalue { i32*, i32*, i64, [1 x i64], [1 x i64] } %20, i64 1, 4, 0, !dbg !28
  br label %22, !dbg !29

22:                                               ; preds = %25, %0
  %23 = phi i64 [ %29, %25 ], [ 0, %0 ]
  %24 = icmp slt i64 %23, 16, !dbg !30
  br i1 %24, label %25, label %30, !dbg !31

25:                                               ; preds = %22
  %26 = trunc i64 %23 to i32, !dbg !32
  %27 = getelementptr i32, i32* %2, i64 %23, !dbg !33
  store i32 %26, i32* %27, align 4, !dbg !34
  %28 = getelementptr i32, i32* %9, i64 %23, !dbg !35
  store i32 1, i32* %28, align 4, !dbg !36
  %29 = add i64 %23, 1, !dbg !37
  br label %22, !dbg !38

30:                                               ; preds = %22
  br label %31, !dbg !39

31:                                               ; preds = %34, %30
  %32 = phi i64 [ %41, %34 ], [ 0, %30 ]
  %33 = icmp slt i64 %32, 16, !dbg !40
  br i1 %33, label %34, label %42, !dbg !41

34:                                               ; preds = %31
  %35 = getelementptr i32, i32* %2, i64 %32, !dbg !42
  %36 = load i32, i32* %35, align 4, !dbg !43
  %37 = getelementptr i32, i32* %9, i64 %32, !dbg !44
  %38 = load i32, i32* %37, align 4, !dbg !45
  %39 = add i32 %36, %38, !dbg !46
  %40 = getelementptr i32, i32* %16, i64 %32, !dbg !47
  store i32 %39, i32* %40, align 4, !dbg !48
  %41 = add i64 %32, 1, !dbg !49
  br label %31, !dbg !50

42:                                               ; preds = %31
  br label %43, !dbg !51

43:                                               ; preds = %47, %42
  %44 = phi i64 [ %51, %47 ], [ 0, %42 ]
  %45 = phi i32 [ %50, %47 ], [ 0, %42 ]
  %46 = icmp slt i64 %44, 16, !dbg !52
  br i1 %46, label %47, label %52, !dbg !53

47:                                               ; preds = %43
  %48 = getelementptr i32, i32* %16, i64 %44, !dbg !54
  %49 = load i32, i32* %48, align 4, !dbg !55
  call void @putint(i32 %49), !dbg !56
  call void @putch(i32 32), !dbg !57
  %50 = add i32 %45, %49, !dbg !58
  %51 = add i64 %44, 1, !dbg !59
  br label %43, !dbg !60

52:                                               ; preds = %43
  call void @putch(i32 10), !dbg !61
  call void @putint(i32 %45), !dbg !62
  call void @putch(i32 10), !dbg !63
  %53 = bitcast i32* %2 to i8*, !dbg !64
  call void @free(i8* %53), !dbg !65
  %54 = bitcast i32* %9 to i8*, !dbg !66
  call void @free(i8* %54), !dbg !67
  %55 = bitcast i32* %16 to i8*, !dbg !68
  call void @free(i8* %55), !dbg !69
  ret i32 0, !dbg !70
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "mlir", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "LLVMDialectModule", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "main", linkageName: "main", scope: null, file: !4, line: 6, type: !5, scopeLine: 6, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "results/mlir/03-llvm-dialect.mlir", directory: "/mnt/d/\E7\BC\AA\E8\87\BB/\E6\97\A5\E5\B8\B8\E5\BA\94\E7\94\A8/\E5\8D\97\E5\BC\80\E5\A4\A7\E5\AD\A6/\E5\A4\A7\E4\B8\89\E4\B8\8A/\E7\BC\96\E8\AF\91\E7\B3\BB\E7\BB\9F\E5\8E\9F\E7\90\86/\E5\A4\A7\E4\BD\9C\E4\B8\9A/compile-prepare")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 19, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 20, column: 11, scope: !8)
!10 = !DILocation(line: 22, column: 11, scope: !8)
!11 = !DILocation(line: 23, column: 11, scope: !8)
!12 = !DILocation(line: 25, column: 11, scope: !8)
!13 = !DILocation(line: 26, column: 11, scope: !8)
!14 = !DILocation(line: 27, column: 11, scope: !8)
!15 = !DILocation(line: 33, column: 11, scope: !8)
!16 = !DILocation(line: 34, column: 11, scope: !8)
!17 = !DILocation(line: 36, column: 11, scope: !8)
!18 = !DILocation(line: 37, column: 11, scope: !8)
!19 = !DILocation(line: 39, column: 11, scope: !8)
!20 = !DILocation(line: 40, column: 11, scope: !8)
!21 = !DILocation(line: 41, column: 11, scope: !8)
!22 = !DILocation(line: 47, column: 11, scope: !8)
!23 = !DILocation(line: 48, column: 11, scope: !8)
!24 = !DILocation(line: 50, column: 11, scope: !8)
!25 = !DILocation(line: 51, column: 11, scope: !8)
!26 = !DILocation(line: 53, column: 11, scope: !8)
!27 = !DILocation(line: 54, column: 11, scope: !8)
!28 = !DILocation(line: 55, column: 11, scope: !8)
!29 = !DILocation(line: 56, column: 5, scope: !8)
!30 = !DILocation(line: 58, column: 11, scope: !8)
!31 = !DILocation(line: 59, column: 5, scope: !8)
!32 = !DILocation(line: 61, column: 11, scope: !8)
!33 = !DILocation(line: 62, column: 11, scope: !8)
!34 = !DILocation(line: 63, column: 5, scope: !8)
!35 = !DILocation(line: 64, column: 11, scope: !8)
!36 = !DILocation(line: 65, column: 5, scope: !8)
!37 = !DILocation(line: 66, column: 11, scope: !8)
!38 = !DILocation(line: 67, column: 5, scope: !8)
!39 = !DILocation(line: 69, column: 5, scope: !8)
!40 = !DILocation(line: 71, column: 11, scope: !8)
!41 = !DILocation(line: 72, column: 5, scope: !8)
!42 = !DILocation(line: 74, column: 11, scope: !8)
!43 = !DILocation(line: 75, column: 11, scope: !8)
!44 = !DILocation(line: 76, column: 11, scope: !8)
!45 = !DILocation(line: 77, column: 11, scope: !8)
!46 = !DILocation(line: 78, column: 11, scope: !8)
!47 = !DILocation(line: 79, column: 11, scope: !8)
!48 = !DILocation(line: 80, column: 5, scope: !8)
!49 = !DILocation(line: 81, column: 11, scope: !8)
!50 = !DILocation(line: 82, column: 5, scope: !8)
!51 = !DILocation(line: 84, column: 5, scope: !8)
!52 = !DILocation(line: 86, column: 11, scope: !8)
!53 = !DILocation(line: 87, column: 5, scope: !8)
!54 = !DILocation(line: 89, column: 11, scope: !8)
!55 = !DILocation(line: 90, column: 11, scope: !8)
!56 = !DILocation(line: 91, column: 5, scope: !8)
!57 = !DILocation(line: 92, column: 5, scope: !8)
!58 = !DILocation(line: 93, column: 11, scope: !8)
!59 = !DILocation(line: 94, column: 11, scope: !8)
!60 = !DILocation(line: 95, column: 5, scope: !8)
!61 = !DILocation(line: 97, column: 5, scope: !8)
!62 = !DILocation(line: 98, column: 5, scope: !8)
!63 = !DILocation(line: 99, column: 5, scope: !8)
!64 = !DILocation(line: 100, column: 11, scope: !8)
!65 = !DILocation(line: 101, column: 5, scope: !8)
!66 = !DILocation(line: 102, column: 11, scope: !8)
!67 = !DILocation(line: 103, column: 5, scope: !8)
!68 = !DILocation(line: 104, column: 11, scope: !8)
!69 = !DILocation(line: 105, column: 5, scope: !8)
!70 = !DILocation(line: 106, column: 5, scope: !8)
