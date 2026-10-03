; Handwritten LLVM 14 IR. No target layout: native and RV64 can compile it.
declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)
define i32 @main() {
entry:
  %value = call i32 @getint()
  call void @putint(i32 %value)
  call void @putch(i32 10)
  ret i32 0
}
