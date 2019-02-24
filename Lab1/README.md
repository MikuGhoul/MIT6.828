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

#### Loading the Kernel
* Exercise 4
    * 略


