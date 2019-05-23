## [Lab 2: Memory Management](https://pdos.csail.mit.edu/6.828/2018/labs/lab2/#Part-1--Physical-Page-Management)

#### Part 1: Physical Page Management
* Exercise 1
    * 实现`boot_alloc(), mem_init(), page_init(), page_alloc(), page_free()`
    * boot_alloc
        * nextfree是下一个空闲内存的**虚拟地址**，通过ld文件里的end来实现
        * ROUNDUP && ROUNDDOWN 是在需要内存对齐的时候使用
        * 注意返回的也是虚拟地址，在判断内存时候溢出的时候也因为是虚拟地址所以加上了KERNBASE
    * mem_init
        * 填充pages数组，这个数组存放的是所有的物理页
        * 而这个数组需要对应的内存空间，所以用boot_alloc分配 (物理页个数 * 存放物理页信息的结构体的大小) 的空间
    * page_init
        * 初始化mem_init里申请的pages数组
        * 第0物理页留给idt和bios结构用，所以不操作
        * 剩下的base内存按页链成链表
        * 中间的IO空洞留着不操作
        * 后面的内存同样链成链表
    * page_alloc
        * 申请一个物理页
        * 从page_free_list链表里取，指针对应移位
    * page_free
        * 释放一个物理页
        * 还给page_free_list链表，注意条件

#### Part 2: Virtual Memory
* Exercise 2
    * 阅读[Intel 80386 Reference Programmer's Manual](https://pdos.csail.mit.edu/6.828/2018/readings/i386/toc.htm)的5.2(Page Translation)和6.4(Page-Level Protection)

![Address Translation Overview](https://pdos.csail.mit.edu/6.828/2018/readings/i386/fig5-1.gif)
* 如图，地址的翻译过程是 **逻辑地址 -> 线性地址 -> 物理地址**
    * 逻辑地址 -> 线性地址 是通过**分段机制**
    * 线性地址 -> 物理地址 是通过**分页机制**

##### Virtual, Linear, and Physical Addresses
* 在x86中，虚拟地址由段选择子和段偏移地址组成，线性地址是在分段翻译后分页翻译前的地址，物理地址是分段翻译和分页翻译后的地址，最终在硬件总线上到RAM
```

           Selector  +--------------+         +-----------+
          ---------->|              |         |           |
                     | Segmentation |         |  Paging   |
Software             |              |-------->|           |---------->  RAM
            Offset   |  Mechanism   |         | Mechanism |
          ---------->|              |         |           |
                     +--------------+         +-----------+
            Virtual                   Linear                Physical

```
* 在`boot/boot.S`中，GDT将段基址设为0到0xffffffff，所以虚拟地址(逻辑地址)偏移量等于线性地址

* Exercise 3
    * xp/Nx paddr -- 查看paddr物理地址处开始的，N个字的16进制的表示结果
    * info registers -- 展示所有内部寄存器的状态
    * info mem -- 展示所有已经被页表映射的虚拟地址空间，以及它们的访问优先级
    * info pg -- 展示当前页表的结构

* 一旦进入保护模式后，就没有任何办法可以直接使用线性地址或物理地址，所有内存引用都被解释为虚拟地址并由MMU转换，C中的指针也是一样
* 内核中的地址在代码中类型区分
```
C type	    Address type

T*  	        Virtual
uintptr_t  	Virtual
physaddr_t  	Physical
```

##### Reference counting
* 使用struct PageInfo中的pp_ref作为引用计数，表示对应的物理页被同时映射为多少个虚拟地址
* 通常，这个引用计数应该等于物理页在页表中出现在**UTOP下面**物理页的个数
    * 可以看`inc/memlayout.h`中的虚拟地址映射图，在UTOP上的映射地址大都是在boot时建立的，并且应该永远不会被free掉，在UTOP下面的地址大都是用户空间，可free
* 注意，page_alloc返回的物理页引用计数都是0

##### Page Table Management