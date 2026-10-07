; ModuleID = 'src/factorial.sy'
source_filename = "src/factorial.sy"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@limit = dso_local local_unnamed_addr constant i32 12, align 4

; Function Attrs: nofree noinline norecurse nosync nounwind readnone uwtable
define dso_local i32 @factorial(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp ugt i32 %0, 12
  br i1 %2, label %23, label %3

3:                                                ; preds = %1
  %4 = icmp ult i32 %0, 2
  br i1 %4, label %23, label %5

5:                                                ; preds = %3
  %6 = add i32 %0, 2
  %7 = and i32 %6, -4
  %8 = add i32 %0, -2
  %9 = insertelement <4 x i32> poison, i32 %8, i64 0
  %10 = shufflevector <4 x i32> %9, <4 x i32> poison, <4 x i32> zeroinitializer
  switch i32 %7, label %11 [
    i32 4, label %13
    i32 8, label %12
  ]

11:                                               ; preds = %5
  br label %13

12:                                               ; preds = %5
  br label %13

13:                                               ; preds = %5, %12, %11
  %14 = phi i32 [ 0, %5 ], [ 8, %11 ], [ 4, %12 ]
  %15 = phi <4 x i32> [ <i32 1, i32 1, i32 1, i32 1>, %5 ], [ <i32 12, i32 21, i32 32, i32 45>, %11 ], [ <i32 2, i32 3, i32 4, i32 5>, %12 ]
  %16 = phi <4 x i32> [ <i32 2, i32 3, i32 4, i32 5>, %5 ], [ <i32 120, i32 231, i32 384, i32 585>, %11 ], [ <i32 12, i32 21, i32 32, i32 45>, %12 ]
  %17 = insertelement <4 x i32> poison, i32 %14, i64 0
  %18 = shufflevector <4 x i32> %17, <4 x i32> poison, <4 x i32> zeroinitializer
  %19 = or <4 x i32> %18, <i32 0, i32 1, i32 2, i32 3>
  %20 = icmp ugt <4 x i32> %19, %10
  %21 = select <4 x i1> %20, <4 x i32> %15, <4 x i32> %16
  %22 = call i32 @llvm.vector.reduce.mul.v4i32(<4 x i32> %21)
  br label %23

23:                                               ; preds = %13, %3, %1
  %24 = phi i32 [ -1, %1 ], [ 1, %3 ], [ %22, %13 ]
  ret i32 %24
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #1 {
  %1 = tail call i32 (...) @getint() #4
  %2 = tail call i32 @factorial(i32 noundef %1)
  tail call void @putint(i32 noundef %2) #4
  tail call void @putch(i32 noundef 10) #4
  ret i32 0
}

declare i32 @getint(...) local_unnamed_addr #2

declare void @putint(i32 noundef) local_unnamed_addr #2

declare void @putch(i32 noundef) local_unnamed_addr #2

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i32 @llvm.vector.reduce.mul.v4i32(<4 x i32>) #3

attributes #0 = { nofree noinline norecurse nosync nounwind readnone uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { noinline nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nofree nosync nounwind readnone willreturn }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
