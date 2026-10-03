; Handwritten SSA version of src/factorial.sy.
@limit = constant i32 12
declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)
define i32 @factorial(i32 %n) {
entry:
  %negative = icmp slt i32 %n, 0
  br i1 %negative, label %invalid, label %upper
upper:
  %bound = load i32, i32* @limit
  %large = icmp sgt i32 %n, %bound
  br i1 %large, label %invalid, label %loop
invalid:
  ret i32 -1
loop:
  %i = phi i32 [2, %upper], [%next, %body]
  %product = phi i32 [1, %upper], [%multiply, %body]
  %more = icmp sle i32 %i, %n
  br i1 %more, label %body, label %done
body:
  %multiply = mul i32 %product, %i
  %next = add i32 %i, 1
  br label %loop
done:
  ret i32 %product
}
define i32 @main() {
entry:
  %n = call i32 @getint()
  %result = call i32 @factorial(i32 %n)
  call void @putint(i32 %result)
  call void @putch(i32 10)
  ret i32 0
}
