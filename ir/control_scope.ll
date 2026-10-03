; Handwritten memory-based IR with explicit short-circuit branches.
@probes = global i32 0
declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)
define i32 @tick() {
entry:
  %old = load i32, i32* @probes
  %next = add i32 %old, 1
  store i32 %next, i32* @probes
  ret i32 1
}
define i32 @main() {
entry:
  %total.addr = alloca i32
  %i.addr = alloca i32
  %inner.n.addr = alloca i32
  %n = call i32 @getint()
  store i32 0, i32* %total.addr
  store i32 0, i32* %i.addr
  br label %condition
condition:
  %i.old = load i32, i32* %i.addr
  %more = icmp slt i32 %i.old, %n
  br i1 %more, label %body, label %and.left
body:
  %i = add i32 %i.old, 1
  store i32 %i, i32* %i.addr
  %remainder = srem i32 %i, 2
  %even = icmp eq i32 %remainder, 0
  br i1 %even, label %condition, label %break.check
break.check:
  %stop = icmp sgt i32 %i, 9
  br i1 %stop, label %and.left, label %inner.scope
inner.scope:
  store i32 %i, i32* %inner.n.addr
  %inner.n = load i32, i32* %inner.n.addr
  %total.old = load i32, i32* %total.addr
  %total.next = add i32 %total.old, %inner.n
  store i32 %total.next, i32* %total.addr
  br label %condition
and.left:
  %positive = icmp sgt i32 %n, 0
  br i1 %positive, label %and.right, label %or.left
and.right:
  %and.value = call i32 @tick()
  %and.true = icmp ne i32 %and.value, 0
  br i1 %and.true, label %add.hundred, label %or.left
add.hundred:
  %t1 = load i32, i32* %total.addr
  %t2 = add i32 %t1, 100
  store i32 %t2, i32* %total.addr
  br label %or.left
or.left:
  %negative = icmp slt i32 %n, 0
  br i1 %negative, label %add.ten, label %or.right
or.right:
  %or.value = call i32 @tick()
  %or.true = icmp ne i32 %or.value, 0
  br i1 %or.true, label %add.ten, label %not.check
add.ten:
  %t3 = load i32, i32* %total.addr
  %t4 = add i32 %t3, 10
  store i32 %t4, i32* %total.addr
  br label %not.check
not.check:
  %zero = icmp eq i32 %n, 0
  br i1 %zero, label %add.one, label %output
add.one:
  %t5 = load i32, i32* %total.addr
  %t6 = add i32 %t5, 1
  store i32 %t6, i32* %total.addr
  br label %output
output:
  %total = load i32, i32* %total.addr
  call void @putint(i32 %total)
  call void @putch(i32 32)
  %count = load i32, i32* @probes
  call void @putint(i32 %count)
  call void @putch(i32 10)
  ret i32 0
}
