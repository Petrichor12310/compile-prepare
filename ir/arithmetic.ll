; Handwritten LLVM 14 IR. Signed division truncates towards zero.
declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

define void @emit(i32 %value) {
entry:
  call void @putint(i32 %value)
  call void @putch(i32 10)
  ret void
}

define i32 @main() {
entry:
  %a = call i32 @getint()
  %b = call i32 @getint()
  %zero = icmp eq i32 %b, 0
  br i1 %zero, label %invalid, label %calculate
invalid:
  call void @emit(i32 -1)
  ret i32 0
calculate:
  %add = add nsw i32 %a, %b
  call void @emit(i32 %add)
  %sub = sub nsw i32 %a, %b
  call void @emit(i32 %sub)
  %mul = mul nsw i32 %a, %b
  call void @emit(i32 %mul)
  %quotient = sdiv i32 %a, %b
  call void @emit(i32 %quotient)
  %remainder = srem i32 %a, %b
  call void @emit(i32 %remainder)
  %neg = sub nsw i32 0, %a
  call void @emit(i32 %neg)
  call void @emit(i32 %a)
  %lt = icmp slt i32 %a, %b
  %lt32 = zext i1 %lt to i32
  call void @emit(i32 %lt32)
  %le = icmp sle i32 %a, %b
  %le32 = zext i1 %le to i32
  call void @emit(i32 %le32)
  %gt = icmp sgt i32 %a, %b
  %gt32 = zext i1 %gt to i32
  call void @emit(i32 %gt32)
  %ge = icmp sge i32 %a, %b
  %ge32 = zext i1 %ge to i32
  call void @emit(i32 %ge32)
  %eq = icmp eq i32 %a, %b
  %eq32 = zext i1 %eq to i32
  call void @emit(i32 %eq32)
  %ne = icmp ne i32 %a, %b
  %ne32 = zext i1 %ne to i32
  call void @emit(i32 %ne32)
  ret i32 0
}
