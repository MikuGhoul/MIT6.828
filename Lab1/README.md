## [Lab 1: Booting a PC](https://pdos.csail.mit.edu/6.828/2018/labs/lab1/)

#### Part 1: PC Bootstrap
##### Getting Started with x86 assembly
 
> Exercise 1. Familiarize yourself with the assembly language materials available on the 6.828 reference page. You don't have to read them now, but you'll almost certainly want to refer to some of this material when reading and writing x86 assembly.

> We do recommend reading the section "The Syntax" in Brennan's Guide to Inline Assembly. It gives a good (and quite brief) description of the AT&T assembly syntax we'll be using with the GNU assembler in JOS.

* Exercises 1
    * 让去学汇编，可以看CSAPP来学AT&T汇编

##### Simulating the x86
* 编译后`make qemu` 和 `make qemu-nox`都可以启动，`make qemu-nox`是模拟串口但不带VGA的，用`ctrl+a x`退出

##### The PC's Physical Address Space
* PC物理地址布局
```
+------------------+  <- 0xFFFFFFFF (4GB)
|      32-bit      |
|  memory mapped   |
|     devices      |
|                  |
/\/\/\/\/\/\/\/\/\/\

/\/\/\/\/\/\/\/\/\/\
|                  |
|      Unused      |
|                  |
+------------------+  <- depends on amount of RAM
|                  |
|                  |
| Extended Memory  |
|                  |
|                  |
+------------------+  <- 0x00100000 (1MB)
|     BIOS ROM     |
+------------------+  <- 0x000F0000 (960KB)
|  16-bit devices, |
|  expansion ROMs  |
+------------------+  <- 0x000C0000 (768KB)
|   VGA Display    |
+------------------+  <- 0x000A0000 (640KB)
|                  |
|    Low Memory    |
|                  |
+------------------+  <- 0x00000000
```
* 低640KB是被称为Low Memory，作为RAM使用
* 0x000A0000 到 0x000FFFFF 的384KB为硬件的特殊用途保留，比如视频播放和非易失固件。最重要的是从 0x000F0000 到 0x000FFFFF 的64KB大小的BIOS
    * BIOS负责基础系统初始化，比如显卡、内存初始化检测，在初始化完成后，BIOS从适当位置加载操作系统，比如软盘、硬盘、CD-ROM或者网络上，并把控制权限交给操作系统
    * 现在的X86处理器支持超过4GB的RAM，RAM扩展超过0xFFFFFFFF，为了让32位设备映射，BIOS的位置也移动到了32位寻址空间外，JOS这里设计的仍然是只使用最开始的256MB，假设PC只有32位地址空间

##### The ROM BIOS
* 用GDB attach后，出现`[f000:fff0] 0xffff0:	ljmp   $0xf000,$0xe05b`，这是第一条将要运行的指令被GDB反汇编出的结果，可以总结如下
    * PC从0x000ffff0这个物理地址开始运行，这是64KB的BIOS的非常上面的位置
    * PC开始运行时，寄存器 CS = 0xf000，IP = 0xfff0
    * 第一条指令是jmp，会跳转到地址 CS = 0xf000，IP = 0xe05b

* 为什么QEMU会这样运行？这是由于IBM使用的Intel 8086处理器设计就是这样，BIOS是hard-wired到物理地址0x000f0000-0x000fffff的，这种设计确保了在PC加电或者系统重启后BIOS总是会获得控制权（QEMU有自己的BIOS）。在加电后，处理器进入实模式，并设置CS = 0xf000，IP = 0xfff0。

* 实模式的寻址公式是：`物理地址 = 16 * 段地址 + 偏移地址`，所以当PC设置CS = 0xf000，IP = 0xfff0后，物理地址为
```
   16 * 0xf000 + 0xfff0   # 16进制中，乘16就是加0
   = 0xf0000 + 0xfff0
   = 0xffff0 
```    


> Exercise 2. Use GDB's si (Step Instruction) command to trace into the ROM BIOS for a few more instructions, and try to guess what it might be doing. You might want to look at Phil Storrs I/O Ports Description, as well as other materials on the 6.828 reference materials page. No need to figure out all the details - just the general idea of what the BIOS is doing first.

* Exercises 2
    * 用GDB跟踪BIOS的指令，关于in/out端口的指令会用到[Phil Storrs I/O Ports Description](http://web.archive.org/web/20040404164813/members.iweb.net.au/~pstorr/pcbook/book2/book2.htm)
* 指令如下
``` x86asm
[f000:fff0]    0xffff0: ljmp   $0xf000,$0xe05b
[f000:e05b]    0xfe05b: cmpl   $0x0,%cs:0x6ac8
[f000:e062]    0xfe062: jne    0xfd2e1
[f000:e066]    0xfe066: xor    %dx,%dx
[f000:e068]    0xfe068: mov    %dx,%ss
[f000:e06a]    0xfe06a: mov    $0x7000,%esp
[f000:e070]    0xfe070: mov    $0xf34c2,%edx
[f000:e076]    0xfe076: jmp    0xfd15c
[f000:d15c]    0xfd15c: mov    %eax,%ecx
[f000:d15f]    0xfd15f: cli
[f000:d160]    0xfd160: cld
[f000:d161]    0xfd161: mov    $0x8f,%eax
[f000:d167]    0xfd167: out    %al,$0x70
[f000:d169]    0xfd169: in     $0x71,%al
[f000:d16b]    0xfd16b: in     $0x92,%al
[f000:d16d]    0xfd16d: or     $0x2,%al
[f000:d16f]    0xfd16f: out    %al,$0x92
[f000:d171]    0xfd171: lidtw  %cs:0x6ab8
[f000:d177]    0xfd177: lgdtw  %cs:0x6a74
[f000:d17d]    0xfd17d: mov    %cr0,%eax
[f000:d180]    0xfd180: or     $0x1,%eax
[f000:d184]    0xfd184: mov    %eax,%cr0
[f000:d187]    0xfd187: ljmpl  $0x8,$0xfd18f
```
* 这些指令大都是和体系结构相关的知识，不必深入了解，简单说一下流程就是设置寄存器，关中断，in/out 70/71控制cmos调整中断，加载IDTR中断向量表，加载GDTR全局描述符，开启保护模式，进入保护模式

#### Part 2: The Boot Loader
* 软盘和硬盘的512字节叫做一个扇区(sector)，是最小的传输粒度（每次独写都是一个或多个扇区，并在扇区边界对齐），可boot的磁盘的第一个扇区叫boot sector，存放boot loader的代码。
* 当BIOS找到可以boot的sector时，会把这个boot sector加载到物理内存的 0x7c00 到 0x7dff，然后jmp到0x7c00，把控制权交给boot loader。（0x7c00这个地址也是PC固定的标准地址）
* jos的boot loader由`boot/boot.S`和`boot/main.c`组成，执行两个功能
    1. 把实模式切换到32位保护模式，因为只有在这个模式下，软件可以访问超过1MB物理地址空间。
        * 保护模式的寻址和实模式不同，具体参见[PC Assembly Language](https://pdos.csail.mit.edu/6.828/2018/readings/pcasm-book.pdf)的1.2.7/1.28
    2. 通过x86的特殊IO指令访问IDE磁盘设备寄存器，从硬盘读取内核

> Exercise 3. Take a look at the lab tools guide, especially the section on GDB commands. Even if you're familiar with GDB, this includes some esoteric GDB commands that are useful for OS work.

> Set a breakpoint at address 0x7c00, which is where the boot sector will be loaded. Continue execution until that breakpoint. Trace through the code in boot/boot.S, using the source code and the disassembly file obj/boot/boot.asm to keep track of where you are. Also use the x/i command in GDB to disassemble sequences of instructions in the boot loader, and compare the original boot loader source code with both the disassembly in obj/boot/boot.asm and GDB.

> Trace into bootmain() in boot/main.c, and then into readsect(). Identify the exact assembly instructions that correspond to each of the statements in readsect(). Trace through the rest of readsect() and back out into bootmain(), and identify the begin and end of the for loop that reads the remaining sectors of the kernel from the disk. Find out what code will run when the loop is finished, set a breakpoint there, and continue to that breakpoint. Then step through the remainder of the boot loader.

* Exercise 3
    * bootloader两个文件
        1. boot.S的主要作用是切换到保护模式，并跳到C代码
            * 关于[boot/boot.S](https://github.com/MikuGhoul/MIT6.828/blob/master/Lab1/boot/boot.S)文件，我在源文件里补充了一些注释
        2. main.c的主要作用是从硬盘读内核的代码到内存，并跳到内核这个ELF文件的入口点
            * 大致流程是先读几个sector，然后通过elf header的magic number判断是不是elf文件，若是就通过elf header里的program header信息读program header到内存。可以参看 [Executable and Linkable Format](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format) wiki
            * readsect向不同的端口打数据就是控制磁盘驱动的，别的函数看注释就可以了

> At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?

* `ljmp    $PROT_MODE_CSEG, $protcseg`这条指令开始运行32位代码，把CR0寄存器的PE位置1导致从16位实模式进入32位保护模式

> What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?

* `((void (*)(void)) (ELFHDR->e_entry))();`是boot loader的最后一句，通过gdb可以追到kernel的第一句是在0x10000c的`movw   $0x1234,0x472 `

> Where is the first instruction of the kernel?

* 在`0x10000c`，用gdb `b`到上面e_entry，看到是`call *0x10018`，`p *0x10018`结果就是`0x10000c`。或者直接用readelf/objdump看入口地址

> How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?

* 在jos里boot loader会先读8个sector，里面有elf header信息，从elf header里获取有多少个program header entry，多大size等信息，然后根据这个信息决定读多少

##### Loading the Kernel
* Exercise 4
    * 略

* 理解`boot/main.c`，需要知道elf二进制文件。当编译并链接一个jos这样的C程序，编译器把C源码(.c)编译为目标文件(.o)，包括了硬件上可运行的二进制编码。然后链接器将所有的目标文件链接成一个二进制镜像文件`obj/kern/kernel`，这个二进制文件就是elf文件
* elf文件由带有**加载信息的头部**和**几个程序段组成**
    * 每个程序段由连续的**代码**和**数据**组成
    * bootloader不修改elf代码，只加载后运行
* elf header定义在`inc/elf.h`
* 几个比较有用的program section
    * .text: 程序运行指令
    * .rodata: 只读数据
    * .data: 初始化全局变量
    * .bss: 未初始化全局变量
        * .bss段本身不占用实际的elf文件的空间，由链接器(linker)记录.bss段的地址和大小，最终加载器（loader)或者本身运行的时候才会真正清零，占用空间

* `objdump -x obj/kern/kernel`
    * section header
        * 注意.text section的VMA和LMA
            * LMA(load address)：section被load进内存的地址
            * VMA(link address)：section被执行的内存地址
        * 通常情况下VMA和LMA是相同的
    * program header
        * 会被load的区域被标记为"LOAD"
        * 以及其他的信息vaddr(virtual address), paddr(pyhsical address), memsz 和 filesz(加载区域大小)

> Exercise 5. Trace through the first few instructions of the boot loader again and identify the first instruction that would "break" or otherwise do the wrong thing if you were to get the boot loader's link address wrong. Then change the link address in boot/Makefrag to something wrong, run make clean, recompile the lab with make, and trace into the boot loader again to see what happens. Don't forget to change the link address back and make clean again afterward!
* Exercise 5
    * 修改一下`boot/Makefrag`中的`-Ttext 0x7C00`，然后gdb重新跟一下bootloader，比如改成`0x8c00`
* 由于此时的loader加载的是bootloader，还有没有操作系统存在，是由bios担任此时的loader，而bios默认规定的链接bootloader地址是`0x7c00`，所以即使用`objdump`看新编译好的bootloader，VMA/LMA地址显示的是`00008c00`，但用gdb跟代码后还是发现依旧被load到`0x7c00`。
* 而在符号重定向的时候，根据elf header中的地址把编译器生成的一些地址进行替换的时候使用的是`0x8c00`，而不是`0x7c00`，所以就会出现
``` x86asm
 17│    0x7c1e:      lgdtw  0x7c64
 18│    0x7c23:      mov    %cr0,%eax
 19│    0x7c26:      or     $0x1,%eax
 20│    0x7c2a:      mov    %eax,%cr0
 21│    0x7c2d:      ljmp   $0x8,$0x7c32
```
变成了
``` x86asm
 17│    0x7c1e:      lgdtw  -0x739c
 18│    0x7c23:      mov    %cr0,%eax
 19│    0x7c26:      or     $0x1,%eax
 20│    0x7c2a:      mov    %eax,%cr0
 21│    0x7c2d:      ljmp   $0x8,$0x8c32
```

> Exercise 6. We can examine memory using GDB's x command. The GDB manual has full details, but for now, it is enough to know that the command x/Nx ADDR prints N words of memory at ADDR. (Note that both 'x's in the command are lowercase.) Warning: The size of a word is not a universal standard. In GNU assembly, a word is two bytes (the 'w' in xorw, which stands for word, means 2 bytes).

> Reset the machine (exit QEMU/GDB and start them again). Examine the 8 words of memory at 0x00100000 at the point the BIOS enters the boot loader, and then again at the point the boot loader enters the kernel. Why are they different? What is there at the second breakpoint? (You do not really need to use QEMU to answer this question. Just think.)

* Exercise 6
    * 在bios进入bootloader的时候(0x7c00)用gdb查看`0x00100000`发现结果如下
    ``` x86asm
    (gdb) x/8x 0x00100000
    0x100000:	0x00000000	0x00000000	0x00000000	0x00000000
    0x100010:	0x00000000	0x00000000	0x00000000	0x00000000
    ```
    * 而在bootloader的最后一条指令(0x7d61)用gdb查看`0x00100000`发现结果如下
    ```x86asm
    (gdb) x/8x 0x00100000
    0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
    0x100010:	0x34000004	0x0000b812	0x220f0011	0xc0200fd8
    ```
    * 原因就是因为bootloader把kernel加载进来了

#### Part 3: The Kernel
* 向bootloader一样，kernel开始也是需要一些汇编代码设置点东西，这样C代码才能正确运行

##### Using virtual memory to work around position dependence
* bootloader的VMA(link address)和LMA(load address)是一样的
* kernel的VMA和LMA有很大差距
    * `kern/kernel.ld`中改变kernel的VMA为`0xF0100000`
* 操作系统通常是link并run在非常高的虚拟地址，比如`0xF0100000`，是为了把低的虚拟地址空间留给用户态程序使用
* 一些机器没有`0xf0100000`这么高的物理地址，所以不能指望把kernel存储在这，但可以用处理器的内存管理硬件硬件把`0xf0100000`(link address: kernel期望被运行的地址)映射到`0x00100000`(load address: bootloader把kernel实际load进物理内存的地址)
* 现在，我们只映射物理内存的前4MB，足够了启动和运行。实现方法在`kern/entrypgdir.c`，用手写的静态初始化**页目录**(page directory)和**页表**(page table)
* 在`kern/entry.S`中，设置cr0寄存器的pg位之前，内存引用的都是物理内存（严格的说是线性地址，只不过把线性地址和物理地址进行了映射），一旦pg位被设置，内存引用的就是虚拟地址了，通过虚拟内存硬件翻译为物理地址
* `entry_pgdir`把虚拟地址`0xf0000000 ~ 0xf0400000` 翻译为物理地址`0x00000000 ~ 0x00400000`，同样，`0x00000000 ~ 0x00400000`被翻译为`0x00000000 ~ 0x00400000`。不在这两个范围内的虚拟地址会导致硬件异常

> Exercise 7. Use QEMU and GDB to trace into the JOS kernel and stop at the movl %eax, %cr0. Examine memory at 0x00100000 and at 0xf0100000. Now, single step over that instruction using the stepi GDB command. Again, examine memory at 0x00100000 and at 0xf0100000. Make sure you understand what just happened.

> What is the first instruction after the new mapping is established that would fail to work properly if the mapping weren't in place? Comment out the movl %eax, %cr0 in kern/entry.S, trace into it, and see if you were right.

* Exercise 7
    1. `movl %eax, %cr0`后开启了分页(引入虚拟地址)，**Map VA's [0, 4MB) to PA's [0, 4MB) ,Map VA's [KERNBASE, KERNBASE+4MB) to PA's [0, 4MB)**，所以分页后`0x00100000`和`0xf0100000`会映射到相同的物理地址(因为KERNBASE为0xf0000000)，用gdb的`x/4i`查看`0x00100000`和`0xf0100000`这两个不同的虚拟地址会发现是相同的指令，分页前却是不同的
        * 参见`kern/entry.S`和`kern/entrypgdir.c`
    2. 无论是否开启分页进行虚拟地址映射，都会用`jmp`指令跳转到临近的下条指令，比如从`0x10002d`跳转到`0xf010002f`
        * 开启分页的话，`[KERNBASE, KERNBASE+4MB)`是已经映射到了物理地址的`[0,4MB)`，所以`0xf010002f`会被映射到`0x0010002f`，所以会正常运行    
            * 因为前面声明了`_start = RELOC(entry)`，即强制把运行的起始地址从KERNBASE以上改到了与实际物理地址相同的虚拟地址，所以`jmp`前的代码实际上都是在`[0,4MB)`运行，所以没有出错
        * 不开启分页的话(注释掉`movl %eax, %cr0`)，`[KERNBASE, KERNBASE+4MB)`这段虚拟地址没有进行映射，`x/8x addr`看一下就知道了里面全是`0x000000`，必然会出错
    
##### Formatted Printing to the Console
> Exercise 8. We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment.

* Exercise 8
    * 对比一下别的case直接写，没什么可说的
    * 深入了解看[stdarg.h wiku](https://en.wikipedia.org/wiki/Stdarg.h) 和 [fprintf cppreference](https://en.cppreference.com/w/c/io/fprintf)

1. Explain the interface between printf.c and console.c. Specifically, what function does console.c export? How is this function used by printf.c?
    * `console.c`提供了`void cputchar(int c)`这个函数给`printf.c`，`printf.c`把这个函数作为输出一个字符的API
2. Explain the following from console.c:
    ``` c
    1      if (crt_pos >= CRT_SIZE) {
    2              int i;
    3              memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
    4              for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
    5                      crt_buf[i] = 0x0700 | ' ';
    6              crt_pos -= CRT_COLS;
    7      }
    ```
    * 作用就是当在把屏幕写满的时候，整体上滚一行，留出新的空行

3. For the following questions you might wish to consult the notes for Lecture 2. These notes cover GCC's calling convention on the x86. Trace the execution of the following code step-by-step:
    ``` c
    int x = 1, y = 3, z = 4;
    cprintf("x %d, y %x, z %d\n", x, y, z);
    ```
    1. In the call to cprintf(), to what does fmt point? To what does ap point?
    2. List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.
    * 理解就可以了，也可以放到代码中编译运行试一试

4. Run the following code.
    ``` c
    unsigned int i = 0x00646c72;
    cprintf("H%x Wo%s", 57616, &i);
    ```
    1. What is the output?
        * 输出 `He110 World`
    2. The output depends on that fact that the x86 is little-endian. If the x86 were instead big-endian what would you set i to in order to yield the same output? Would you need to change 57616 to a different value?
        * 如果是big-endian，i应该为0x726c6400，57616不用变

5. In the following code, what is going to be printed after 'y='? (note: the answer is not a specific value.) Why does this happen?
    * `cprintf("x=%d y=%d", 3);`
        * 这是个ub，因为最终调用va_arg的时候，ap这个va_list里面已经没有多余的未解析参数了，参考[va_arg](https://en.cppreference.com/w/cpp/utility/variadic/va_arg)里的
        > If va_arg is called when there are no more arguments in ap, the behavior is undefined.

6. Let's say that GCC changed its calling convention so that it pushed arguments on the stack in declaration order, so that the last argument is pushed last. How would you have to change cprintf or its interface so that it would still be possible to pass it a variable number of arguments?
    * 把`int cprintf(const char *fmt, ...)`改为`int	cprintf(..., const char *fmt)`
    * 看看[C语言函数参数压栈顺序为何是从右到左？](https://blog.csdn.net/jiange_zh/article/details/47381597)就懂了

* Challenge
    * 先略过哈

##### The Stack
> Exercise 9. Determine where the kernel initializes its stack, and exactly where in memory its stack is located. How does the kernel reserve space for its stack? And at which "end" of this reserved area is the stack pointer initialized to point to?
* Exercise 9
    * 在`kern/entry.S`中的`movl $0x0, %ebp`和`movl $(bootstacktop), %esp`设置栈指针，初始化栈
    * 用objdump反汇编kernel文件，可以看到bootstacktop的地址在0xf0110000，属于.date段
    * 在`kern/entry.S`中，用`.space KSTKSIZE`声明了栈的大小，为8个page大小，即 8*4096 byte
    * esp初始化时指向的是低地址的栈顶

* esp**栈指针寄存器**，指向当前栈的低地址，更低地址的栈空间是空闲的，push是减小esp值，并把值写入esp所指的地址。pop是从esp所指地址读数据，并增加esp值
* ebp**栈基址寄存器**，是栈预先约定的规则。进入C函数中，通常先要通过push到栈中保存上一个函数的ebp，并把esp赋值给ebp。
    * 参考[栈帧%ebp,%esp详解](https://blog.csdn.net/wojiuguowei/article/details/78958794)
    * 有这样的约定规则十分有用，比如在assert失败或者panic时，可以通过栈的调用链保存的ebp寄存器回溯来决定嵌套调用序列

> Exercise 10. To become familiar with the C calling conventions on the x86, find the address of the test_backtrace function in obj/kern/kernel.asm, set a breakpoint there, and examine what happens each time it gets called after the kernel starts. How many 32-bit words does each recursive nesting level of test_backtrace push on the stack, and what are those words?
* Exercise 10
    * 略

> Exercise 11. Implement the backtrace function as specified above. Use the same format as in the example, since otherwise the grading script will be confused. When you think you have it working right, run make grade to see if its output conforms to what our grading script expects, and fix it if it doesn't. After you have handed in your Lab 1 code, you are welcome to change the output format of the backtrace function any way you like.
* Exerciese 11
    * 实现`mon_backtrace`，知道函数调用时候堆栈发生了什么就很好写了，参考反汇编
        * 函数首先把参数入栈（对应反汇编的push），然后把函数返回后接下来运行的语句地址入栈（汇编通过call语句实现，call可以分解为push和jmp），然后进入被调用函数，把调用函数的栈基质入栈（对应反汇编的push %ebp）
    * 知道了入栈顺序后，就可以通过ebp计算出其余值

> Exercise 12.Exercise 12. Modify your stack backtrace function to display, for each eip, the function name, source file name, and line number corresponding to that eip.

* Exercise 12
    * 这里通过修改`kernel.ld`，添加`.stab`section，为后面获取debug信息准备，即相当于在编译后的elf文件中添加了所需的debug信息。调用debuginfo_eip通过eip存储的地址来获取信息，包括当前指令所在文件、函数、行数等
    * 修改的文件有`kern/kdebug.c`和`kern/monitor.c`