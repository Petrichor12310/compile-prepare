; Handwritten LLVM 14 IR: nested arrays and a row pointer parameter.
declare i32 @getint()
declare float @getfloat()
declare void @putfloat(float)
declare void @putint(i32)
declare void @putch(i32)
define float @sum(float* %row, i32 %n) {
entry:
  br label %loop
loop:
  %i = phi i32 [0, %entry], [%next, %body]
  %total = phi float [0.0, %entry], [%added, %body]
  %more = icmp slt i32 %i, %n
  br i1 %more, label %body, label %done
body:
  %element = getelementptr float, float* %row, i32 %i
  %value = load float, float* %element
  %added = fadd float %total, %value
  %next = add i32 %i, 1
  br label %loop
done:
  ret float %total
}
define i32 @main() {
entry:
  %array = alloca [2 x [3 x float]], align 4
  store [2 x [3 x float]] [[3 x float] [float 1.0, float 2.0, float 3.0], [3 x float] [float 4.0, float 5.0, float 6.0]], [2 x [3 x float]]* %array
  %bias = call i32 @getint()
  %x = call float @getfloat()
  %slot = getelementptr [2 x [3 x float]], [2 x [3 x float]]* %array, i32 0, i32 1, i32 1
  store float %x, float* %slot
  %row = getelementptr [2 x [3 x float]], [2 x [3 x float]]* %array, i32 0, i32 1, i32 0
  %sum = call float @sum(float* %row, i32 3)
  %bias.float = sitofp i32 %bias to float
  %result = fadd float %sum, %bias.float
  call void @putfloat(float %result)
  call void @putch(i32 10)
  %integer = fptosi float %result to i32
  call void @putint(i32 %integer)
  call void @putch(i32 10)
  ret i32 0
}
