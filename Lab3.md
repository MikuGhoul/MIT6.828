## [Lab 3: User Environments](https://pdos.csail.mit.edu/6.828/2018/labs/lab3/)

##### Introduction
* 在这个lab，我们实现基础的内核功能来保护用户空间运行，增强jos内核去建立用户空间的数据交换，创造一个单一的用户环境，加载一个程序镜像并运行，并仍内核一个处理用户空间产生的系统调用和各种异常
* 注意：这里的**环境**类似**进程**，为了与UNIX区分

#### Part A: User Environments and Exception Handling

##### Allocating the Environments Array
* 想Lab2中，在mem_init中申请了pages数组一样，现在申请envs数组
* Exercise 1
    * 