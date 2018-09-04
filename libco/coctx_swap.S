/*
* Tencent is pleased to support the open source community by making Libco available.

* Copyright (C) 2014 THL A29 Limited, a Tencent company. All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); 
* you may not use this file except in compliance with the License. 
* You may obtain a copy of the License at
*
*	http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, 
* software distributed under the License is distributed on an "AS IS" BASIS, 
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
* See the License for the specific language governing permissions and 
* limitations under the License.
*/

.globl coctx_swap
#if !defined( __APPLE__ )
.type  coctx_swap, @function
#endif
coctx_swap:

#if defined(__i386__)
	leal 4(%esp), %eax //sp 
	movl 4(%esp), %esp 
	leal 32(%esp), %esp //parm a : &regs[7] + sizeof(void*)

	pushl %eax //esp ->parm a 

	pushl %ebp
	pushl %esi
	pushl %edi
	pushl %edx
	pushl %ecx
	pushl %ebx
	pushl -4(%eax)

	
	movl 4(%eax), %esp //parm b -> &regs[0]

	popl %eax  //ret func addr
	popl %ebx  
	popl %ecx
	popl %edx
	popl %edi
	popl %esi
	popl %ebp
	popl %esp
	pushl %eax //set ret func addr

	xorl %eax, %eax
	ret

#elif defined(__x86_64__)                    // 该函数调用之前，rip（返回地址）会被压栈，所以rsp此时指向返回地址
    leaq 8(%rsp),%rax                    // 此时rax=rsp+8 表示 调用方的栈顶
    leaq 112(%rdi),%rsp                    // rsp 指向regs数组最后一个元素之后，也就是x.ss_size的位置  -- rdi是第一个入参 x  rdi+112 = x.ss_size  //rsp是栈顶指针
    pushq %rax                            // 当前调用方的栈顶入栈        x.regs[13] = rsp  // rsp被上一个指令修改了地址，此时rax保存着调用方的栈顶
    pushq %rbx                          // 当前rbx入栈        x.regs[12] = rbx
    pushq %rcx                            // 当前rcx入栈        x.regs[11] = rcx
    pushq %rdx                            // 当前rdx入栈        x.regs[10] = rdx

    pushq -8(%rax) //ret func addr        // 当前返回地址入栈     x.regs[9] = 返回地址

    pushq %rsi                            // rsi==参数y的地址 x.regs[8] == y
    pushq %rdi                          // rdi==参数x的地址 x.regs[7] == x        
    pushq %rbp                            // 当前rbp入栈        x.regs[6] = rbp
    pushq %r8                            // 当前r8入栈        x.regs[5] = r8
    pushq %r9                            // 当前r9入栈        x.regs[4] = r9
    pushq %r12                            // 当前r12入栈        x.regs[3] = r12
    pushq %r13                            // 当前r13入栈        x.regs[2] = r13
    pushq %r14                            // 当前r14入栈        x.regs[1] = r14
    pushq %r15                            // 当前r15入栈        x.regs[0] = r15
                                        //    以上操作的意思就是： 将当前线程的寄存器状态，保存到x中去，此时x让出cpu
    movq %rsi, %rsp                        // 调整栈顶指针到 参数y的地址
    popq %r15                            // r15 = y.regs[0]
    popq %r14                            // ...
    popq %r13
    popq %r12
    popq %r9
    popq %r8
    popq %rbp
    popq %rdi                            // rdi = y.regs[7] = y   // 如上 x.regs[7] == x     // 当一个新协程开始执行时， rdi 中保存的是 新协程的地址
    popq %rsi                            // rsi = y.regs[8] = xyz? // 未定，指向上一次y让出cpu时候的另一个协程的地址    // 当一个新协程开始执行时，rsi保存的是NULL
    popq %rax //ret func addr            // rax = y.regs[9]     // 当一个新的协程开始执行时， 指向协程的回调函数，实际是对回调函数的封装
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rsp                            // rsp = y.regs[13] // 当一个新协程开始执行时， regs[13]为栈内存的栈底-8 的位置， 此时函数运行时的栈hook到了已设定的内存
                                        // 以上操作的意思就是： 将y中保存的寄存器状态，恢复到寄存器中，此时rsp指向保存时调用方的栈顶，以此作为当前y协程执行的栈底
    pushq %rax                            // 把新协程保存的返回地址压栈，rsp此时指向 返回地址

    xorl %eax, %eax                        // eax=0  eax是rax的低32位，也就是让rax的低32位置0
    ret                                    // 弹出返回地址到rip，到返回地址继续执行； 相当于 pop %rip; 此时 rsp -= 8

#endif
