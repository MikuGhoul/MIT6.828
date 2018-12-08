
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 f8 06 ff ff    	lea    -0xf908(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 e6 09 00 00       	call   f0100a49 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 0b 08 00 00       	call   f0100883 <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 14 07 ff ff    	lea    -0xf8ec(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 be 09 00 00       	call   f0100a49 <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 da 14 00 00       	call   f01015a9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 2f 07 ff ff    	lea    -0xf8d1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 61 09 00 00       	call   f0100a49 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 8c 07 00 00       	call   f010088d <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 5b 07 00 00       	call   f010088d <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 4a 07 ff ff    	lea    -0xf8b6(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 f6 08 00 00       	call   f0100a49 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 b5 08 00 00       	call   f0100a12 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 86 07 ff ff    	lea    -0xf87a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 de 08 00 00       	call   f0100a49 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 62 07 ff ff    	lea    -0xf89e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 b1 08 00 00       	call   f0100a49 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 6e 08 00 00       	call   f0100a12 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 86 07 ff ff    	lea    -0xf87a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 97 08 00 00       	call   f0100a49 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 b8 08 ff 	movzbl -0xf748(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 b8 07 ff 	movzbl -0xf848(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 7c 07 ff ff    	lea    -0xf884(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 66 07 00 00       	call   f0100a49 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 b8 08 ff 	movzbl -0xf748(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 07             	or     $0x7,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 b2 10 00 00       	call   f01015f6 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 88 07 ff ff    	lea    -0xf878(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 1b 03 00 00       	call   f0100a49 <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 b8 09 ff ff    	lea    -0xf648(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 d6 09 ff ff    	lea    -0xf62a(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 db 09 ff ff    	lea    -0xf625(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 ba 02 00 00       	call   f0100a49 <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 44 0a ff ff    	lea    -0xf5bc(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 e4 09 ff ff    	lea    -0xf61c(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 a3 02 00 00       	call   f0100a49 <cprintf>
	return 0;
}
f01007a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ae:	5b                   	pop    %ebx
f01007af:	5e                   	pop    %esi
f01007b0:	5d                   	pop    %ebp
f01007b1:	c3                   	ret    

f01007b2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	57                   	push   %edi
f01007b6:	56                   	push   %esi
f01007b7:	53                   	push   %ebx
f01007b8:	83 ec 18             	sub    $0x18,%esp
f01007bb:	e8 fc f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007c0:	81 c3 48 0b 01 00    	add    $0x10b48,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c6:	8d 83 ed 09 ff ff    	lea    -0xf613(%ebx),%eax
f01007cc:	50                   	push   %eax
f01007cd:	e8 77 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d2:	83 c4 08             	add    $0x8,%esp
f01007d5:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007db:	8d 83 6c 0a ff ff    	lea    -0xf594(%ebx),%eax
f01007e1:	50                   	push   %eax
f01007e2:	e8 62 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f0:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f6:	50                   	push   %eax
f01007f7:	57                   	push   %edi
f01007f8:	8d 83 94 0a ff ff    	lea    -0xf56c(%ebx),%eax
f01007fe:	50                   	push   %eax
f01007ff:	e8 45 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100804:	83 c4 0c             	add    $0xc,%esp
f0100807:	c7 c0 e9 19 10 f0    	mov    $0xf01019e9,%eax
f010080d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100813:	52                   	push   %edx
f0100814:	50                   	push   %eax
f0100815:	8d 83 b8 0a ff ff    	lea    -0xf548(%ebx),%eax
f010081b:	50                   	push   %eax
f010081c:	e8 28 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100821:	83 c4 0c             	add    $0xc,%esp
f0100824:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010082a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100830:	52                   	push   %edx
f0100831:	50                   	push   %eax
f0100832:	8d 83 dc 0a ff ff    	lea    -0xf524(%ebx),%eax
f0100838:	50                   	push   %eax
f0100839:	e8 0b 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100847:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010084d:	50                   	push   %eax
f010084e:	56                   	push   %esi
f010084f:	8d 83 00 0b ff ff    	lea    -0xf500(%ebx),%eax
f0100855:	50                   	push   %eax
f0100856:	e8 ee 01 00 00       	call   f0100a49 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085b:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100864:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	c1 fe 0a             	sar    $0xa,%esi
f0100869:	56                   	push   %esi
f010086a:	8d 83 24 0b ff ff    	lea    -0xf4dc(%ebx),%eax
f0100870:	50                   	push   %eax
f0100871:	e8 d3 01 00 00       	call   f0100a49 <cprintf>
	return 0;
}
f0100876:	b8 00 00 00 00       	mov    $0x0,%eax
f010087b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087e:	5b                   	pop    %ebx
f010087f:	5e                   	pop    %esi
f0100880:	5f                   	pop    %edi
f0100881:	5d                   	pop    %ebp
f0100882:	c3                   	ret    

f0100883 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100883:	55                   	push   %ebp
f0100884:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100886:	b8 00 00 00 00       	mov    $0x0,%eax
f010088b:	5d                   	pop    %ebp
f010088c:	c3                   	ret    

f010088d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010088d:	55                   	push   %ebp
f010088e:	89 e5                	mov    %esp,%ebp
f0100890:	57                   	push   %edi
f0100891:	56                   	push   %esi
f0100892:	53                   	push   %ebx
f0100893:	83 ec 68             	sub    $0x68,%esp
f0100896:	e8 21 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010089b:	81 c3 6d 0a 01 00    	add    $0x10a6d,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008a1:	8d 83 50 0b ff ff    	lea    -0xf4b0(%ebx),%eax
f01008a7:	50                   	push   %eax
f01008a8:	e8 9c 01 00 00       	call   f0100a49 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008ad:	8d 83 74 0b ff ff    	lea    -0xf48c(%ebx),%eax
f01008b3:	89 04 24             	mov    %eax,(%esp)
f01008b6:	e8 8e 01 00 00       	call   f0100a49 <cprintf>
f01008bb:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01008be:	8d bb 0a 0a ff ff    	lea    -0xf5f6(%ebx),%edi
f01008c4:	eb 4a                	jmp    f0100910 <monitor+0x83>
f01008c6:	83 ec 08             	sub    $0x8,%esp
f01008c9:	0f be c0             	movsbl %al,%eax
f01008cc:	50                   	push   %eax
f01008cd:	57                   	push   %edi
f01008ce:	e8 99 0c 00 00       	call   f010156c <strchr>
f01008d3:	83 c4 10             	add    $0x10,%esp
f01008d6:	85 c0                	test   %eax,%eax
f01008d8:	74 08                	je     f01008e2 <monitor+0x55>
			*buf++ = 0;
f01008da:	c6 06 00             	movb   $0x0,(%esi)
f01008dd:	8d 76 01             	lea    0x1(%esi),%esi
f01008e0:	eb 79                	jmp    f010095b <monitor+0xce>
		if (*buf == 0)
f01008e2:	80 3e 00             	cmpb   $0x0,(%esi)
f01008e5:	74 7f                	je     f0100966 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f01008e7:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01008eb:	74 0f                	je     f01008fc <monitor+0x6f>
		argv[argc++] = buf;
f01008ed:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01008f0:	8d 48 01             	lea    0x1(%eax),%ecx
f01008f3:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01008f6:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01008fa:	eb 44                	jmp    f0100940 <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008fc:	83 ec 08             	sub    $0x8,%esp
f01008ff:	6a 10                	push   $0x10
f0100901:	8d 83 0f 0a ff ff    	lea    -0xf5f1(%ebx),%eax
f0100907:	50                   	push   %eax
f0100908:	e8 3c 01 00 00       	call   f0100a49 <cprintf>
f010090d:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100910:	8d 83 06 0a ff ff    	lea    -0xf5fa(%ebx),%eax
f0100916:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100919:	83 ec 0c             	sub    $0xc,%esp
f010091c:	ff 75 a4             	pushl  -0x5c(%ebp)
f010091f:	e8 10 0a 00 00       	call   f0101334 <readline>
f0100924:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100926:	83 c4 10             	add    $0x10,%esp
f0100929:	85 c0                	test   %eax,%eax
f010092b:	74 ec                	je     f0100919 <monitor+0x8c>
	argv[argc] = 0;
f010092d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100934:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f010093b:	eb 1e                	jmp    f010095b <monitor+0xce>
			buf++;
f010093d:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100940:	0f b6 06             	movzbl (%esi),%eax
f0100943:	84 c0                	test   %al,%al
f0100945:	74 14                	je     f010095b <monitor+0xce>
f0100947:	83 ec 08             	sub    $0x8,%esp
f010094a:	0f be c0             	movsbl %al,%eax
f010094d:	50                   	push   %eax
f010094e:	57                   	push   %edi
f010094f:	e8 18 0c 00 00       	call   f010156c <strchr>
f0100954:	83 c4 10             	add    $0x10,%esp
f0100957:	85 c0                	test   %eax,%eax
f0100959:	74 e2                	je     f010093d <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f010095b:	0f b6 06             	movzbl (%esi),%eax
f010095e:	84 c0                	test   %al,%al
f0100960:	0f 85 60 ff ff ff    	jne    f01008c6 <monitor+0x39>
	argv[argc] = 0;
f0100966:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100969:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100970:	00 
	if (argc == 0)
f0100971:	85 c0                	test   %eax,%eax
f0100973:	74 9b                	je     f0100910 <monitor+0x83>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100975:	83 ec 08             	sub    $0x8,%esp
f0100978:	8d 83 d6 09 ff ff    	lea    -0xf62a(%ebx),%eax
f010097e:	50                   	push   %eax
f010097f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100982:	e8 87 0b 00 00       	call   f010150e <strcmp>
f0100987:	83 c4 10             	add    $0x10,%esp
f010098a:	85 c0                	test   %eax,%eax
f010098c:	74 38                	je     f01009c6 <monitor+0x139>
f010098e:	83 ec 08             	sub    $0x8,%esp
f0100991:	8d 83 e4 09 ff ff    	lea    -0xf61c(%ebx),%eax
f0100997:	50                   	push   %eax
f0100998:	ff 75 a8             	pushl  -0x58(%ebp)
f010099b:	e8 6e 0b 00 00       	call   f010150e <strcmp>
f01009a0:	83 c4 10             	add    $0x10,%esp
f01009a3:	85 c0                	test   %eax,%eax
f01009a5:	74 1a                	je     f01009c1 <monitor+0x134>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009a7:	83 ec 08             	sub    $0x8,%esp
f01009aa:	ff 75 a8             	pushl  -0x58(%ebp)
f01009ad:	8d 83 2c 0a ff ff    	lea    -0xf5d4(%ebx),%eax
f01009b3:	50                   	push   %eax
f01009b4:	e8 90 00 00 00       	call   f0100a49 <cprintf>
f01009b9:	83 c4 10             	add    $0x10,%esp
f01009bc:	e9 4f ff ff ff       	jmp    f0100910 <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009c1:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f01009c6:	83 ec 04             	sub    $0x4,%esp
f01009c9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01009cc:	ff 75 08             	pushl  0x8(%ebp)
f01009cf:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009d2:	52                   	push   %edx
f01009d3:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009d6:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f01009dd:	83 c4 10             	add    $0x10,%esp
f01009e0:	85 c0                	test   %eax,%eax
f01009e2:	0f 89 28 ff ff ff    	jns    f0100910 <monitor+0x83>
				break;
	}
}
f01009e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009eb:	5b                   	pop    %ebx
f01009ec:	5e                   	pop    %esi
f01009ed:	5f                   	pop    %edi
f01009ee:	5d                   	pop    %ebp
f01009ef:	c3                   	ret    

f01009f0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009f0:	55                   	push   %ebp
f01009f1:	89 e5                	mov    %esp,%ebp
f01009f3:	53                   	push   %ebx
f01009f4:	83 ec 10             	sub    $0x10,%esp
f01009f7:	e8 c0 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01009fc:	81 c3 0c 09 01 00    	add    $0x1090c,%ebx
	cputchar(ch);
f0100a02:	ff 75 08             	pushl  0x8(%ebp)
f0100a05:	e8 29 fd ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100a0a:	83 c4 10             	add    $0x10,%esp
f0100a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a10:	c9                   	leave  
f0100a11:	c3                   	ret    

f0100a12 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a12:	55                   	push   %ebp
f0100a13:	89 e5                	mov    %esp,%ebp
f0100a15:	53                   	push   %ebx
f0100a16:	83 ec 14             	sub    $0x14,%esp
f0100a19:	e8 9e f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a1e:	81 c3 ea 08 01 00    	add    $0x108ea,%ebx
	int cnt = 0;
f0100a24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a2b:	ff 75 0c             	pushl  0xc(%ebp)
f0100a2e:	ff 75 08             	pushl  0x8(%ebp)
f0100a31:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a34:	50                   	push   %eax
f0100a35:	8d 83 e8 f6 fe ff    	lea    -0x10918(%ebx),%eax
f0100a3b:	50                   	push   %eax
f0100a3c:	e8 1c 04 00 00       	call   f0100e5d <vprintfmt>
	return cnt;
}
f0100a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a47:	c9                   	leave  
f0100a48:	c3                   	ret    

f0100a49 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a49:	55                   	push   %ebp
f0100a4a:	89 e5                	mov    %esp,%ebp
f0100a4c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a4f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a52:	50                   	push   %eax
f0100a53:	ff 75 08             	pushl  0x8(%ebp)
f0100a56:	e8 b7 ff ff ff       	call   f0100a12 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a5b:	c9                   	leave  
f0100a5c:	c3                   	ret    

f0100a5d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a5d:	55                   	push   %ebp
f0100a5e:	89 e5                	mov    %esp,%ebp
f0100a60:	57                   	push   %edi
f0100a61:	56                   	push   %esi
f0100a62:	53                   	push   %ebx
f0100a63:	83 ec 14             	sub    $0x14,%esp
f0100a66:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a6c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a72:	8b 32                	mov    (%edx),%esi
f0100a74:	8b 01                	mov    (%ecx),%eax
f0100a76:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a79:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a80:	eb 2f                	jmp    f0100ab1 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100a82:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100a85:	39 c6                	cmp    %eax,%esi
f0100a87:	7f 49                	jg     f0100ad2 <stab_binsearch+0x75>
f0100a89:	0f b6 0a             	movzbl (%edx),%ecx
f0100a8c:	83 ea 0c             	sub    $0xc,%edx
f0100a8f:	39 f9                	cmp    %edi,%ecx
f0100a91:	75 ef                	jne    f0100a82 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a93:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a96:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a99:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a9d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100aa0:	73 35                	jae    f0100ad7 <stab_binsearch+0x7a>
			*region_left = m;
f0100aa2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100aa5:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100aa7:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100aaa:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100ab1:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100ab4:	7f 4e                	jg     f0100b04 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ab9:	01 f0                	add    %esi,%eax
f0100abb:	89 c3                	mov    %eax,%ebx
f0100abd:	c1 eb 1f             	shr    $0x1f,%ebx
f0100ac0:	01 c3                	add    %eax,%ebx
f0100ac2:	d1 fb                	sar    %ebx
f0100ac4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ac7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100aca:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100ace:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100ad0:	eb b3                	jmp    f0100a85 <stab_binsearch+0x28>
			l = true_m + 1;
f0100ad2:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100ad5:	eb da                	jmp    f0100ab1 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100ad7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100ada:	76 14                	jbe    f0100af0 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100adc:	83 e8 01             	sub    $0x1,%eax
f0100adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ae2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100ae5:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100ae7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100aee:	eb c1                	jmp    f0100ab1 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100af0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100af3:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100af5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100af9:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100afb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b02:	eb ad                	jmp    f0100ab1 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100b04:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100b08:	74 16                	je     f0100b20 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b0d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b0f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b12:	8b 0e                	mov    (%esi),%ecx
f0100b14:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b17:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100b1a:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100b1e:	eb 12                	jmp    f0100b32 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100b20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b23:	8b 00                	mov    (%eax),%eax
f0100b25:	83 e8 01             	sub    $0x1,%eax
f0100b28:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100b2b:	89 07                	mov    %eax,(%edi)
f0100b2d:	eb 16                	jmp    f0100b45 <stab_binsearch+0xe8>
		     l--)
f0100b2f:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100b32:	39 c1                	cmp    %eax,%ecx
f0100b34:	7d 0a                	jge    f0100b40 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100b36:	0f b6 1a             	movzbl (%edx),%ebx
f0100b39:	83 ea 0c             	sub    $0xc,%edx
f0100b3c:	39 fb                	cmp    %edi,%ebx
f0100b3e:	75 ef                	jne    f0100b2f <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100b40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b43:	89 07                	mov    %eax,(%edi)
	}
}
f0100b45:	83 c4 14             	add    $0x14,%esp
f0100b48:	5b                   	pop    %ebx
f0100b49:	5e                   	pop    %esi
f0100b4a:	5f                   	pop    %edi
f0100b4b:	5d                   	pop    %ebp
f0100b4c:	c3                   	ret    

f0100b4d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b4d:	55                   	push   %ebp
f0100b4e:	89 e5                	mov    %esp,%ebp
f0100b50:	57                   	push   %edi
f0100b51:	56                   	push   %esi
f0100b52:	53                   	push   %ebx
f0100b53:	83 ec 2c             	sub    $0x2c,%esp
f0100b56:	e8 fa 01 00 00       	call   f0100d55 <__x86.get_pc_thunk.cx>
f0100b5b:	81 c1 ad 07 01 00    	add    $0x107ad,%ecx
f0100b61:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100b64:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100b67:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b6a:	8d 81 9c 0b ff ff    	lea    -0xf464(%ecx),%eax
f0100b70:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100b72:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100b79:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100b7c:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100b83:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0100b86:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b8d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0100b93:	0f 86 f4 00 00 00    	jbe    f0100c8d <debuginfo_eip+0x140>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b99:	c7 c0 55 5c 10 f0    	mov    $0xf0105c55,%eax
f0100b9f:	39 81 fc ff ff ff    	cmp    %eax,-0x4(%ecx)
f0100ba5:	0f 86 88 01 00 00    	jbe    f0100d33 <debuginfo_eip+0x1e6>
f0100bab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100bae:	c7 c0 9c 75 10 f0    	mov    $0xf010759c,%eax
f0100bb4:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100bb8:	0f 85 7c 01 00 00    	jne    f0100d3a <debuginfo_eip+0x1ed>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bbe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100bc5:	c7 c0 c0 20 10 f0    	mov    $0xf01020c0,%eax
f0100bcb:	c7 c2 54 5c 10 f0    	mov    $0xf0105c54,%edx
f0100bd1:	29 c2                	sub    %eax,%edx
f0100bd3:	c1 fa 02             	sar    $0x2,%edx
f0100bd6:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100bdc:	83 ea 01             	sub    $0x1,%edx
f0100bdf:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100be2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100be5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100be8:	83 ec 08             	sub    $0x8,%esp
f0100beb:	53                   	push   %ebx
f0100bec:	6a 64                	push   $0x64
f0100bee:	e8 6a fe ff ff       	call   f0100a5d <stab_binsearch>
	if (lfile == 0)
f0100bf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bf6:	83 c4 10             	add    $0x10,%esp
f0100bf9:	85 c0                	test   %eax,%eax
f0100bfb:	0f 84 40 01 00 00    	je     f0100d41 <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c01:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c04:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c07:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c0a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c0d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c10:	83 ec 08             	sub    $0x8,%esp
f0100c13:	53                   	push   %ebx
f0100c14:	6a 24                	push   $0x24
f0100c16:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0100c19:	c7 c0 c0 20 10 f0    	mov    $0xf01020c0,%eax
f0100c1f:	e8 39 fe ff ff       	call   f0100a5d <stab_binsearch>

	if (lfun <= rfun) {
f0100c24:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100c27:	83 c4 10             	add    $0x10,%esp
f0100c2a:	3b 75 d8             	cmp    -0x28(%ebp),%esi
f0100c2d:	7f 79                	jg     f0100ca8 <debuginfo_eip+0x15b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c2f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c32:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c35:	c7 c2 c0 20 10 f0    	mov    $0xf01020c0,%edx
f0100c3b:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100c3e:	8b 11                	mov    (%ecx),%edx
f0100c40:	c7 c0 9c 75 10 f0    	mov    $0xf010759c,%eax
f0100c46:	81 e8 55 5c 10 f0    	sub    $0xf0105c55,%eax
f0100c4c:	39 c2                	cmp    %eax,%edx
f0100c4e:	73 09                	jae    f0100c59 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c50:	81 c2 55 5c 10 f0    	add    $0xf0105c55,%edx
f0100c56:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c59:	8b 41 08             	mov    0x8(%ecx),%eax
f0100c5c:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c5f:	83 ec 08             	sub    $0x8,%esp
f0100c62:	6a 3a                	push   $0x3a
f0100c64:	ff 77 08             	pushl  0x8(%edi)
f0100c67:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c6a:	e8 1e 09 00 00       	call   f010158d <strfind>
f0100c6f:	2b 47 08             	sub    0x8(%edi),%eax
f0100c72:	89 47 0c             	mov    %eax,0xc(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c75:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100c78:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c7b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100c7e:	c7 c2 c0 20 10 f0    	mov    $0xf01020c0,%edx
f0100c84:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
f0100c88:	83 c4 10             	add    $0x10,%esp
f0100c8b:	eb 29                	jmp    f0100cb6 <debuginfo_eip+0x169>
  	        panic("User address");
f0100c8d:	83 ec 04             	sub    $0x4,%esp
f0100c90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c93:	8d 83 a6 0b ff ff    	lea    -0xf45a(%ebx),%eax
f0100c99:	50                   	push   %eax
f0100c9a:	6a 7f                	push   $0x7f
f0100c9c:	8d 83 b3 0b ff ff    	lea    -0xf44d(%ebx),%eax
f0100ca2:	50                   	push   %eax
f0100ca3:	e8 5e f4 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100ca8:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0100cab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100cae:	eb af                	jmp    f0100c5f <debuginfo_eip+0x112>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100cb0:	83 ee 01             	sub    $0x1,%esi
f0100cb3:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100cb6:	39 f3                	cmp    %esi,%ebx
f0100cb8:	7f 3a                	jg     f0100cf4 <debuginfo_eip+0x1a7>
	       && stabs[lline].n_type != N_SOL
f0100cba:	0f b6 10             	movzbl (%eax),%edx
f0100cbd:	80 fa 84             	cmp    $0x84,%dl
f0100cc0:	74 0b                	je     f0100ccd <debuginfo_eip+0x180>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100cc2:	80 fa 64             	cmp    $0x64,%dl
f0100cc5:	75 e9                	jne    f0100cb0 <debuginfo_eip+0x163>
f0100cc7:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100ccb:	74 e3                	je     f0100cb0 <debuginfo_eip+0x163>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100ccd:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100cd0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cd3:	c7 c0 c0 20 10 f0    	mov    $0xf01020c0,%eax
f0100cd9:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100cdc:	c7 c0 9c 75 10 f0    	mov    $0xf010759c,%eax
f0100ce2:	81 e8 55 5c 10 f0    	sub    $0xf0105c55,%eax
f0100ce8:	39 c2                	cmp    %eax,%edx
f0100cea:	73 08                	jae    f0100cf4 <debuginfo_eip+0x1a7>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100cec:	81 c2 55 5c 10 f0    	add    $0xf0105c55,%edx
f0100cf2:	89 17                	mov    %edx,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cf4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100cf7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cfa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100cff:	39 cb                	cmp    %ecx,%ebx
f0100d01:	7d 4a                	jge    f0100d4d <debuginfo_eip+0x200>
		for (lline = lfun + 1;
f0100d03:	8d 53 01             	lea    0x1(%ebx),%edx
f0100d06:	8d 1c 5b             	lea    (%ebx,%ebx,2),%ebx
f0100d09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d0c:	c7 c0 c0 20 10 f0    	mov    $0xf01020c0,%eax
f0100d12:	8d 44 98 10          	lea    0x10(%eax,%ebx,4),%eax
f0100d16:	eb 07                	jmp    f0100d1f <debuginfo_eip+0x1d2>
			info->eip_fn_narg++;
f0100d18:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100d1c:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0100d1f:	39 d1                	cmp    %edx,%ecx
f0100d21:	74 25                	je     f0100d48 <debuginfo_eip+0x1fb>
f0100d23:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d26:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100d2a:	74 ec                	je     f0100d18 <debuginfo_eip+0x1cb>
	return 0;
f0100d2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d31:	eb 1a                	jmp    f0100d4d <debuginfo_eip+0x200>
		return -1;
f0100d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d38:	eb 13                	jmp    f0100d4d <debuginfo_eip+0x200>
f0100d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d3f:	eb 0c                	jmp    f0100d4d <debuginfo_eip+0x200>
		return -1;
f0100d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d46:	eb 05                	jmp    f0100d4d <debuginfo_eip+0x200>
	return 0;
f0100d48:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d50:	5b                   	pop    %ebx
f0100d51:	5e                   	pop    %esi
f0100d52:	5f                   	pop    %edi
f0100d53:	5d                   	pop    %ebp
f0100d54:	c3                   	ret    

f0100d55 <__x86.get_pc_thunk.cx>:
f0100d55:	8b 0c 24             	mov    (%esp),%ecx
f0100d58:	c3                   	ret    

f0100d59 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d59:	55                   	push   %ebp
f0100d5a:	89 e5                	mov    %esp,%ebp
f0100d5c:	57                   	push   %edi
f0100d5d:	56                   	push   %esi
f0100d5e:	53                   	push   %ebx
f0100d5f:	83 ec 2c             	sub    $0x2c,%esp
f0100d62:	e8 ee ff ff ff       	call   f0100d55 <__x86.get_pc_thunk.cx>
f0100d67:	81 c1 a1 05 01 00    	add    $0x105a1,%ecx
f0100d6d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100d70:	89 c7                	mov    %eax,%edi
f0100d72:	89 d6                	mov    %edx,%esi
f0100d74:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d77:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d7d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d80:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100d83:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d88:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100d8b:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100d8e:	39 d3                	cmp    %edx,%ebx
f0100d90:	72 09                	jb     f0100d9b <printnum+0x42>
f0100d92:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d95:	0f 87 83 00 00 00    	ja     f0100e1e <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d9b:	83 ec 0c             	sub    $0xc,%esp
f0100d9e:	ff 75 18             	pushl  0x18(%ebp)
f0100da1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100da4:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100da7:	53                   	push   %ebx
f0100da8:	ff 75 10             	pushl  0x10(%ebp)
f0100dab:	83 ec 08             	sub    $0x8,%esp
f0100dae:	ff 75 dc             	pushl  -0x24(%ebp)
f0100db1:	ff 75 d8             	pushl  -0x28(%ebp)
f0100db4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100db7:	ff 75 d0             	pushl  -0x30(%ebp)
f0100dba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100dbd:	e8 ee 09 00 00       	call   f01017b0 <__udivdi3>
f0100dc2:	83 c4 18             	add    $0x18,%esp
f0100dc5:	52                   	push   %edx
f0100dc6:	50                   	push   %eax
f0100dc7:	89 f2                	mov    %esi,%edx
f0100dc9:	89 f8                	mov    %edi,%eax
f0100dcb:	e8 89 ff ff ff       	call   f0100d59 <printnum>
f0100dd0:	83 c4 20             	add    $0x20,%esp
f0100dd3:	eb 13                	jmp    f0100de8 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100dd5:	83 ec 08             	sub    $0x8,%esp
f0100dd8:	56                   	push   %esi
f0100dd9:	ff 75 18             	pushl  0x18(%ebp)
f0100ddc:	ff d7                	call   *%edi
f0100dde:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100de1:	83 eb 01             	sub    $0x1,%ebx
f0100de4:	85 db                	test   %ebx,%ebx
f0100de6:	7f ed                	jg     f0100dd5 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100de8:	83 ec 08             	sub    $0x8,%esp
f0100deb:	56                   	push   %esi
f0100dec:	83 ec 04             	sub    $0x4,%esp
f0100def:	ff 75 dc             	pushl  -0x24(%ebp)
f0100df2:	ff 75 d8             	pushl  -0x28(%ebp)
f0100df5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100df8:	ff 75 d0             	pushl  -0x30(%ebp)
f0100dfb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100dfe:	89 f3                	mov    %esi,%ebx
f0100e00:	e8 cb 0a 00 00       	call   f01018d0 <__umoddi3>
f0100e05:	83 c4 14             	add    $0x14,%esp
f0100e08:	0f be 84 06 c1 0b ff 	movsbl -0xf43f(%esi,%eax,1),%eax
f0100e0f:	ff 
f0100e10:	50                   	push   %eax
f0100e11:	ff d7                	call   *%edi
}
f0100e13:	83 c4 10             	add    $0x10,%esp
f0100e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e19:	5b                   	pop    %ebx
f0100e1a:	5e                   	pop    %esi
f0100e1b:	5f                   	pop    %edi
f0100e1c:	5d                   	pop    %ebp
f0100e1d:	c3                   	ret    
f0100e1e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100e21:	eb be                	jmp    f0100de1 <printnum+0x88>

f0100e23 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e23:	55                   	push   %ebp
f0100e24:	89 e5                	mov    %esp,%ebp
f0100e26:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e29:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e2d:	8b 10                	mov    (%eax),%edx
f0100e2f:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e32:	73 0a                	jae    f0100e3e <sprintputch+0x1b>
		*b->buf++ = ch;
f0100e34:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e37:	89 08                	mov    %ecx,(%eax)
f0100e39:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e3c:	88 02                	mov    %al,(%edx)
}
f0100e3e:	5d                   	pop    %ebp
f0100e3f:	c3                   	ret    

f0100e40 <printfmt>:
{
f0100e40:	55                   	push   %ebp
f0100e41:	89 e5                	mov    %esp,%ebp
f0100e43:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100e46:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e49:	50                   	push   %eax
f0100e4a:	ff 75 10             	pushl  0x10(%ebp)
f0100e4d:	ff 75 0c             	pushl  0xc(%ebp)
f0100e50:	ff 75 08             	pushl  0x8(%ebp)
f0100e53:	e8 05 00 00 00       	call   f0100e5d <vprintfmt>
}
f0100e58:	83 c4 10             	add    $0x10,%esp
f0100e5b:	c9                   	leave  
f0100e5c:	c3                   	ret    

f0100e5d <vprintfmt>:
{
f0100e5d:	55                   	push   %ebp
f0100e5e:	89 e5                	mov    %esp,%ebp
f0100e60:	57                   	push   %edi
f0100e61:	56                   	push   %esi
f0100e62:	53                   	push   %ebx
f0100e63:	83 ec 2c             	sub    $0x2c,%esp
f0100e66:	e8 51 f3 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100e6b:	81 c3 9d 04 01 00    	add    $0x1049d,%ebx
f0100e71:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e74:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e77:	e9 8e 03 00 00       	jmp    f010120a <.L35+0x48>
		padc = ' ';
f0100e7c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100e80:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100e87:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0100e8e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100e95:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e9a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100e9d:	8d 47 01             	lea    0x1(%edi),%eax
f0100ea0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ea3:	0f b6 17             	movzbl (%edi),%edx
f0100ea6:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100ea9:	3c 55                	cmp    $0x55,%al
f0100eab:	0f 87 e1 03 00 00    	ja     f0101292 <.L22>
f0100eb1:	0f b6 c0             	movzbl %al,%eax
f0100eb4:	89 d9                	mov    %ebx,%ecx
f0100eb6:	03 8c 83 50 0c ff ff 	add    -0xf3b0(%ebx,%eax,4),%ecx
f0100ebd:	ff e1                	jmp    *%ecx

f0100ebf <.L67>:
f0100ebf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100ec2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100ec6:	eb d5                	jmp    f0100e9d <vprintfmt+0x40>

f0100ec8 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0100ec8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100ecb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100ecf:	eb cc                	jmp    f0100e9d <vprintfmt+0x40>

f0100ed1 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0100ed1:	0f b6 d2             	movzbl %dl,%edx
f0100ed4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100ed7:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0100edc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100edf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100ee3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100ee6:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100ee9:	83 f9 09             	cmp    $0x9,%ecx
f0100eec:	77 55                	ja     f0100f43 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0100eee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0100ef1:	eb e9                	jmp    f0100edc <.L29+0xb>

f0100ef3 <.L26>:
			precision = va_arg(ap, int);
f0100ef3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef6:	8b 00                	mov    (%eax),%eax
f0100ef8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100efb:	8b 45 14             	mov    0x14(%ebp),%eax
f0100efe:	8d 40 04             	lea    0x4(%eax),%eax
f0100f01:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100f07:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f0b:	79 90                	jns    f0100e9d <vprintfmt+0x40>
				width = precision, precision = -1;
f0100f0d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f10:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f13:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100f1a:	eb 81                	jmp    f0100e9d <vprintfmt+0x40>

f0100f1c <.L27>:
f0100f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f1f:	85 c0                	test   %eax,%eax
f0100f21:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f26:	0f 49 d0             	cmovns %eax,%edx
f0100f29:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f2f:	e9 69 ff ff ff       	jmp    f0100e9d <vprintfmt+0x40>

f0100f34 <.L23>:
f0100f34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100f37:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100f3e:	e9 5a ff ff ff       	jmp    f0100e9d <vprintfmt+0x40>
f0100f43:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f46:	eb bf                	jmp    f0100f07 <.L26+0x14>

f0100f48 <.L33>:
			lflag++;
f0100f48:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100f4f:	e9 49 ff ff ff       	jmp    f0100e9d <vprintfmt+0x40>

f0100f54 <.L30>:
			putch(va_arg(ap, int), putdat);
f0100f54:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f57:	8d 78 04             	lea    0x4(%eax),%edi
f0100f5a:	83 ec 08             	sub    $0x8,%esp
f0100f5d:	56                   	push   %esi
f0100f5e:	ff 30                	pushl  (%eax)
f0100f60:	ff 55 08             	call   *0x8(%ebp)
			break;
f0100f63:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100f66:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100f69:	e9 99 02 00 00       	jmp    f0101207 <.L35+0x45>

f0100f6e <.L32>:
			err = va_arg(ap, int);
f0100f6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f71:	8d 78 04             	lea    0x4(%eax),%edi
f0100f74:	8b 00                	mov    (%eax),%eax
f0100f76:	99                   	cltd   
f0100f77:	31 d0                	xor    %edx,%eax
f0100f79:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f7b:	83 f8 06             	cmp    $0x6,%eax
f0100f7e:	7f 27                	jg     f0100fa7 <.L32+0x39>
f0100f80:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f0100f87:	85 d2                	test   %edx,%edx
f0100f89:	74 1c                	je     f0100fa7 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0100f8b:	52                   	push   %edx
f0100f8c:	8d 83 e2 0b ff ff    	lea    -0xf41e(%ebx),%eax
f0100f92:	50                   	push   %eax
f0100f93:	56                   	push   %esi
f0100f94:	ff 75 08             	pushl  0x8(%ebp)
f0100f97:	e8 a4 fe ff ff       	call   f0100e40 <printfmt>
f0100f9c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100f9f:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100fa2:	e9 60 02 00 00       	jmp    f0101207 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0100fa7:	50                   	push   %eax
f0100fa8:	8d 83 d9 0b ff ff    	lea    -0xf427(%ebx),%eax
f0100fae:	50                   	push   %eax
f0100faf:	56                   	push   %esi
f0100fb0:	ff 75 08             	pushl  0x8(%ebp)
f0100fb3:	e8 88 fe ff ff       	call   f0100e40 <printfmt>
f0100fb8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100fbb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100fbe:	e9 44 02 00 00       	jmp    f0101207 <.L35+0x45>

f0100fc3 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0100fc3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fc6:	83 c0 04             	add    $0x4,%eax
f0100fc9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100fcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fcf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100fd1:	85 ff                	test   %edi,%edi
f0100fd3:	8d 83 d2 0b ff ff    	lea    -0xf42e(%ebx),%eax
f0100fd9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100fdc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100fe0:	0f 8e b5 00 00 00    	jle    f010109b <.L36+0xd8>
f0100fe6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100fea:	75 08                	jne    f0100ff4 <.L36+0x31>
f0100fec:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100fef:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ff2:	eb 6d                	jmp    f0101061 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ff4:	83 ec 08             	sub    $0x8,%esp
f0100ff7:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ffa:	57                   	push   %edi
f0100ffb:	e8 49 04 00 00       	call   f0101449 <strnlen>
f0101000:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101003:	29 c2                	sub    %eax,%edx
f0101005:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0101008:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010100b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010100f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101012:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101015:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101017:	eb 10                	jmp    f0101029 <.L36+0x66>
					putch(padc, putdat);
f0101019:	83 ec 08             	sub    $0x8,%esp
f010101c:	56                   	push   %esi
f010101d:	ff 75 e0             	pushl  -0x20(%ebp)
f0101020:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101023:	83 ef 01             	sub    $0x1,%edi
f0101026:	83 c4 10             	add    $0x10,%esp
f0101029:	85 ff                	test   %edi,%edi
f010102b:	7f ec                	jg     f0101019 <.L36+0x56>
f010102d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101030:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101033:	85 d2                	test   %edx,%edx
f0101035:	b8 00 00 00 00       	mov    $0x0,%eax
f010103a:	0f 49 c2             	cmovns %edx,%eax
f010103d:	29 c2                	sub    %eax,%edx
f010103f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101042:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101045:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101048:	eb 17                	jmp    f0101061 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f010104a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010104e:	75 30                	jne    f0101080 <.L36+0xbd>
					putch(ch, putdat);
f0101050:	83 ec 08             	sub    $0x8,%esp
f0101053:	ff 75 0c             	pushl  0xc(%ebp)
f0101056:	50                   	push   %eax
f0101057:	ff 55 08             	call   *0x8(%ebp)
f010105a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010105d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0101061:	83 c7 01             	add    $0x1,%edi
f0101064:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0101068:	0f be c2             	movsbl %dl,%eax
f010106b:	85 c0                	test   %eax,%eax
f010106d:	74 52                	je     f01010c1 <.L36+0xfe>
f010106f:	85 f6                	test   %esi,%esi
f0101071:	78 d7                	js     f010104a <.L36+0x87>
f0101073:	83 ee 01             	sub    $0x1,%esi
f0101076:	79 d2                	jns    f010104a <.L36+0x87>
f0101078:	8b 75 0c             	mov    0xc(%ebp),%esi
f010107b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010107e:	eb 32                	jmp    f01010b2 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0101080:	0f be d2             	movsbl %dl,%edx
f0101083:	83 ea 20             	sub    $0x20,%edx
f0101086:	83 fa 5e             	cmp    $0x5e,%edx
f0101089:	76 c5                	jbe    f0101050 <.L36+0x8d>
					putch('?', putdat);
f010108b:	83 ec 08             	sub    $0x8,%esp
f010108e:	ff 75 0c             	pushl  0xc(%ebp)
f0101091:	6a 3f                	push   $0x3f
f0101093:	ff 55 08             	call   *0x8(%ebp)
f0101096:	83 c4 10             	add    $0x10,%esp
f0101099:	eb c2                	jmp    f010105d <.L36+0x9a>
f010109b:	89 75 0c             	mov    %esi,0xc(%ebp)
f010109e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01010a1:	eb be                	jmp    f0101061 <.L36+0x9e>
				putch(' ', putdat);
f01010a3:	83 ec 08             	sub    $0x8,%esp
f01010a6:	56                   	push   %esi
f01010a7:	6a 20                	push   $0x20
f01010a9:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01010ac:	83 ef 01             	sub    $0x1,%edi
f01010af:	83 c4 10             	add    $0x10,%esp
f01010b2:	85 ff                	test   %edi,%edi
f01010b4:	7f ed                	jg     f01010a3 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01010b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01010b9:	89 45 14             	mov    %eax,0x14(%ebp)
f01010bc:	e9 46 01 00 00       	jmp    f0101207 <.L35+0x45>
f01010c1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01010c4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01010c7:	eb e9                	jmp    f01010b2 <.L36+0xef>

f01010c9 <.L31>:
f01010c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
f01010cc:	83 f9 01             	cmp    $0x1,%ecx
f01010cf:	7e 40                	jle    f0101111 <.L31+0x48>
		return va_arg(*ap, long long);
f01010d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d4:	8b 50 04             	mov    0x4(%eax),%edx
f01010d7:	8b 00                	mov    (%eax),%eax
f01010d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010df:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e2:	8d 40 08             	lea    0x8(%eax),%eax
f01010e5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01010e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010ec:	79 55                	jns    f0101143 <.L31+0x7a>
				putch('-', putdat);
f01010ee:	83 ec 08             	sub    $0x8,%esp
f01010f1:	56                   	push   %esi
f01010f2:	6a 2d                	push   $0x2d
f01010f4:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01010f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01010fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01010fd:	f7 da                	neg    %edx
f01010ff:	83 d1 00             	adc    $0x0,%ecx
f0101102:	f7 d9                	neg    %ecx
f0101104:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101107:	b8 0a 00 00 00       	mov    $0xa,%eax
f010110c:	e9 db 00 00 00       	jmp    f01011ec <.L35+0x2a>
	else if (lflag)
f0101111:	85 c9                	test   %ecx,%ecx
f0101113:	75 17                	jne    f010112c <.L31+0x63>
		return va_arg(*ap, int);
f0101115:	8b 45 14             	mov    0x14(%ebp),%eax
f0101118:	8b 00                	mov    (%eax),%eax
f010111a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010111d:	99                   	cltd   
f010111e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101121:	8b 45 14             	mov    0x14(%ebp),%eax
f0101124:	8d 40 04             	lea    0x4(%eax),%eax
f0101127:	89 45 14             	mov    %eax,0x14(%ebp)
f010112a:	eb bc                	jmp    f01010e8 <.L31+0x1f>
		return va_arg(*ap, long);
f010112c:	8b 45 14             	mov    0x14(%ebp),%eax
f010112f:	8b 00                	mov    (%eax),%eax
f0101131:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101134:	99                   	cltd   
f0101135:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101138:	8b 45 14             	mov    0x14(%ebp),%eax
f010113b:	8d 40 04             	lea    0x4(%eax),%eax
f010113e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101141:	eb a5                	jmp    f01010e8 <.L31+0x1f>
			num = getint(&ap, lflag);
f0101143:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101146:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101149:	b8 0a 00 00 00       	mov    $0xa,%eax
f010114e:	e9 99 00 00 00       	jmp    f01011ec <.L35+0x2a>

f0101153 <.L37>:
f0101153:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
f0101156:	83 f9 01             	cmp    $0x1,%ecx
f0101159:	7e 15                	jle    f0101170 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
f010115b:	8b 45 14             	mov    0x14(%ebp),%eax
f010115e:	8b 10                	mov    (%eax),%edx
f0101160:	8b 48 04             	mov    0x4(%eax),%ecx
f0101163:	8d 40 08             	lea    0x8(%eax),%eax
f0101166:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101169:	b8 0a 00 00 00       	mov    $0xa,%eax
f010116e:	eb 7c                	jmp    f01011ec <.L35+0x2a>
	else if (lflag)
f0101170:	85 c9                	test   %ecx,%ecx
f0101172:	75 17                	jne    f010118b <.L37+0x38>
		return va_arg(*ap, unsigned int);
f0101174:	8b 45 14             	mov    0x14(%ebp),%eax
f0101177:	8b 10                	mov    (%eax),%edx
f0101179:	b9 00 00 00 00       	mov    $0x0,%ecx
f010117e:	8d 40 04             	lea    0x4(%eax),%eax
f0101181:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101184:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101189:	eb 61                	jmp    f01011ec <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010118b:	8b 45 14             	mov    0x14(%ebp),%eax
f010118e:	8b 10                	mov    (%eax),%edx
f0101190:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101195:	8d 40 04             	lea    0x4(%eax),%eax
f0101198:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010119b:	b8 0a 00 00 00       	mov    $0xa,%eax
f01011a0:	eb 4a                	jmp    f01011ec <.L35+0x2a>

f01011a2 <.L34>:
			putch('X', putdat);
f01011a2:	83 ec 08             	sub    $0x8,%esp
f01011a5:	56                   	push   %esi
f01011a6:	6a 58                	push   $0x58
f01011a8:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01011ab:	83 c4 08             	add    $0x8,%esp
f01011ae:	56                   	push   %esi
f01011af:	6a 58                	push   $0x58
f01011b1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01011b4:	83 c4 08             	add    $0x8,%esp
f01011b7:	56                   	push   %esi
f01011b8:	6a 58                	push   $0x58
f01011ba:	ff 55 08             	call   *0x8(%ebp)
			break;
f01011bd:	83 c4 10             	add    $0x10,%esp
f01011c0:	eb 45                	jmp    f0101207 <.L35+0x45>

f01011c2 <.L35>:
			putch('0', putdat);
f01011c2:	83 ec 08             	sub    $0x8,%esp
f01011c5:	56                   	push   %esi
f01011c6:	6a 30                	push   $0x30
f01011c8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01011cb:	83 c4 08             	add    $0x8,%esp
f01011ce:	56                   	push   %esi
f01011cf:	6a 78                	push   $0x78
f01011d1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01011d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01011d7:	8b 10                	mov    (%eax),%edx
f01011d9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01011de:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01011e1:	8d 40 04             	lea    0x4(%eax),%eax
f01011e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011e7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01011ec:	83 ec 0c             	sub    $0xc,%esp
f01011ef:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01011f3:	57                   	push   %edi
f01011f4:	ff 75 e0             	pushl  -0x20(%ebp)
f01011f7:	50                   	push   %eax
f01011f8:	51                   	push   %ecx
f01011f9:	52                   	push   %edx
f01011fa:	89 f2                	mov    %esi,%edx
f01011fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ff:	e8 55 fb ff ff       	call   f0100d59 <printnum>
			break;
f0101204:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101207:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010120a:	83 c7 01             	add    $0x1,%edi
f010120d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101211:	83 f8 25             	cmp    $0x25,%eax
f0101214:	0f 84 62 fc ff ff    	je     f0100e7c <vprintfmt+0x1f>
			if (ch == '\0')
f010121a:	85 c0                	test   %eax,%eax
f010121c:	0f 84 91 00 00 00    	je     f01012b3 <.L22+0x21>
			putch(ch, putdat);
f0101222:	83 ec 08             	sub    $0x8,%esp
f0101225:	56                   	push   %esi
f0101226:	50                   	push   %eax
f0101227:	ff 55 08             	call   *0x8(%ebp)
f010122a:	83 c4 10             	add    $0x10,%esp
f010122d:	eb db                	jmp    f010120a <.L35+0x48>

f010122f <.L38>:
f010122f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
	if (lflag >= 2)
f0101232:	83 f9 01             	cmp    $0x1,%ecx
f0101235:	7e 15                	jle    f010124c <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0101237:	8b 45 14             	mov    0x14(%ebp),%eax
f010123a:	8b 10                	mov    (%eax),%edx
f010123c:	8b 48 04             	mov    0x4(%eax),%ecx
f010123f:	8d 40 08             	lea    0x8(%eax),%eax
f0101242:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101245:	b8 10 00 00 00       	mov    $0x10,%eax
f010124a:	eb a0                	jmp    f01011ec <.L35+0x2a>
	else if (lflag)
f010124c:	85 c9                	test   %ecx,%ecx
f010124e:	75 17                	jne    f0101267 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f0101250:	8b 45 14             	mov    0x14(%ebp),%eax
f0101253:	8b 10                	mov    (%eax),%edx
f0101255:	b9 00 00 00 00       	mov    $0x0,%ecx
f010125a:	8d 40 04             	lea    0x4(%eax),%eax
f010125d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101260:	b8 10 00 00 00       	mov    $0x10,%eax
f0101265:	eb 85                	jmp    f01011ec <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0101267:	8b 45 14             	mov    0x14(%ebp),%eax
f010126a:	8b 10                	mov    (%eax),%edx
f010126c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101271:	8d 40 04             	lea    0x4(%eax),%eax
f0101274:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101277:	b8 10 00 00 00       	mov    $0x10,%eax
f010127c:	e9 6b ff ff ff       	jmp    f01011ec <.L35+0x2a>

f0101281 <.L25>:
			putch(ch, putdat);
f0101281:	83 ec 08             	sub    $0x8,%esp
f0101284:	56                   	push   %esi
f0101285:	6a 25                	push   $0x25
f0101287:	ff 55 08             	call   *0x8(%ebp)
			break;
f010128a:	83 c4 10             	add    $0x10,%esp
f010128d:	e9 75 ff ff ff       	jmp    f0101207 <.L35+0x45>

f0101292 <.L22>:
			putch('%', putdat);
f0101292:	83 ec 08             	sub    $0x8,%esp
f0101295:	56                   	push   %esi
f0101296:	6a 25                	push   $0x25
f0101298:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010129b:	83 c4 10             	add    $0x10,%esp
f010129e:	89 f8                	mov    %edi,%eax
f01012a0:	eb 03                	jmp    f01012a5 <.L22+0x13>
f01012a2:	83 e8 01             	sub    $0x1,%eax
f01012a5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01012a9:	75 f7                	jne    f01012a2 <.L22+0x10>
f01012ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012ae:	e9 54 ff ff ff       	jmp    f0101207 <.L35+0x45>
}
f01012b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012b6:	5b                   	pop    %ebx
f01012b7:	5e                   	pop    %esi
f01012b8:	5f                   	pop    %edi
f01012b9:	5d                   	pop    %ebp
f01012ba:	c3                   	ret    

f01012bb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01012bb:	55                   	push   %ebp
f01012bc:	89 e5                	mov    %esp,%ebp
f01012be:	53                   	push   %ebx
f01012bf:	83 ec 14             	sub    $0x14,%esp
f01012c2:	e8 f5 ee ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01012c7:	81 c3 41 00 01 00    	add    $0x10041,%ebx
f01012cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01012d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01012d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01012d6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01012da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01012dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01012e4:	85 c0                	test   %eax,%eax
f01012e6:	74 2b                	je     f0101313 <vsnprintf+0x58>
f01012e8:	85 d2                	test   %edx,%edx
f01012ea:	7e 27                	jle    f0101313 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01012ec:	ff 75 14             	pushl  0x14(%ebp)
f01012ef:	ff 75 10             	pushl  0x10(%ebp)
f01012f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01012f5:	50                   	push   %eax
f01012f6:	8d 83 1b fb fe ff    	lea    -0x104e5(%ebx),%eax
f01012fc:	50                   	push   %eax
f01012fd:	e8 5b fb ff ff       	call   f0100e5d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101302:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101305:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101308:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010130b:	83 c4 10             	add    $0x10,%esp
}
f010130e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101311:	c9                   	leave  
f0101312:	c3                   	ret    
		return -E_INVAL;
f0101313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101318:	eb f4                	jmp    f010130e <vsnprintf+0x53>

f010131a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010131a:	55                   	push   %ebp
f010131b:	89 e5                	mov    %esp,%ebp
f010131d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101320:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101323:	50                   	push   %eax
f0101324:	ff 75 10             	pushl  0x10(%ebp)
f0101327:	ff 75 0c             	pushl  0xc(%ebp)
f010132a:	ff 75 08             	pushl  0x8(%ebp)
f010132d:	e8 89 ff ff ff       	call   f01012bb <vsnprintf>
	va_end(ap);

	return rc;
}
f0101332:	c9                   	leave  
f0101333:	c3                   	ret    

f0101334 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101334:	55                   	push   %ebp
f0101335:	89 e5                	mov    %esp,%ebp
f0101337:	57                   	push   %edi
f0101338:	56                   	push   %esi
f0101339:	53                   	push   %ebx
f010133a:	83 ec 1c             	sub    $0x1c,%esp
f010133d:	e8 7a ee ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101342:	81 c3 c6 ff 00 00    	add    $0xffc6,%ebx
f0101348:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010134b:	85 c0                	test   %eax,%eax
f010134d:	74 13                	je     f0101362 <readline+0x2e>
		cprintf("%s", prompt);
f010134f:	83 ec 08             	sub    $0x8,%esp
f0101352:	50                   	push   %eax
f0101353:	8d 83 e2 0b ff ff    	lea    -0xf41e(%ebx),%eax
f0101359:	50                   	push   %eax
f010135a:	e8 ea f6 ff ff       	call   f0100a49 <cprintf>
f010135f:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101362:	83 ec 0c             	sub    $0xc,%esp
f0101365:	6a 00                	push   $0x0
f0101367:	e8 e8 f3 ff ff       	call   f0100754 <iscons>
f010136c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010136f:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101372:	bf 00 00 00 00       	mov    $0x0,%edi
f0101377:	eb 46                	jmp    f01013bf <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101379:	83 ec 08             	sub    $0x8,%esp
f010137c:	50                   	push   %eax
f010137d:	8d 83 a8 0d ff ff    	lea    -0xf258(%ebx),%eax
f0101383:	50                   	push   %eax
f0101384:	e8 c0 f6 ff ff       	call   f0100a49 <cprintf>
			return NULL;
f0101389:	83 c4 10             	add    $0x10,%esp
f010138c:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101391:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101394:	5b                   	pop    %ebx
f0101395:	5e                   	pop    %esi
f0101396:	5f                   	pop    %edi
f0101397:	5d                   	pop    %ebp
f0101398:	c3                   	ret    
			if (echoing)
f0101399:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010139d:	75 05                	jne    f01013a4 <readline+0x70>
			i--;
f010139f:	83 ef 01             	sub    $0x1,%edi
f01013a2:	eb 1b                	jmp    f01013bf <readline+0x8b>
				cputchar('\b');
f01013a4:	83 ec 0c             	sub    $0xc,%esp
f01013a7:	6a 08                	push   $0x8
f01013a9:	e8 85 f3 ff ff       	call   f0100733 <cputchar>
f01013ae:	83 c4 10             	add    $0x10,%esp
f01013b1:	eb ec                	jmp    f010139f <readline+0x6b>
			buf[i++] = c;
f01013b3:	89 f0                	mov    %esi,%eax
f01013b5:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f01013bc:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01013bf:	e8 7f f3 ff ff       	call   f0100743 <getchar>
f01013c4:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01013c6:	85 c0                	test   %eax,%eax
f01013c8:	78 af                	js     f0101379 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01013ca:	83 f8 08             	cmp    $0x8,%eax
f01013cd:	0f 94 c2             	sete   %dl
f01013d0:	83 f8 7f             	cmp    $0x7f,%eax
f01013d3:	0f 94 c0             	sete   %al
f01013d6:	08 c2                	or     %al,%dl
f01013d8:	74 04                	je     f01013de <readline+0xaa>
f01013da:	85 ff                	test   %edi,%edi
f01013dc:	7f bb                	jg     f0101399 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01013de:	83 fe 1f             	cmp    $0x1f,%esi
f01013e1:	7e 1c                	jle    f01013ff <readline+0xcb>
f01013e3:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01013e9:	7f 14                	jg     f01013ff <readline+0xcb>
			if (echoing)
f01013eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01013ef:	74 c2                	je     f01013b3 <readline+0x7f>
				cputchar(c);
f01013f1:	83 ec 0c             	sub    $0xc,%esp
f01013f4:	56                   	push   %esi
f01013f5:	e8 39 f3 ff ff       	call   f0100733 <cputchar>
f01013fa:	83 c4 10             	add    $0x10,%esp
f01013fd:	eb b4                	jmp    f01013b3 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01013ff:	83 fe 0a             	cmp    $0xa,%esi
f0101402:	74 05                	je     f0101409 <readline+0xd5>
f0101404:	83 fe 0d             	cmp    $0xd,%esi
f0101407:	75 b6                	jne    f01013bf <readline+0x8b>
			if (echoing)
f0101409:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010140d:	75 13                	jne    f0101422 <readline+0xee>
			buf[i] = 0;
f010140f:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f0101416:	00 
			return buf;
f0101417:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f010141d:	e9 6f ff ff ff       	jmp    f0101391 <readline+0x5d>
				cputchar('\n');
f0101422:	83 ec 0c             	sub    $0xc,%esp
f0101425:	6a 0a                	push   $0xa
f0101427:	e8 07 f3 ff ff       	call   f0100733 <cputchar>
f010142c:	83 c4 10             	add    $0x10,%esp
f010142f:	eb de                	jmp    f010140f <readline+0xdb>

f0101431 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101431:	55                   	push   %ebp
f0101432:	89 e5                	mov    %esp,%ebp
f0101434:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101437:	b8 00 00 00 00       	mov    $0x0,%eax
f010143c:	eb 03                	jmp    f0101441 <strlen+0x10>
		n++;
f010143e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0101441:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101445:	75 f7                	jne    f010143e <strlen+0xd>
	return n;
}
f0101447:	5d                   	pop    %ebp
f0101448:	c3                   	ret    

f0101449 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101449:	55                   	push   %ebp
f010144a:	89 e5                	mov    %esp,%ebp
f010144c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010144f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101452:	b8 00 00 00 00       	mov    $0x0,%eax
f0101457:	eb 03                	jmp    f010145c <strnlen+0x13>
		n++;
f0101459:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010145c:	39 d0                	cmp    %edx,%eax
f010145e:	74 06                	je     f0101466 <strnlen+0x1d>
f0101460:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101464:	75 f3                	jne    f0101459 <strnlen+0x10>
	return n;
}
f0101466:	5d                   	pop    %ebp
f0101467:	c3                   	ret    

f0101468 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101468:	55                   	push   %ebp
f0101469:	89 e5                	mov    %esp,%ebp
f010146b:	53                   	push   %ebx
f010146c:	8b 45 08             	mov    0x8(%ebp),%eax
f010146f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101472:	89 c2                	mov    %eax,%edx
f0101474:	83 c1 01             	add    $0x1,%ecx
f0101477:	83 c2 01             	add    $0x1,%edx
f010147a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010147e:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101481:	84 db                	test   %bl,%bl
f0101483:	75 ef                	jne    f0101474 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101485:	5b                   	pop    %ebx
f0101486:	5d                   	pop    %ebp
f0101487:	c3                   	ret    

f0101488 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101488:	55                   	push   %ebp
f0101489:	89 e5                	mov    %esp,%ebp
f010148b:	53                   	push   %ebx
f010148c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010148f:	53                   	push   %ebx
f0101490:	e8 9c ff ff ff       	call   f0101431 <strlen>
f0101495:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101498:	ff 75 0c             	pushl  0xc(%ebp)
f010149b:	01 d8                	add    %ebx,%eax
f010149d:	50                   	push   %eax
f010149e:	e8 c5 ff ff ff       	call   f0101468 <strcpy>
	return dst;
}
f01014a3:	89 d8                	mov    %ebx,%eax
f01014a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014a8:	c9                   	leave  
f01014a9:	c3                   	ret    

f01014aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01014aa:	55                   	push   %ebp
f01014ab:	89 e5                	mov    %esp,%ebp
f01014ad:	56                   	push   %esi
f01014ae:	53                   	push   %ebx
f01014af:	8b 75 08             	mov    0x8(%ebp),%esi
f01014b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014b5:	89 f3                	mov    %esi,%ebx
f01014b7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014ba:	89 f2                	mov    %esi,%edx
f01014bc:	eb 0f                	jmp    f01014cd <strncpy+0x23>
		*dst++ = *src;
f01014be:	83 c2 01             	add    $0x1,%edx
f01014c1:	0f b6 01             	movzbl (%ecx),%eax
f01014c4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01014c7:	80 39 01             	cmpb   $0x1,(%ecx)
f01014ca:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f01014cd:	39 da                	cmp    %ebx,%edx
f01014cf:	75 ed                	jne    f01014be <strncpy+0x14>
	}
	return ret;
}
f01014d1:	89 f0                	mov    %esi,%eax
f01014d3:	5b                   	pop    %ebx
f01014d4:	5e                   	pop    %esi
f01014d5:	5d                   	pop    %ebp
f01014d6:	c3                   	ret    

f01014d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01014d7:	55                   	push   %ebp
f01014d8:	89 e5                	mov    %esp,%ebp
f01014da:	56                   	push   %esi
f01014db:	53                   	push   %ebx
f01014dc:	8b 75 08             	mov    0x8(%ebp),%esi
f01014df:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01014e5:	89 f0                	mov    %esi,%eax
f01014e7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01014eb:	85 c9                	test   %ecx,%ecx
f01014ed:	75 0b                	jne    f01014fa <strlcpy+0x23>
f01014ef:	eb 17                	jmp    f0101508 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01014f1:	83 c2 01             	add    $0x1,%edx
f01014f4:	83 c0 01             	add    $0x1,%eax
f01014f7:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01014fa:	39 d8                	cmp    %ebx,%eax
f01014fc:	74 07                	je     f0101505 <strlcpy+0x2e>
f01014fe:	0f b6 0a             	movzbl (%edx),%ecx
f0101501:	84 c9                	test   %cl,%cl
f0101503:	75 ec                	jne    f01014f1 <strlcpy+0x1a>
		*dst = '\0';
f0101505:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101508:	29 f0                	sub    %esi,%eax
}
f010150a:	5b                   	pop    %ebx
f010150b:	5e                   	pop    %esi
f010150c:	5d                   	pop    %ebp
f010150d:	c3                   	ret    

f010150e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010150e:	55                   	push   %ebp
f010150f:	89 e5                	mov    %esp,%ebp
f0101511:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101514:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101517:	eb 06                	jmp    f010151f <strcmp+0x11>
		p++, q++;
f0101519:	83 c1 01             	add    $0x1,%ecx
f010151c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010151f:	0f b6 01             	movzbl (%ecx),%eax
f0101522:	84 c0                	test   %al,%al
f0101524:	74 04                	je     f010152a <strcmp+0x1c>
f0101526:	3a 02                	cmp    (%edx),%al
f0101528:	74 ef                	je     f0101519 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010152a:	0f b6 c0             	movzbl %al,%eax
f010152d:	0f b6 12             	movzbl (%edx),%edx
f0101530:	29 d0                	sub    %edx,%eax
}
f0101532:	5d                   	pop    %ebp
f0101533:	c3                   	ret    

f0101534 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101534:	55                   	push   %ebp
f0101535:	89 e5                	mov    %esp,%ebp
f0101537:	53                   	push   %ebx
f0101538:	8b 45 08             	mov    0x8(%ebp),%eax
f010153b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010153e:	89 c3                	mov    %eax,%ebx
f0101540:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101543:	eb 06                	jmp    f010154b <strncmp+0x17>
		n--, p++, q++;
f0101545:	83 c0 01             	add    $0x1,%eax
f0101548:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010154b:	39 d8                	cmp    %ebx,%eax
f010154d:	74 16                	je     f0101565 <strncmp+0x31>
f010154f:	0f b6 08             	movzbl (%eax),%ecx
f0101552:	84 c9                	test   %cl,%cl
f0101554:	74 04                	je     f010155a <strncmp+0x26>
f0101556:	3a 0a                	cmp    (%edx),%cl
f0101558:	74 eb                	je     f0101545 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010155a:	0f b6 00             	movzbl (%eax),%eax
f010155d:	0f b6 12             	movzbl (%edx),%edx
f0101560:	29 d0                	sub    %edx,%eax
}
f0101562:	5b                   	pop    %ebx
f0101563:	5d                   	pop    %ebp
f0101564:	c3                   	ret    
		return 0;
f0101565:	b8 00 00 00 00       	mov    $0x0,%eax
f010156a:	eb f6                	jmp    f0101562 <strncmp+0x2e>

f010156c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010156c:	55                   	push   %ebp
f010156d:	89 e5                	mov    %esp,%ebp
f010156f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101572:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101576:	0f b6 10             	movzbl (%eax),%edx
f0101579:	84 d2                	test   %dl,%dl
f010157b:	74 09                	je     f0101586 <strchr+0x1a>
		if (*s == c)
f010157d:	38 ca                	cmp    %cl,%dl
f010157f:	74 0a                	je     f010158b <strchr+0x1f>
	for (; *s; s++)
f0101581:	83 c0 01             	add    $0x1,%eax
f0101584:	eb f0                	jmp    f0101576 <strchr+0xa>
			return (char *) s;
	return 0;
f0101586:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010158b:	5d                   	pop    %ebp
f010158c:	c3                   	ret    

f010158d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010158d:	55                   	push   %ebp
f010158e:	89 e5                	mov    %esp,%ebp
f0101590:	8b 45 08             	mov    0x8(%ebp),%eax
f0101593:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101597:	eb 03                	jmp    f010159c <strfind+0xf>
f0101599:	83 c0 01             	add    $0x1,%eax
f010159c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010159f:	38 ca                	cmp    %cl,%dl
f01015a1:	74 04                	je     f01015a7 <strfind+0x1a>
f01015a3:	84 d2                	test   %dl,%dl
f01015a5:	75 f2                	jne    f0101599 <strfind+0xc>
			break;
	return (char *) s;
}
f01015a7:	5d                   	pop    %ebp
f01015a8:	c3                   	ret    

f01015a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01015a9:	55                   	push   %ebp
f01015aa:	89 e5                	mov    %esp,%ebp
f01015ac:	57                   	push   %edi
f01015ad:	56                   	push   %esi
f01015ae:	53                   	push   %ebx
f01015af:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01015b5:	85 c9                	test   %ecx,%ecx
f01015b7:	74 13                	je     f01015cc <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01015b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01015bf:	75 05                	jne    f01015c6 <memset+0x1d>
f01015c1:	f6 c1 03             	test   $0x3,%cl
f01015c4:	74 0d                	je     f01015d3 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01015c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015c9:	fc                   	cld    
f01015ca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01015cc:	89 f8                	mov    %edi,%eax
f01015ce:	5b                   	pop    %ebx
f01015cf:	5e                   	pop    %esi
f01015d0:	5f                   	pop    %edi
f01015d1:	5d                   	pop    %ebp
f01015d2:	c3                   	ret    
		c &= 0xFF;
f01015d3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01015d7:	89 d3                	mov    %edx,%ebx
f01015d9:	c1 e3 08             	shl    $0x8,%ebx
f01015dc:	89 d0                	mov    %edx,%eax
f01015de:	c1 e0 18             	shl    $0x18,%eax
f01015e1:	89 d6                	mov    %edx,%esi
f01015e3:	c1 e6 10             	shl    $0x10,%esi
f01015e6:	09 f0                	or     %esi,%eax
f01015e8:	09 c2                	or     %eax,%edx
f01015ea:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01015ec:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01015ef:	89 d0                	mov    %edx,%eax
f01015f1:	fc                   	cld    
f01015f2:	f3 ab                	rep stos %eax,%es:(%edi)
f01015f4:	eb d6                	jmp    f01015cc <memset+0x23>

f01015f6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01015f6:	55                   	push   %ebp
f01015f7:	89 e5                	mov    %esp,%ebp
f01015f9:	57                   	push   %edi
f01015fa:	56                   	push   %esi
f01015fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01015fe:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101601:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101604:	39 c6                	cmp    %eax,%esi
f0101606:	73 35                	jae    f010163d <memmove+0x47>
f0101608:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010160b:	39 c2                	cmp    %eax,%edx
f010160d:	76 2e                	jbe    f010163d <memmove+0x47>
		s += n;
		d += n;
f010160f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101612:	89 d6                	mov    %edx,%esi
f0101614:	09 fe                	or     %edi,%esi
f0101616:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010161c:	74 0c                	je     f010162a <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010161e:	83 ef 01             	sub    $0x1,%edi
f0101621:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101624:	fd                   	std    
f0101625:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101627:	fc                   	cld    
f0101628:	eb 21                	jmp    f010164b <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010162a:	f6 c1 03             	test   $0x3,%cl
f010162d:	75 ef                	jne    f010161e <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010162f:	83 ef 04             	sub    $0x4,%edi
f0101632:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101635:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101638:	fd                   	std    
f0101639:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010163b:	eb ea                	jmp    f0101627 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010163d:	89 f2                	mov    %esi,%edx
f010163f:	09 c2                	or     %eax,%edx
f0101641:	f6 c2 03             	test   $0x3,%dl
f0101644:	74 09                	je     f010164f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101646:	89 c7                	mov    %eax,%edi
f0101648:	fc                   	cld    
f0101649:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010164b:	5e                   	pop    %esi
f010164c:	5f                   	pop    %edi
f010164d:	5d                   	pop    %ebp
f010164e:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010164f:	f6 c1 03             	test   $0x3,%cl
f0101652:	75 f2                	jne    f0101646 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101654:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101657:	89 c7                	mov    %eax,%edi
f0101659:	fc                   	cld    
f010165a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010165c:	eb ed                	jmp    f010164b <memmove+0x55>

f010165e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010165e:	55                   	push   %ebp
f010165f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101661:	ff 75 10             	pushl  0x10(%ebp)
f0101664:	ff 75 0c             	pushl  0xc(%ebp)
f0101667:	ff 75 08             	pushl  0x8(%ebp)
f010166a:	e8 87 ff ff ff       	call   f01015f6 <memmove>
}
f010166f:	c9                   	leave  
f0101670:	c3                   	ret    

f0101671 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101671:	55                   	push   %ebp
f0101672:	89 e5                	mov    %esp,%ebp
f0101674:	56                   	push   %esi
f0101675:	53                   	push   %ebx
f0101676:	8b 45 08             	mov    0x8(%ebp),%eax
f0101679:	8b 55 0c             	mov    0xc(%ebp),%edx
f010167c:	89 c6                	mov    %eax,%esi
f010167e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101681:	39 f0                	cmp    %esi,%eax
f0101683:	74 1c                	je     f01016a1 <memcmp+0x30>
		if (*s1 != *s2)
f0101685:	0f b6 08             	movzbl (%eax),%ecx
f0101688:	0f b6 1a             	movzbl (%edx),%ebx
f010168b:	38 d9                	cmp    %bl,%cl
f010168d:	75 08                	jne    f0101697 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010168f:	83 c0 01             	add    $0x1,%eax
f0101692:	83 c2 01             	add    $0x1,%edx
f0101695:	eb ea                	jmp    f0101681 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101697:	0f b6 c1             	movzbl %cl,%eax
f010169a:	0f b6 db             	movzbl %bl,%ebx
f010169d:	29 d8                	sub    %ebx,%eax
f010169f:	eb 05                	jmp    f01016a6 <memcmp+0x35>
	}

	return 0;
f01016a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016a6:	5b                   	pop    %ebx
f01016a7:	5e                   	pop    %esi
f01016a8:	5d                   	pop    %ebp
f01016a9:	c3                   	ret    

f01016aa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01016aa:	55                   	push   %ebp
f01016ab:	89 e5                	mov    %esp,%ebp
f01016ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01016b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01016b3:	89 c2                	mov    %eax,%edx
f01016b5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01016b8:	39 d0                	cmp    %edx,%eax
f01016ba:	73 09                	jae    f01016c5 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01016bc:	38 08                	cmp    %cl,(%eax)
f01016be:	74 05                	je     f01016c5 <memfind+0x1b>
	for (; s < ends; s++)
f01016c0:	83 c0 01             	add    $0x1,%eax
f01016c3:	eb f3                	jmp    f01016b8 <memfind+0xe>
			break;
	return (void *) s;
}
f01016c5:	5d                   	pop    %ebp
f01016c6:	c3                   	ret    

f01016c7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01016c7:	55                   	push   %ebp
f01016c8:	89 e5                	mov    %esp,%ebp
f01016ca:	57                   	push   %edi
f01016cb:	56                   	push   %esi
f01016cc:	53                   	push   %ebx
f01016cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01016d3:	eb 03                	jmp    f01016d8 <strtol+0x11>
		s++;
f01016d5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01016d8:	0f b6 01             	movzbl (%ecx),%eax
f01016db:	3c 20                	cmp    $0x20,%al
f01016dd:	74 f6                	je     f01016d5 <strtol+0xe>
f01016df:	3c 09                	cmp    $0x9,%al
f01016e1:	74 f2                	je     f01016d5 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01016e3:	3c 2b                	cmp    $0x2b,%al
f01016e5:	74 2e                	je     f0101715 <strtol+0x4e>
	int neg = 0;
f01016e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01016ec:	3c 2d                	cmp    $0x2d,%al
f01016ee:	74 2f                	je     f010171f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01016f0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01016f6:	75 05                	jne    f01016fd <strtol+0x36>
f01016f8:	80 39 30             	cmpb   $0x30,(%ecx)
f01016fb:	74 2c                	je     f0101729 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01016fd:	85 db                	test   %ebx,%ebx
f01016ff:	75 0a                	jne    f010170b <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101701:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0101706:	80 39 30             	cmpb   $0x30,(%ecx)
f0101709:	74 28                	je     f0101733 <strtol+0x6c>
		base = 10;
f010170b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101710:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101713:	eb 50                	jmp    f0101765 <strtol+0x9e>
		s++;
f0101715:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101718:	bf 00 00 00 00       	mov    $0x0,%edi
f010171d:	eb d1                	jmp    f01016f0 <strtol+0x29>
		s++, neg = 1;
f010171f:	83 c1 01             	add    $0x1,%ecx
f0101722:	bf 01 00 00 00       	mov    $0x1,%edi
f0101727:	eb c7                	jmp    f01016f0 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101729:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010172d:	74 0e                	je     f010173d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010172f:	85 db                	test   %ebx,%ebx
f0101731:	75 d8                	jne    f010170b <strtol+0x44>
		s++, base = 8;
f0101733:	83 c1 01             	add    $0x1,%ecx
f0101736:	bb 08 00 00 00       	mov    $0x8,%ebx
f010173b:	eb ce                	jmp    f010170b <strtol+0x44>
		s += 2, base = 16;
f010173d:	83 c1 02             	add    $0x2,%ecx
f0101740:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101745:	eb c4                	jmp    f010170b <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101747:	8d 72 9f             	lea    -0x61(%edx),%esi
f010174a:	89 f3                	mov    %esi,%ebx
f010174c:	80 fb 19             	cmp    $0x19,%bl
f010174f:	77 29                	ja     f010177a <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101751:	0f be d2             	movsbl %dl,%edx
f0101754:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101757:	3b 55 10             	cmp    0x10(%ebp),%edx
f010175a:	7d 30                	jge    f010178c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010175c:	83 c1 01             	add    $0x1,%ecx
f010175f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101763:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101765:	0f b6 11             	movzbl (%ecx),%edx
f0101768:	8d 72 d0             	lea    -0x30(%edx),%esi
f010176b:	89 f3                	mov    %esi,%ebx
f010176d:	80 fb 09             	cmp    $0x9,%bl
f0101770:	77 d5                	ja     f0101747 <strtol+0x80>
			dig = *s - '0';
f0101772:	0f be d2             	movsbl %dl,%edx
f0101775:	83 ea 30             	sub    $0x30,%edx
f0101778:	eb dd                	jmp    f0101757 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f010177a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010177d:	89 f3                	mov    %esi,%ebx
f010177f:	80 fb 19             	cmp    $0x19,%bl
f0101782:	77 08                	ja     f010178c <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101784:	0f be d2             	movsbl %dl,%edx
f0101787:	83 ea 37             	sub    $0x37,%edx
f010178a:	eb cb                	jmp    f0101757 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010178c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101790:	74 05                	je     f0101797 <strtol+0xd0>
		*endptr = (char *) s;
f0101792:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101795:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101797:	89 c2                	mov    %eax,%edx
f0101799:	f7 da                	neg    %edx
f010179b:	85 ff                	test   %edi,%edi
f010179d:	0f 45 c2             	cmovne %edx,%eax
}
f01017a0:	5b                   	pop    %ebx
f01017a1:	5e                   	pop    %esi
f01017a2:	5f                   	pop    %edi
f01017a3:	5d                   	pop    %ebp
f01017a4:	c3                   	ret    
f01017a5:	66 90                	xchg   %ax,%ax
f01017a7:	66 90                	xchg   %ax,%ax
f01017a9:	66 90                	xchg   %ax,%ax
f01017ab:	66 90                	xchg   %ax,%ax
f01017ad:	66 90                	xchg   %ax,%ax
f01017af:	90                   	nop

f01017b0 <__udivdi3>:
f01017b0:	55                   	push   %ebp
f01017b1:	57                   	push   %edi
f01017b2:	56                   	push   %esi
f01017b3:	53                   	push   %ebx
f01017b4:	83 ec 1c             	sub    $0x1c,%esp
f01017b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01017bb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01017bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017c3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01017c7:	85 d2                	test   %edx,%edx
f01017c9:	75 35                	jne    f0101800 <__udivdi3+0x50>
f01017cb:	39 f3                	cmp    %esi,%ebx
f01017cd:	0f 87 bd 00 00 00    	ja     f0101890 <__udivdi3+0xe0>
f01017d3:	85 db                	test   %ebx,%ebx
f01017d5:	89 d9                	mov    %ebx,%ecx
f01017d7:	75 0b                	jne    f01017e4 <__udivdi3+0x34>
f01017d9:	b8 01 00 00 00       	mov    $0x1,%eax
f01017de:	31 d2                	xor    %edx,%edx
f01017e0:	f7 f3                	div    %ebx
f01017e2:	89 c1                	mov    %eax,%ecx
f01017e4:	31 d2                	xor    %edx,%edx
f01017e6:	89 f0                	mov    %esi,%eax
f01017e8:	f7 f1                	div    %ecx
f01017ea:	89 c6                	mov    %eax,%esi
f01017ec:	89 e8                	mov    %ebp,%eax
f01017ee:	89 f7                	mov    %esi,%edi
f01017f0:	f7 f1                	div    %ecx
f01017f2:	89 fa                	mov    %edi,%edx
f01017f4:	83 c4 1c             	add    $0x1c,%esp
f01017f7:	5b                   	pop    %ebx
f01017f8:	5e                   	pop    %esi
f01017f9:	5f                   	pop    %edi
f01017fa:	5d                   	pop    %ebp
f01017fb:	c3                   	ret    
f01017fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101800:	39 f2                	cmp    %esi,%edx
f0101802:	77 7c                	ja     f0101880 <__udivdi3+0xd0>
f0101804:	0f bd fa             	bsr    %edx,%edi
f0101807:	83 f7 1f             	xor    $0x1f,%edi
f010180a:	0f 84 98 00 00 00    	je     f01018a8 <__udivdi3+0xf8>
f0101810:	89 f9                	mov    %edi,%ecx
f0101812:	b8 20 00 00 00       	mov    $0x20,%eax
f0101817:	29 f8                	sub    %edi,%eax
f0101819:	d3 e2                	shl    %cl,%edx
f010181b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010181f:	89 c1                	mov    %eax,%ecx
f0101821:	89 da                	mov    %ebx,%edx
f0101823:	d3 ea                	shr    %cl,%edx
f0101825:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101829:	09 d1                	or     %edx,%ecx
f010182b:	89 f2                	mov    %esi,%edx
f010182d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101831:	89 f9                	mov    %edi,%ecx
f0101833:	d3 e3                	shl    %cl,%ebx
f0101835:	89 c1                	mov    %eax,%ecx
f0101837:	d3 ea                	shr    %cl,%edx
f0101839:	89 f9                	mov    %edi,%ecx
f010183b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010183f:	d3 e6                	shl    %cl,%esi
f0101841:	89 eb                	mov    %ebp,%ebx
f0101843:	89 c1                	mov    %eax,%ecx
f0101845:	d3 eb                	shr    %cl,%ebx
f0101847:	09 de                	or     %ebx,%esi
f0101849:	89 f0                	mov    %esi,%eax
f010184b:	f7 74 24 08          	divl   0x8(%esp)
f010184f:	89 d6                	mov    %edx,%esi
f0101851:	89 c3                	mov    %eax,%ebx
f0101853:	f7 64 24 0c          	mull   0xc(%esp)
f0101857:	39 d6                	cmp    %edx,%esi
f0101859:	72 0c                	jb     f0101867 <__udivdi3+0xb7>
f010185b:	89 f9                	mov    %edi,%ecx
f010185d:	d3 e5                	shl    %cl,%ebp
f010185f:	39 c5                	cmp    %eax,%ebp
f0101861:	73 5d                	jae    f01018c0 <__udivdi3+0x110>
f0101863:	39 d6                	cmp    %edx,%esi
f0101865:	75 59                	jne    f01018c0 <__udivdi3+0x110>
f0101867:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010186a:	31 ff                	xor    %edi,%edi
f010186c:	89 fa                	mov    %edi,%edx
f010186e:	83 c4 1c             	add    $0x1c,%esp
f0101871:	5b                   	pop    %ebx
f0101872:	5e                   	pop    %esi
f0101873:	5f                   	pop    %edi
f0101874:	5d                   	pop    %ebp
f0101875:	c3                   	ret    
f0101876:	8d 76 00             	lea    0x0(%esi),%esi
f0101879:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101880:	31 ff                	xor    %edi,%edi
f0101882:	31 c0                	xor    %eax,%eax
f0101884:	89 fa                	mov    %edi,%edx
f0101886:	83 c4 1c             	add    $0x1c,%esp
f0101889:	5b                   	pop    %ebx
f010188a:	5e                   	pop    %esi
f010188b:	5f                   	pop    %edi
f010188c:	5d                   	pop    %ebp
f010188d:	c3                   	ret    
f010188e:	66 90                	xchg   %ax,%ax
f0101890:	31 ff                	xor    %edi,%edi
f0101892:	89 e8                	mov    %ebp,%eax
f0101894:	89 f2                	mov    %esi,%edx
f0101896:	f7 f3                	div    %ebx
f0101898:	89 fa                	mov    %edi,%edx
f010189a:	83 c4 1c             	add    $0x1c,%esp
f010189d:	5b                   	pop    %ebx
f010189e:	5e                   	pop    %esi
f010189f:	5f                   	pop    %edi
f01018a0:	5d                   	pop    %ebp
f01018a1:	c3                   	ret    
f01018a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018a8:	39 f2                	cmp    %esi,%edx
f01018aa:	72 06                	jb     f01018b2 <__udivdi3+0x102>
f01018ac:	31 c0                	xor    %eax,%eax
f01018ae:	39 eb                	cmp    %ebp,%ebx
f01018b0:	77 d2                	ja     f0101884 <__udivdi3+0xd4>
f01018b2:	b8 01 00 00 00       	mov    $0x1,%eax
f01018b7:	eb cb                	jmp    f0101884 <__udivdi3+0xd4>
f01018b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018c0:	89 d8                	mov    %ebx,%eax
f01018c2:	31 ff                	xor    %edi,%edi
f01018c4:	eb be                	jmp    f0101884 <__udivdi3+0xd4>
f01018c6:	66 90                	xchg   %ax,%ax
f01018c8:	66 90                	xchg   %ax,%ax
f01018ca:	66 90                	xchg   %ax,%ax
f01018cc:	66 90                	xchg   %ax,%ax
f01018ce:	66 90                	xchg   %ax,%ax

f01018d0 <__umoddi3>:
f01018d0:	55                   	push   %ebp
f01018d1:	57                   	push   %edi
f01018d2:	56                   	push   %esi
f01018d3:	53                   	push   %ebx
f01018d4:	83 ec 1c             	sub    $0x1c,%esp
f01018d7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01018db:	8b 74 24 30          	mov    0x30(%esp),%esi
f01018df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01018e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01018e7:	85 ed                	test   %ebp,%ebp
f01018e9:	89 f0                	mov    %esi,%eax
f01018eb:	89 da                	mov    %ebx,%edx
f01018ed:	75 19                	jne    f0101908 <__umoddi3+0x38>
f01018ef:	39 df                	cmp    %ebx,%edi
f01018f1:	0f 86 b1 00 00 00    	jbe    f01019a8 <__umoddi3+0xd8>
f01018f7:	f7 f7                	div    %edi
f01018f9:	89 d0                	mov    %edx,%eax
f01018fb:	31 d2                	xor    %edx,%edx
f01018fd:	83 c4 1c             	add    $0x1c,%esp
f0101900:	5b                   	pop    %ebx
f0101901:	5e                   	pop    %esi
f0101902:	5f                   	pop    %edi
f0101903:	5d                   	pop    %ebp
f0101904:	c3                   	ret    
f0101905:	8d 76 00             	lea    0x0(%esi),%esi
f0101908:	39 dd                	cmp    %ebx,%ebp
f010190a:	77 f1                	ja     f01018fd <__umoddi3+0x2d>
f010190c:	0f bd cd             	bsr    %ebp,%ecx
f010190f:	83 f1 1f             	xor    $0x1f,%ecx
f0101912:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101916:	0f 84 b4 00 00 00    	je     f01019d0 <__umoddi3+0x100>
f010191c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101921:	89 c2                	mov    %eax,%edx
f0101923:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101927:	29 c2                	sub    %eax,%edx
f0101929:	89 c1                	mov    %eax,%ecx
f010192b:	89 f8                	mov    %edi,%eax
f010192d:	d3 e5                	shl    %cl,%ebp
f010192f:	89 d1                	mov    %edx,%ecx
f0101931:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101935:	d3 e8                	shr    %cl,%eax
f0101937:	09 c5                	or     %eax,%ebp
f0101939:	8b 44 24 04          	mov    0x4(%esp),%eax
f010193d:	89 c1                	mov    %eax,%ecx
f010193f:	d3 e7                	shl    %cl,%edi
f0101941:	89 d1                	mov    %edx,%ecx
f0101943:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101947:	89 df                	mov    %ebx,%edi
f0101949:	d3 ef                	shr    %cl,%edi
f010194b:	89 c1                	mov    %eax,%ecx
f010194d:	89 f0                	mov    %esi,%eax
f010194f:	d3 e3                	shl    %cl,%ebx
f0101951:	89 d1                	mov    %edx,%ecx
f0101953:	89 fa                	mov    %edi,%edx
f0101955:	d3 e8                	shr    %cl,%eax
f0101957:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010195c:	09 d8                	or     %ebx,%eax
f010195e:	f7 f5                	div    %ebp
f0101960:	d3 e6                	shl    %cl,%esi
f0101962:	89 d1                	mov    %edx,%ecx
f0101964:	f7 64 24 08          	mull   0x8(%esp)
f0101968:	39 d1                	cmp    %edx,%ecx
f010196a:	89 c3                	mov    %eax,%ebx
f010196c:	89 d7                	mov    %edx,%edi
f010196e:	72 06                	jb     f0101976 <__umoddi3+0xa6>
f0101970:	75 0e                	jne    f0101980 <__umoddi3+0xb0>
f0101972:	39 c6                	cmp    %eax,%esi
f0101974:	73 0a                	jae    f0101980 <__umoddi3+0xb0>
f0101976:	2b 44 24 08          	sub    0x8(%esp),%eax
f010197a:	19 ea                	sbb    %ebp,%edx
f010197c:	89 d7                	mov    %edx,%edi
f010197e:	89 c3                	mov    %eax,%ebx
f0101980:	89 ca                	mov    %ecx,%edx
f0101982:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101987:	29 de                	sub    %ebx,%esi
f0101989:	19 fa                	sbb    %edi,%edx
f010198b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010198f:	89 d0                	mov    %edx,%eax
f0101991:	d3 e0                	shl    %cl,%eax
f0101993:	89 d9                	mov    %ebx,%ecx
f0101995:	d3 ee                	shr    %cl,%esi
f0101997:	d3 ea                	shr    %cl,%edx
f0101999:	09 f0                	or     %esi,%eax
f010199b:	83 c4 1c             	add    $0x1c,%esp
f010199e:	5b                   	pop    %ebx
f010199f:	5e                   	pop    %esi
f01019a0:	5f                   	pop    %edi
f01019a1:	5d                   	pop    %ebp
f01019a2:	c3                   	ret    
f01019a3:	90                   	nop
f01019a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019a8:	85 ff                	test   %edi,%edi
f01019aa:	89 f9                	mov    %edi,%ecx
f01019ac:	75 0b                	jne    f01019b9 <__umoddi3+0xe9>
f01019ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01019b3:	31 d2                	xor    %edx,%edx
f01019b5:	f7 f7                	div    %edi
f01019b7:	89 c1                	mov    %eax,%ecx
f01019b9:	89 d8                	mov    %ebx,%eax
f01019bb:	31 d2                	xor    %edx,%edx
f01019bd:	f7 f1                	div    %ecx
f01019bf:	89 f0                	mov    %esi,%eax
f01019c1:	f7 f1                	div    %ecx
f01019c3:	e9 31 ff ff ff       	jmp    f01018f9 <__umoddi3+0x29>
f01019c8:	90                   	nop
f01019c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01019d0:	39 dd                	cmp    %ebx,%ebp
f01019d2:	72 08                	jb     f01019dc <__umoddi3+0x10c>
f01019d4:	39 f7                	cmp    %esi,%edi
f01019d6:	0f 87 21 ff ff ff    	ja     f01018fd <__umoddi3+0x2d>
f01019dc:	89 da                	mov    %ebx,%edx
f01019de:	89 f0                	mov    %esi,%eax
f01019e0:	29 f8                	sub    %edi,%eax
f01019e2:	19 ea                	sbb    %ebp,%edx
f01019e4:	e9 14 ff ff ff       	jmp    f01018fd <__umoddi3+0x2d>
