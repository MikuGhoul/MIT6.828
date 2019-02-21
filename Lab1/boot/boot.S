#include <inc/mmu.h>

# Start the CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

# .set 伪指令设置全局变量
.set PROT_MODE_CSEG, 0x8         # kernel code segment selector
.set PROT_MODE_DSEG, 0x10        # kernel data segment selector
.set CR0_PE_ON,      0x1         # protected mode enable flag

# .global 伪指令，设置为全局符号，使start对链接器可见
# cli 会置eflags寄存器的IF位为0，关闭中断，bootloader过程不相应中断
# cld 会置eflags寄存器的df位为0，控制串处理指令方向
.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
  cld                         # String operations increment

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
  movw    %ax,%ds             # -> Data Segment
  movw    %ax,%es             # -> Extra Segment
  movw    %ax,%ss             # -> Stack Segment

  # A20是为了实模式下兼容8088/8086的部分软件，马上就要进入保护模式了，就可以解除限制，开启A20
  # 开启A20 Gate是对0x100000-0x10FFEF(0xffff:0xffff)之间的地址寻址时，系统正常访问物理内存
  # 关闭A20 Gate是对0x100000-0x10FFEF之间的地址寻址时，会取模0x100000后进行访问（舍弃大于0x100000的位）
  # 
  # 从0x64端口读1 byte数据到al中，然后判断第2位是否为0，不为0则跳转到seta20.1重新读数据
  #   这里0x64端口管理A20 Gate的控制器的端口，为0表示缓冲区空，可以向端口写数据
  # 为0则向端口0x64写入0xd1，同理seta20.2是向0x60写入0xdf
  #   写入后就打开了A20，具体端口操作去查硬件手册
  # 
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.1

  movb    $0xd1,%al               # 0xd1 -> port 0x64
  outb    %al,$0x64

seta20.2:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.2

  movb    $0xdf,%al               # 0xdf -> port 0x60
  outb    %al,$0x60

  # lgdt作用是设置GDTR，格式是固定的：GDT的size和offset
  #   0x17是23，所以GDT是24 byte，因为每个GDT entry是8 byte，所以会声明3个GDT entry
  # SEG宏展开，分别声明了null seg，code seg，data seg
  # cr0寄存器的0位被置1，0位是PE标志位，当设置该位时即开启了保护模式，进入32位模式
  #
  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
  movl    %cr0, %eax
  orl     $CR0_PE_ON, %eax
  movl    %eax, %cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
  movw    %ax, %ds                # -> DS: Data Segment
  movw    %ax, %es                # -> ES: Extra Segment
  movw    %ax, %fs                # -> FS
  movw    %ax, %gs                # -> GS
  movw    %ax, %ss                # -> SS: Stack Segment
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
  call bootmain

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin

# Bootstrap GDT
.p2align 2                                # force 4 byte alignment
gdt:
  SEG_NULL				# null seg
  SEG(STA_X|STA_R, 0x0, 0xffffffff)	# code seg
  SEG(STA_W, 0x0, 0xffffffff)	        # data seg

gdtdesc:
  .word   0x17                            # sizeof(gdt) - 1
  .long   gdt                             # address gdt

