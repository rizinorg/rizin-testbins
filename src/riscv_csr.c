/*
 * riscv_csr_all.c  —  RISC-V CSR Complete Exercise File
 * Privileged Spec v20240411, all standard registers.
 *
 * SECTIONS
 *   1  Raw CSR instruction macros (all 8 forms)
 *   2  Function-generating macros
DEMO_RO /
DEMO_ALL_FORMS
 *   3  CSR address #defines with DWARF register numbers
 *   4  csr_ro_<n>()  — 3 read-safe instruction forms per register
 *   5  csr_rw_<n>()  — all 8 instruction forms per register
 *   6  main() — calls every RO then every RW function
 *
 * INSTRUCTION FORMS
 *   csrrs  rd, csr, x0   (1) pure read        (rs1=x0  → write suppressed)
 *   csrrsi rd, csr, 0    (2) set-imm 0        (imm=0   → write suppressed)
 *   csrrci rd, csr, 0    (3) clear-imm 0      (imm=0   → write suppressed)
 *   csrrw  x0, csr, rs1  (4) write, discard old value
 *   csrrw  rd, csr, rs1  (5) atomic swap: read old, write new
 *   csrrs  rd, csr, rs1  (6) atomic read + set bits
 *   csrrc  rd, csr, rs1  (7) atomic read + clear bits
 *   csrrwi x0, csr, 0    (8) write immediate 0
 *
 * FUNCTION NAMING
 *   csr_ro_<name>()  — forms 1,2,3 only  (safe on read-only CSRs at runtime)
 *   csr_rw_<name>()  — all 8 forms       (will fault on read-only CSRs)
 *
 * DWARF register number = 4096 + CSR address (decimal)
 *   mstatus 0x300 → DWARF 4864 | cycle 0xC00 → DWARF 7168
 *
 * COMPILE
 *   riscv64-unknown-elf-gcc -march=rv64gcv_zicsr -O0 -g \
 *       riscv_csr_all.c -o riscv_csr_all.elf
 *
 * DISASSEMBLE
 *   objdump -d riscv_csr_all.elf | grep -A12 "<csr_ro_cycle>"
 *   objdump -d riscv_csr_all.elf | grep -A30 "<csr_rw_mstatus>"
 *
 * RUNTIME NOTE
 *   Will fault if executed from a privilege level that cannot access a given
 *   CSR. The RW functions also fault on genuinely read-only CSRs. Both are
 *   expected — the file is intended for disassembly inspection only.
 */

#include <stdint.h>

/* =========================================================================
 * Section 1 — Raw CSR instruction macros
 * ========================================================================= */

/* csrrs rd, csr, x0 — pure read, write suppressed because rs1=x0 */
#define csr_read(csr) \
	({ \
		unsigned long __v; \
		__asm__ volatile("csrrs %0, " #csr ", x0" : "=r"(__v)::); \
		__v; \
	})

/* csrrw x0, csr, rs1 — write, discard old value */
#define csr_write(csr, val) \
	do { \
		unsigned long __v = (unsigned long)(val); \
		__asm__ volatile("csrrw x0, " #csr ", %0" ::"rK"(__v) :); \
	} while (0)

/* csrrw rd, csr, rs1 — atomic swap: read old, write new */
#define csr_swap(csr, val) \
	({ \
		unsigned long __v = (unsigned long)(val); \
		__asm__ volatile("csrrw %0, " #csr ", %1" : "=r"(__v) : "rK"(__v) :); \
		__v; \
	})

/* csrrs rd, csr, rs1 — atomic read + set bits in mask */
#define csr_set_bits(csr, mask) \
	({ \
		unsigned long __v = (unsigned long)(mask); \
		__asm__ volatile("csrrs %0, " #csr ", %1" : "=r"(__v) : "rK"(__v) :); \
		__v; \
	})

/* csrrc rd, csr, rs1 — atomic read + clear bits in mask */
#define csr_clear_bits(csr, mask) \
	({ \
		unsigned long __v = (unsigned long)(mask); \
		__asm__ volatile("csrrc %0, " #csr ", %1" : "=r"(__v) : "rK"(__v) :); \
		__v; \
	})

/* csrrwi x0, csr, uimm5 — write immediate [0..31], discard old */
#define csr_write_imm(csr, imm) \
	do { \
		__asm__ volatile("csrrwi x0, " #csr ", " #imm :::); \
	} while (0)

/* csrrsi rd, csr, uimm5 — set bits immediate, return old value */
#define csr_set_imm(csr, imm) \
	({ \
		unsigned long __v; \
		__asm__ volatile("csrrsi %0, " #csr ", " #imm : "=r"(__v)::); \
		__v; \
	})

/* csrrci rd, csr, uimm5 — clear bits immediate, return old value */
#define csr_clear_imm(csr, imm) \
	({ \
		unsigned long __v; \
		__asm__ volatile("csrrci %0, " #csr ", " #imm : "=r"(__v)::); \
		__v; \
	})

/* Volatile sink — prevents reads from being optimised away */
volatile unsigned long __csr_sink;

/* =========================================================================
 * Section 2 — Function-generating macros
 *
 *
DEMO_RO(name)       → void csr_ro_<name>(void)   3 read-safe forms
 *
DEMO_ALL_FORMS(name)→ void csr_rw_<name>(void)   all 8 forms
 *
 * __attribute__((noinline)) guarantees a distinct symbol in the binary
 * at any optimisation level, making each function directly addressable
 * in a disassembler (objdump/gdb: disas csr_rw_mstatus).
 *
 * All write values are 0:
 *   - WARL fields: 0 is always legal
 *   - WPRI fields: writes are silently ignored
 *   - Read-only CSRs: will raise illegal-instruction at runtime (expected)
 * ========================================================================= */

#define DEMO_RO(name) \
	__attribute__((noinline)) void csr_ro_##name(void) { \
		unsigned long _v; \
		_v = csr_read(name); /* csrrs  rd, name, x0  */ \
		_v = csr_set_imm(name, 0); /* csrrsi rd, name, 0   */ \
		_v = csr_clear_imm(name, 0); /* csrrci rd, name, 0   */ \
		__csr_sink = _v; \
	}

#define DEMO_ALL_FORMS(name) \
	__attribute__((noinline)) void csr_rw_##name(void) { \
		unsigned long _v; \
		_v = csr_read(name); /* csrrs  rd, name, x0  */ \
		_v = csr_set_imm(name, 0); /* csrrsi rd, name, 0   */ \
		_v = csr_clear_imm(name, 0); /* csrrci rd, name, 0   */ \
		csr_write(name, _v); /* csrrw  x0, name, rs1 */ \
		_v = csr_swap(name, 0UL); /* csrrw  rd, name, rs1 */ \
		_v = csr_set_bits(name, 0UL); /* csrrs  rd, name, rs1 */ \
		_v = csr_clear_bits(name, 0UL); /* csrrc  rd, name, rs1 */ \
		csr_write_imm(name, 0); /* csrrwi x0, name, 0   */ \
		__csr_sink = _v; \
	}

/* =========================================================================
 * Section 3 — CSR address symbolic constants
 * Source: RISC-V Privileged Spec v20240411, Tables 4–8
 * DWARF number = 4096 + decimal(address)
 * ========================================================================= */

/* Unprivileged Floating-Point */
#define CSR_FFLAGS 0x001 /* DWARF 4097 */
#define CSR_FRM    0x002 /* DWARF 4098 */
#define CSR_FCSR   0x003 /* DWARF 4099 */
/* Unprivileged Counter/Timer read-only shadows */
#define CSR_CYCLE        0xC00 /* DWARF 7168 */
#define CSR_TIME         0xC01
#define CSR_INSTRET      0xC02
#define CSR_HPMCOUNTER3  0xC03
#define CSR_HPMCOUNTER4  0xC04
#define CSR_HPMCOUNTER5  0xC05
#define CSR_HPMCOUNTER6  0xC06
#define CSR_HPMCOUNTER7  0xC07
#define CSR_HPMCOUNTER8  0xC08
#define CSR_HPMCOUNTER9  0xC09
#define CSR_HPMCOUNTER10 0xC0A
#define CSR_HPMCOUNTER11 0xC0B
#define CSR_HPMCOUNTER12 0xC0C
#define CSR_HPMCOUNTER13 0xC0D
#define CSR_HPMCOUNTER14 0xC0E
#define CSR_HPMCOUNTER15 0xC0F
#define CSR_HPMCOUNTER16 0xC10
#define CSR_HPMCOUNTER17 0xC11
#define CSR_HPMCOUNTER18 0xC12
#define CSR_HPMCOUNTER19 0xC13
#define CSR_HPMCOUNTER20 0xC14
#define CSR_HPMCOUNTER21 0xC15
#define CSR_HPMCOUNTER22 0xC16
#define CSR_HPMCOUNTER23 0xC17
#define CSR_HPMCOUNTER24 0xC18
#define CSR_HPMCOUNTER25 0xC19
#define CSR_HPMCOUNTER26 0xC1A
#define CSR_HPMCOUNTER27 0xC1B
#define CSR_HPMCOUNTER28 0xC1C
#define CSR_HPMCOUNTER29 0xC1D
#define CSR_HPMCOUNTER30 0xC1E
#define CSR_HPMCOUNTER31 0xC1F /* DWARF 7199 */
/* RV32-only high halves */
#define CSR_CYCLEH        0xC80 /* DWARF 7296 */
#define CSR_TIMEH         0xC81
#define CSR_INSTRETH      0xC82
#define CSR_HPMCOUNTER3H  0xC83
#define CSR_HPMCOUNTER4H  0xC84
#define CSR_HPMCOUNTER5H  0xC85
#define CSR_HPMCOUNTER6H  0xC86
#define CSR_HPMCOUNTER7H  0xC87
#define CSR_HPMCOUNTER8H  0xC88
#define CSR_HPMCOUNTER9H  0xC89
#define CSR_HPMCOUNTER10H 0xC8A
#define CSR_HPMCOUNTER11H 0xC8B
#define CSR_HPMCOUNTER12H 0xC8C
#define CSR_HPMCOUNTER13H 0xC8D
#define CSR_HPMCOUNTER14H 0xC8E
#define CSR_HPMCOUNTER15H 0xC8F
#define CSR_HPMCOUNTER16H 0xC90
#define CSR_HPMCOUNTER17H 0xC91
#define CSR_HPMCOUNTER18H 0xC92
#define CSR_HPMCOUNTER19H 0xC93
#define CSR_HPMCOUNTER20H 0xC94
#define CSR_HPMCOUNTER21H 0xC95
#define CSR_HPMCOUNTER22H 0xC96
#define CSR_HPMCOUNTER23H 0xC97
#define CSR_HPMCOUNTER24H 0xC98
#define CSR_HPMCOUNTER25H 0xC99
#define CSR_HPMCOUNTER26H 0xC9A
#define CSR_HPMCOUNTER27H 0xC9B
#define CSR_HPMCOUNTER28H 0xC9C
#define CSR_HPMCOUNTER29H 0xC9D
#define CSR_HPMCOUNTER30H 0xC9E
#define CSR_HPMCOUNTER31H 0xC9F /* DWARF 7327 */
/* Supervisor */
#define CSR_SSTATUS       0x100 /* DWARF 4352 */
#define CSR_SIE           0x104
#define CSR_STVEC         0x105
#define CSR_SCOUNTEREN    0x106
#define CSR_SENVCFG       0x10A
#define CSR_SCOUNTINHIBIT 0x120
#define CSR_SSTATEEN0     0x10C
#define CSR_SSTATEEN1     0x10D
#define CSR_SSTATEEN2     0x10E
#define CSR_SSTATEEN3     0x10F
#define CSR_SSCRATCH      0x140
#define CSR_SEPC          0x141
#define CSR_SCAUSE        0x142
#define CSR_STVAL         0x143
#define CSR_SIP           0x144
#define CSR_SCOUNTOVF     0xDA0 /* DWARF 7584  SRO Sscofpmf */
#define CSR_SATP          0x180 /* DWARF 4480 */
#define CSR_SCONTEXT      0x5A8
#define CSR_STIMECMP      0x14D /* Sstc */
#define CSR_STIMECMPH     0x15D /* Sstc RV32 only */
#define CSR_SISELECT      0x150 /* Sscsrind */
#define CSR_SIREG         0x151
#define CSR_SIREG2        0x152
#define CSR_SIREG3        0x153
#define CSR_SIREG4        0x154
#define CSR_SIREG5        0x155
#define CSR_SIREG6        0x156
#define CSR_STOPEI        0x15C /* AIA */
/* Hypervisor */
#define CSR_HSTATUS     0x600 /* DWARF 5696 */
#define CSR_HEDELEG     0x602
#define CSR_HIDELEG     0x603
#define CSR_HIE         0x604
#define CSR_HCOUNTEREN  0x606
#define CSR_HGEIE       0x607
#define CSR_HEDELEGH    0x612 /* RV32 only */
#define CSR_HTVAL       0x643
#define CSR_HIP         0x644
#define CSR_HVIP        0x645
#define CSR_HTINST      0x64A
#define CSR_HGEIP       0xE12 /* DWARF 7698  HRO */
#define CSR_HENVCFG     0x60A
#define CSR_HENVCFGH    0x61A /* RV32 only */
#define CSR_HGATP       0x680
#define CSR_HCONTEXT    0x6A8
#define CSR_HTIMEDELTA  0x605
#define CSR_HTIMEDELTAH 0x615 /* RV32 only */
#define CSR_HSTATEEN0   0x60C
#define CSR_HSTATEEN1   0x60D
#define CSR_HSTATEEN2   0x60E
#define CSR_HSTATEEN3   0x60F
#define CSR_HSTATEEN0H  0x61C /* RV32 only */
#define CSR_HSTATEEN1H  0x61D
#define CSR_HSTATEEN2H  0x61E
#define CSR_HSTATEEN3H  0x61F
/* Virtual Supervisor */
#define CSR_VSSTATUS   0x200 /* DWARF 4608 */
#define CSR_VSIE       0x204
#define CSR_VSTVEC     0x205
#define CSR_VSSCRATCH  0x240
#define CSR_VSEPC      0x241
#define CSR_VSCAUSE    0x242
#define CSR_VSTVAL     0x243
#define CSR_VSIP       0x244
#define CSR_VSATP      0x280
#define CSR_VSTIMECMP  0x24D /* Sstc */
#define CSR_VSTIMECMPH 0x25D /* Sstc RV32 only */
#define CSR_VSISELECT  0x250 /* Smcsrind */
#define CSR_VSIREG     0x251
#define CSR_VSIREG2    0x252
#define CSR_VSIREG3    0x253
#define CSR_VSIREG4    0x254
#define CSR_VSIREG5    0x255
#define CSR_VSIREG6    0x256
#define CSR_VSTOPEI    0x25C /* AIA */
/* Machine Information (MRO) */
#define CSR_MVENDORID  0xF11 /* DWARF 8081 */
#define CSR_MARCHID    0xF12
#define CSR_MIMPID     0xF13
#define CSR_MHARTID    0xF14
#define CSR_MCONFIGPTR 0xF15
/* Machine Trap Setup */
#define CSR_MSTATUS    0x300 /* DWARF 4864 */
#define CSR_MISA       0x301
#define CSR_MEDELEG    0x302
#define CSR_MIDELEG    0x303
#define CSR_MIE        0x304
#define CSR_MTVEC      0x305
#define CSR_MCOUNTEREN 0x306
#define CSR_MSTATUSH   0x310 /* RV32 only */
#define CSR_MEDELEGH   0x312 /* RV32 only */
/* Machine Trap Handling */
#define CSR_MSCRATCH 0x340
#define CSR_MEPC     0x341
#define CSR_MCAUSE   0x342
#define CSR_MTVAL    0x343
#define CSR_MIP      0x344
#define CSR_MTINST   0x34A /* H-ext */
#define CSR_MTVAL2   0x34B /* H-ext */
/* Machine Configuration */
#define CSR_MENVCFG  0x30A
#define CSR_MENVCFGH 0x31A /* RV32 only */
#define CSR_MSECCFG  0x747 /* Smepmp */
#define CSR_MSECCFGH 0x757 /* RV32 only */
/* Machine State Enable */
#define CSR_MSTATEEN0  0x30C
#define CSR_MSTATEEN1  0x30D
#define CSR_MSTATEEN2  0x30E
#define CSR_MSTATEEN3  0x30F
#define CSR_MSTATEEN0H 0x31C /* RV32 only */
#define CSR_MSTATEEN1H 0x31D
#define CSR_MSTATEEN2H 0x31E
#define CSR_MSTATEEN3H 0x31F
/* PMP config */
#define CSR_PMPCFG0  0x3A0
#define CSR_PMPCFG1  0x3A1 /* RV32 only */
#define CSR_PMPCFG2  0x3A2
#define CSR_PMPCFG3  0x3A3 /* RV32 only */
#define CSR_PMPCFG4  0x3A4
#define CSR_PMPCFG5  0x3A5 /* RV32 only */
#define CSR_PMPCFG6  0x3A6
#define CSR_PMPCFG7  0x3A7 /* RV32 only */
#define CSR_PMPCFG8  0x3A8
#define CSR_PMPCFG9  0x3A9 /* RV32 only */
#define CSR_PMPCFG10 0x3AA
#define CSR_PMPCFG11 0x3AB /* RV32 only */
#define CSR_PMPCFG12 0x3AC
#define CSR_PMPCFG13 0x3AD /* RV32 only */
#define CSR_PMPCFG14 0x3AE
#define CSR_PMPCFG15 0x3AF /* RV32 only */
/* PMP address 0..63 */
#define CSR_PMPADDR0  0x3B0
#define CSR_PMPADDR1  0x3B1
#define CSR_PMPADDR2  0x3B2
#define CSR_PMPADDR3  0x3B3
#define CSR_PMPADDR4  0x3B4
#define CSR_PMPADDR5  0x3B5
#define CSR_PMPADDR6  0x3B6
#define CSR_PMPADDR7  0x3B7
#define CSR_PMPADDR8  0x3B8
#define CSR_PMPADDR9  0x3B9
#define CSR_PMPADDR10 0x3BA
#define CSR_PMPADDR11 0x3BB
#define CSR_PMPADDR12 0x3BC
#define CSR_PMPADDR13 0x3BD
#define CSR_PMPADDR14 0x3BE
#define CSR_PMPADDR15 0x3BF
#define CSR_PMPADDR16 0x3C0
#define CSR_PMPADDR17 0x3C1
#define CSR_PMPADDR18 0x3C2
#define CSR_PMPADDR19 0x3C3
#define CSR_PMPADDR20 0x3C4
#define CSR_PMPADDR21 0x3C5
#define CSR_PMPADDR22 0x3C6
#define CSR_PMPADDR23 0x3C7
#define CSR_PMPADDR24 0x3C8
#define CSR_PMPADDR25 0x3C9
#define CSR_PMPADDR26 0x3CA
#define CSR_PMPADDR27 0x3CB
#define CSR_PMPADDR28 0x3CC
#define CSR_PMPADDR29 0x3CD
#define CSR_PMPADDR30 0x3CE
#define CSR_PMPADDR31 0x3CF
#define CSR_PMPADDR32 0x3D0
#define CSR_PMPADDR33 0x3D1
#define CSR_PMPADDR34 0x3D2
#define CSR_PMPADDR35 0x3D3
#define CSR_PMPADDR36 0x3D4
#define CSR_PMPADDR37 0x3D5
#define CSR_PMPADDR38 0x3D6
#define CSR_PMPADDR39 0x3D7
#define CSR_PMPADDR40 0x3D8
#define CSR_PMPADDR41 0x3D9
#define CSR_PMPADDR42 0x3DA
#define CSR_PMPADDR43 0x3DB
#define CSR_PMPADDR44 0x3DC
#define CSR_PMPADDR45 0x3DD
#define CSR_PMPADDR46 0x3DE
#define CSR_PMPADDR47 0x3DF
#define CSR_PMPADDR48 0x3E0
#define CSR_PMPADDR49 0x3E1
#define CSR_PMPADDR50 0x3E2
#define CSR_PMPADDR51 0x3E3
#define CSR_PMPADDR52 0x3E4
#define CSR_PMPADDR53 0x3E5
#define CSR_PMPADDR54 0x3E6
#define CSR_PMPADDR55 0x3E7
#define CSR_PMPADDR56 0x3E8
#define CSR_PMPADDR57 0x3E9
#define CSR_PMPADDR58 0x3EA
#define CSR_PMPADDR59 0x3EB
#define CSR_PMPADDR60 0x3EC
#define CSR_PMPADDR61 0x3ED
#define CSR_PMPADDR62 0x3EE
#define CSR_PMPADDR63 0x3EF
/* Machine NMI (Smrnmi) */
#define CSR_MNSCRATCH 0x740
#define CSR_MNEPC     0x741
#define CSR_MNCAUSE   0x742
#define CSR_MNSTATUS  0x744
/* Machine Counters/Timers */
#define CSR_MCYCLE        0xB00 /* DWARF 6400 */
#define CSR_MINSTRET      0xB02
#define CSR_MHPMCOUNTER3  0xB03
#define CSR_MHPMCOUNTER4  0xB04
#define CSR_MHPMCOUNTER5  0xB05
#define CSR_MHPMCOUNTER6  0xB06
#define CSR_MHPMCOUNTER7  0xB07
#define CSR_MHPMCOUNTER8  0xB08
#define CSR_MHPMCOUNTER9  0xB09
#define CSR_MHPMCOUNTER10 0xB0A
#define CSR_MHPMCOUNTER11 0xB0B
#define CSR_MHPMCOUNTER12 0xB0C
#define CSR_MHPMCOUNTER13 0xB0D
#define CSR_MHPMCOUNTER14 0xB0E
#define CSR_MHPMCOUNTER15 0xB0F
#define CSR_MHPMCOUNTER16 0xB10
#define CSR_MHPMCOUNTER17 0xB11
#define CSR_MHPMCOUNTER18 0xB12
#define CSR_MHPMCOUNTER19 0xB13
#define CSR_MHPMCOUNTER20 0xB14
#define CSR_MHPMCOUNTER21 0xB15
#define CSR_MHPMCOUNTER22 0xB16
#define CSR_MHPMCOUNTER23 0xB17
#define CSR_MHPMCOUNTER24 0xB18
#define CSR_MHPMCOUNTER25 0xB19
#define CSR_MHPMCOUNTER26 0xB1A
#define CSR_MHPMCOUNTER27 0xB1B
#define CSR_MHPMCOUNTER28 0xB1C
#define CSR_MHPMCOUNTER29 0xB1D
#define CSR_MHPMCOUNTER30 0xB1E
#define CSR_MHPMCOUNTER31 0xB1F
/* RV32 high halves */
#define CSR_MCYCLEH        0xB80
#define CSR_MINSTRETH      0xB82
#define CSR_MHPMCOUNTER3H  0xB83
#define CSR_MHPMCOUNTER4H  0xB84
#define CSR_MHPMCOUNTER5H  0xB85
#define CSR_MHPMCOUNTER6H  0xB86
#define CSR_MHPMCOUNTER7H  0xB87
#define CSR_MHPMCOUNTER8H  0xB88
#define CSR_MHPMCOUNTER9H  0xB89
#define CSR_MHPMCOUNTER10H 0xB8A
#define CSR_MHPMCOUNTER11H 0xB8B
#define CSR_MHPMCOUNTER12H 0xB8C
#define CSR_MHPMCOUNTER13H 0xB8D
#define CSR_MHPMCOUNTER14H 0xB8E
#define CSR_MHPMCOUNTER15H 0xB8F
#define CSR_MHPMCOUNTER16H 0xB90
#define CSR_MHPMCOUNTER17H 0xB91
#define CSR_MHPMCOUNTER18H 0xB92
#define CSR_MHPMCOUNTER19H 0xB93
#define CSR_MHPMCOUNTER20H 0xB94
#define CSR_MHPMCOUNTER21H 0xB95
#define CSR_MHPMCOUNTER22H 0xB96
#define CSR_MHPMCOUNTER23H 0xB97
#define CSR_MHPMCOUNTER24H 0xB98
#define CSR_MHPMCOUNTER25H 0xB99
#define CSR_MHPMCOUNTER26H 0xB9A
#define CSR_MHPMCOUNTER27H 0xB9B
#define CSR_MHPMCOUNTER28H 0xB9C
#define CSR_MHPMCOUNTER29H 0xB9D
#define CSR_MHPMCOUNTER30H 0xB9E
#define CSR_MHPMCOUNTER31H 0xB9F
/* Machine Counter Setup */
#define CSR_MCOUNTINHIBIT 0x320
#define CSR_MCYCLECFG     0x321 /* Smcntrpmf */
#define CSR_MINSTRETCFG   0x322
#define CSR_MHPMEVENT3    0x323
#define CSR_MHPMEVENT4    0x324
#define CSR_MHPMEVENT5    0x325
#define CSR_MHPMEVENT6    0x326
#define CSR_MHPMEVENT7    0x327
#define CSR_MHPMEVENT8    0x328
#define CSR_MHPMEVENT9    0x329
#define CSR_MHPMEVENT10   0x32A
#define CSR_MHPMEVENT11   0x32B
#define CSR_MHPMEVENT12   0x32C
#define CSR_MHPMEVENT13   0x32D
#define CSR_MHPMEVENT14   0x32E
#define CSR_MHPMEVENT15   0x32F
#define CSR_MHPMEVENT16   0x330
#define CSR_MHPMEVENT17   0x331
#define CSR_MHPMEVENT18   0x332
#define CSR_MHPMEVENT19   0x333
#define CSR_MHPMEVENT20   0x334
#define CSR_MHPMEVENT21   0x335
#define CSR_MHPMEVENT22   0x336
#define CSR_MHPMEVENT23   0x337
#define CSR_MHPMEVENT24   0x338
#define CSR_MHPMEVENT25   0x339
#define CSR_MHPMEVENT26   0x33A
#define CSR_MHPMEVENT27   0x33B
#define CSR_MHPMEVENT28   0x33C
#define CSR_MHPMEVENT29   0x33D
#define CSR_MHPMEVENT30   0x33E
#define CSR_MHPMEVENT31   0x33F
/* Sscofpmf high-half event selectors (RV32 only) */
#define CSR_MCYCLECFGH   0x721
#define CSR_MINSTRETCFGH 0x722
#define CSR_MHPMEVENT3H  0x723
#define CSR_MHPMEVENT4H  0x724
#define CSR_MHPMEVENT5H  0x725
#define CSR_MHPMEVENT6H  0x726
#define CSR_MHPMEVENT7H  0x727
#define CSR_MHPMEVENT8H  0x728
#define CSR_MHPMEVENT9H  0x729
#define CSR_MHPMEVENT10H 0x72A
#define CSR_MHPMEVENT11H 0x72B
#define CSR_MHPMEVENT12H 0x72C
#define CSR_MHPMEVENT13H 0x72D
#define CSR_MHPMEVENT14H 0x72E
#define CSR_MHPMEVENT15H 0x72F
#define CSR_MHPMEVENT16H 0x730
#define CSR_MHPMEVENT17H 0x731
#define CSR_MHPMEVENT18H 0x732
#define CSR_MHPMEVENT19H 0x733
#define CSR_MHPMEVENT20H 0x734
#define CSR_MHPMEVENT21H 0x735
#define CSR_MHPMEVENT22H 0x736
#define CSR_MHPMEVENT23H 0x737
#define CSR_MHPMEVENT24H 0x738
#define CSR_MHPMEVENT25H 0x739
#define CSR_MHPMEVENT26H 0x73A
#define CSR_MHPMEVENT27H 0x73B
#define CSR_MHPMEVENT28H 0x73C
#define CSR_MHPMEVENT29H 0x73D
#define CSR_MHPMEVENT30H 0x73E
#define CSR_MHPMEVENT31H 0x73F
/* Debug/Trace — M-mode accessible subset (0x7A0..0x7AF) */
#define CSR_TSELECT   0x7A0
#define CSR_TDATA1    0x7A1
#define CSR_TDATA2    0x7A2
#define CSR_TDATA3    0x7A3
#define CSR_TINFO     0x7A4
#define CSR_TCONTROL  0x7A5
#define CSR_MCONTEXT  0x7A8
#define CSR_MSCONTEXT 0x7AA
/* Debug Mode only (0x7B0-0x7B3) — illegal even from M-mode, listed for
 * reference */
#define CSR_DCSR      0x7B0
#define CSR_DPC       0x7B1
#define CSR_DSCRATCH0 0x7B2
#define CSR_DSCRATCH1 0x7B3
/* Machine indirect CSR access (Smcsrind) */
#define CSR_MISELECT 0x350
#define CSR_MIREG    0x351
#define CSR_MIREG2   0x352
#define CSR_MIREG3   0x353
#define CSR_MIREG4   0x354
#define CSR_MIREG5   0x355
#define CSR_MIREG6   0x356
#define CSR_MTOPEI   0x35C /* AIA */

/* =========================================================================
 * Section 4 — RO functions: csr_ro_<n>()
 * 3 read-safe instruction forms.  Safe on genuinely read-only CSRs.
 * ========================================================================= */

/* -- Unprivileged Floating-Point -- */

DEMO_RO(fflags)

DEMO_RO(frm)
DEMO_RO(fcsr)

/* -- Unprivileged Counter/Timer shadows -- */

DEMO_RO(cycle)
DEMO_RO(time)
DEMO_RO(instret)

DEMO_RO(hpmcounter3)
DEMO_RO(hpmcounter4)
DEMO_RO(hpmcounter5)

DEMO_RO(hpmcounter6)
DEMO_RO(hpmcounter7)
DEMO_RO(hpmcounter8)

DEMO_RO(hpmcounter9)
DEMO_RO(hpmcounter10)
DEMO_RO(hpmcounter11)

DEMO_RO(hpmcounter12)
DEMO_RO(hpmcounter13)
DEMO_RO(hpmcounter14)

DEMO_RO(hpmcounter15)
DEMO_RO(hpmcounter16)
DEMO_RO(hpmcounter17)

DEMO_RO(hpmcounter18)
DEMO_RO(hpmcounter19)
DEMO_RO(hpmcounter20)

DEMO_RO(hpmcounter21)
DEMO_RO(hpmcounter22)
DEMO_RO(hpmcounter23)

DEMO_RO(hpmcounter24)
DEMO_RO(hpmcounter25)
DEMO_RO(hpmcounter26)

DEMO_RO(hpmcounter27)
DEMO_RO(hpmcounter28)
DEMO_RO(hpmcounter29)

DEMO_RO(hpmcounter30)
DEMO_RO(hpmcounter31)
/* RV32-only high halves */

DEMO_RO(cycleh)
DEMO_RO(timeh)
DEMO_RO(instreth)

DEMO_RO(hpmcounter3h)
DEMO_RO(hpmcounter4h)
DEMO_RO(hpmcounter5h)

DEMO_RO(hpmcounter6h)
DEMO_RO(hpmcounter7h)
DEMO_RO(hpmcounter8h)

DEMO_RO(hpmcounter9h)
DEMO_RO(hpmcounter10h)
DEMO_RO(hpmcounter11h)

DEMO_RO(hpmcounter12h)
DEMO_RO(hpmcounter13h)
DEMO_RO(hpmcounter14h)

DEMO_RO(hpmcounter15h)
DEMO_RO(hpmcounter16h)
DEMO_RO(hpmcounter17h)

DEMO_RO(hpmcounter18h)
DEMO_RO(hpmcounter19h)
DEMO_RO(hpmcounter20h)

DEMO_RO(hpmcounter21h)
DEMO_RO(hpmcounter22h)
DEMO_RO(hpmcounter23h)

DEMO_RO(hpmcounter24h)
DEMO_RO(hpmcounter25h)
DEMO_RO(hpmcounter26h)

DEMO_RO(hpmcounter27h)
DEMO_RO(hpmcounter28h)
DEMO_RO(hpmcounter29h)

DEMO_RO(hpmcounter30h)
DEMO_RO(hpmcounter31h)

/* -- Supervisor -- */

DEMO_RO(sstatus)
DEMO_RO(sie)
DEMO_RO(stvec)
DEMO_RO(scounteren)

DEMO_RO(senvcfg)
DEMO_RO(scountinhibit)

DEMO_RO(sstateen0)
DEMO_RO(sstateen1)
DEMO_RO(sstateen2)
DEMO_RO(sstateen3)

DEMO_RO(sscratch)
DEMO_RO(sepc)
DEMO_RO(scause)
DEMO_RO(stval)

DEMO_RO(sip)
DEMO_RO(scountovf)
DEMO_RO(satp)
DEMO_RO(scontext)

DEMO_RO(stimecmp)
DEMO_RO(stimecmph)

DEMO_RO(siselect)
DEMO_RO(sireg)
DEMO_RO(sireg2)
DEMO_RO(sireg3)

DEMO_RO(sireg4)
DEMO_RO(sireg5)
DEMO_RO(sireg6)
DEMO_RO(stopei)

/* -- Hypervisor and VS -- */

DEMO_RO(hstatus)
DEMO_RO(hedeleg)
DEMO_RO(hideleg)
DEMO_RO(hie)

DEMO_RO(hcounteren)
DEMO_RO(hgeie)
DEMO_RO(hedelegh)

DEMO_RO(htval)
DEMO_RO(hip)
DEMO_RO(hvip)
DEMO_RO(htinst)
DEMO_RO(hgeip)

DEMO_RO(henvcfg)
DEMO_RO(henvcfgh)
DEMO_RO(hgatp)
DEMO_RO(hcontext)

DEMO_RO(htimedelta)
DEMO_RO(htimedeltah)

DEMO_RO(hstateen0)
DEMO_RO(hstateen1)
DEMO_RO(hstateen2)
DEMO_RO(hstateen3)

DEMO_RO(hstateen0h)
DEMO_RO(hstateen1h)
DEMO_RO(hstateen2h)
DEMO_RO(hstateen3h)

DEMO_RO(vsstatus)
DEMO_RO(vsie)
DEMO_RO(vstvec)
DEMO_RO(vsscratch)

DEMO_RO(vsepc)
DEMO_RO(vscause)
DEMO_RO(vstval)
DEMO_RO(vsip)
DEMO_RO(vsatp)

DEMO_RO(vstimecmp)
DEMO_RO(vstimecmph)

DEMO_RO(vsiselect)
DEMO_RO(vsireg)
DEMO_RO(vsireg2)
DEMO_RO(vsireg3)

DEMO_RO(vsireg4)
DEMO_RO(vsireg5)
DEMO_RO(vsireg6)
DEMO_RO(vstopei)

/* -- Machine -- */

DEMO_RO(mvendorid)
DEMO_RO(marchid)
DEMO_RO(mimpid)

DEMO_RO(mhartid)
DEMO_RO(mconfigptr)

DEMO_RO(mstatus)
DEMO_RO(misa)
DEMO_RO(medeleg)
DEMO_RO(mideleg)

DEMO_RO(mie)
DEMO_RO(mtvec)
DEMO_RO(mcounteren)
DEMO_RO(mstatush)
DEMO_RO(medelegh)

DEMO_RO(mscratch)
DEMO_RO(mepc)
DEMO_RO(mcause)
DEMO_RO(mtval)

DEMO_RO(mip)
DEMO_RO(mtinst)
DEMO_RO(mtval2)

DEMO_RO(menvcfg)
DEMO_RO(menvcfgh)
DEMO_RO(mseccfg)
DEMO_RO(mseccfgh)

DEMO_RO(mstateen0)
DEMO_RO(mstateen1)
DEMO_RO(mstateen2)
DEMO_RO(mstateen3)

DEMO_RO(mstateen0h)
DEMO_RO(mstateen1h)
DEMO_RO(mstateen2h)
DEMO_RO(mstateen3h)

DEMO_RO(pmpcfg0)
DEMO_RO(pmpcfg1)
DEMO_RO(pmpcfg2)
DEMO_RO(pmpcfg3)

DEMO_RO(pmpcfg4)
DEMO_RO(pmpcfg5)
DEMO_RO(pmpcfg6)
DEMO_RO(pmpcfg7)

DEMO_RO(pmpcfg8)
DEMO_RO(pmpcfg9)
DEMO_RO(pmpcfg10)
DEMO_RO(pmpcfg11)

DEMO_RO(pmpcfg12)
DEMO_RO(pmpcfg13)
DEMO_RO(pmpcfg14)
DEMO_RO(pmpcfg15)

DEMO_RO(pmpaddr0)
DEMO_RO(pmpaddr1)
DEMO_RO(pmpaddr2)
DEMO_RO(pmpaddr3)

DEMO_RO(pmpaddr4)
DEMO_RO(pmpaddr5)
DEMO_RO(pmpaddr6)
DEMO_RO(pmpaddr7)

DEMO_RO(pmpaddr8)
DEMO_RO(pmpaddr9)
DEMO_RO(pmpaddr10)
DEMO_RO(pmpaddr11)

DEMO_RO(pmpaddr12)
DEMO_RO(pmpaddr13)
DEMO_RO(pmpaddr14)
DEMO_RO(pmpaddr15)

DEMO_RO(pmpaddr16)
DEMO_RO(pmpaddr17)
DEMO_RO(pmpaddr18)
DEMO_RO(pmpaddr19)

DEMO_RO(pmpaddr20)
DEMO_RO(pmpaddr21)
DEMO_RO(pmpaddr22)
DEMO_RO(pmpaddr23)

DEMO_RO(pmpaddr24)
DEMO_RO(pmpaddr25)
DEMO_RO(pmpaddr26)
DEMO_RO(pmpaddr27)

DEMO_RO(pmpaddr28)
DEMO_RO(pmpaddr29)
DEMO_RO(pmpaddr30)
DEMO_RO(pmpaddr31)

DEMO_RO(pmpaddr32)
DEMO_RO(pmpaddr33)
DEMO_RO(pmpaddr34)
DEMO_RO(pmpaddr35)

DEMO_RO(pmpaddr36)
DEMO_RO(pmpaddr37)
DEMO_RO(pmpaddr38)
DEMO_RO(pmpaddr39)

DEMO_RO(pmpaddr40)
DEMO_RO(pmpaddr41)
DEMO_RO(pmpaddr42)
DEMO_RO(pmpaddr43)

DEMO_RO(pmpaddr44)
DEMO_RO(pmpaddr45)
DEMO_RO(pmpaddr46)
DEMO_RO(pmpaddr47)

DEMO_RO(pmpaddr48)
DEMO_RO(pmpaddr49)
DEMO_RO(pmpaddr50)
DEMO_RO(pmpaddr51)

DEMO_RO(pmpaddr52)
DEMO_RO(pmpaddr53)
DEMO_RO(pmpaddr54)
DEMO_RO(pmpaddr55)

DEMO_RO(pmpaddr56)
DEMO_RO(pmpaddr57)
DEMO_RO(pmpaddr58)
DEMO_RO(pmpaddr59)

DEMO_RO(pmpaddr60)
DEMO_RO(pmpaddr61)
DEMO_RO(pmpaddr62)
DEMO_RO(pmpaddr63)

DEMO_RO(mnscratch)
DEMO_RO(mnepc)
DEMO_RO(mncause)
DEMO_RO(mnstatus)

DEMO_RO(mcycle)
DEMO_RO(minstret)

DEMO_RO(mhpmcounter3)
DEMO_RO(mhpmcounter4)
DEMO_RO(mhpmcounter5)

DEMO_RO(mhpmcounter6)
DEMO_RO(mhpmcounter7)
DEMO_RO(mhpmcounter8)

DEMO_RO(mhpmcounter9)
DEMO_RO(mhpmcounter10)
DEMO_RO(mhpmcounter11)

DEMO_RO(mhpmcounter12)
DEMO_RO(mhpmcounter13)
DEMO_RO(mhpmcounter14)

DEMO_RO(mhpmcounter15)
DEMO_RO(mhpmcounter16)
DEMO_RO(mhpmcounter17)

DEMO_RO(mhpmcounter18)
DEMO_RO(mhpmcounter19)
DEMO_RO(mhpmcounter20)

DEMO_RO(mhpmcounter21)
DEMO_RO(mhpmcounter22)
DEMO_RO(mhpmcounter23)

DEMO_RO(mhpmcounter24)
DEMO_RO(mhpmcounter25)
DEMO_RO(mhpmcounter26)

DEMO_RO(mhpmcounter27)
DEMO_RO(mhpmcounter28)
DEMO_RO(mhpmcounter29)

DEMO_RO(mhpmcounter30)
DEMO_RO(mhpmcounter31)

DEMO_RO(mcycleh)
DEMO_RO(minstreth)

DEMO_RO(mhpmcounter3h)
DEMO_RO(mhpmcounter4h)
DEMO_RO(mhpmcounter5h)

DEMO_RO(mhpmcounter6h)
DEMO_RO(mhpmcounter7h)
DEMO_RO(mhpmcounter8h)

DEMO_RO(mhpmcounter9h)
DEMO_RO(mhpmcounter10h)
DEMO_RO(mhpmcounter11h)

DEMO_RO(mhpmcounter12h)
DEMO_RO(mhpmcounter13h)
DEMO_RO(mhpmcounter14h)

DEMO_RO(mhpmcounter15h)
DEMO_RO(mhpmcounter16h)
DEMO_RO(mhpmcounter17h)

DEMO_RO(mhpmcounter18h)
DEMO_RO(mhpmcounter19h)
DEMO_RO(mhpmcounter20h)

DEMO_RO(mhpmcounter21h)
DEMO_RO(mhpmcounter22h)
DEMO_RO(mhpmcounter23h)

DEMO_RO(mhpmcounter24h)
DEMO_RO(mhpmcounter25h)
DEMO_RO(mhpmcounter26h)

DEMO_RO(mhpmcounter27h)
DEMO_RO(mhpmcounter28h)
DEMO_RO(mhpmcounter29h)

DEMO_RO(mhpmcounter30h)
DEMO_RO(mhpmcounter31h)

DEMO_RO(mcountinhibit)
DEMO_RO(mcyclecfg)
DEMO_RO(minstretcfg)

DEMO_RO(mhpmevent3)
DEMO_RO(mhpmevent4)
DEMO_RO(mhpmevent5)

DEMO_RO(mhpmevent6)
DEMO_RO(mhpmevent7)
DEMO_RO(mhpmevent8)

DEMO_RO(mhpmevent9)
DEMO_RO(mhpmevent10)
DEMO_RO(mhpmevent11)

DEMO_RO(mhpmevent12)
DEMO_RO(mhpmevent13)
DEMO_RO(mhpmevent14)

DEMO_RO(mhpmevent15)
DEMO_RO(mhpmevent16)
DEMO_RO(mhpmevent17)

DEMO_RO(mhpmevent18)
DEMO_RO(mhpmevent19)
DEMO_RO(mhpmevent20)

DEMO_RO(mhpmevent21)
DEMO_RO(mhpmevent22)
DEMO_RO(mhpmevent23)

DEMO_RO(mhpmevent24)
DEMO_RO(mhpmevent25)
DEMO_RO(mhpmevent26)

DEMO_RO(mhpmevent27)
DEMO_RO(mhpmevent28)
DEMO_RO(mhpmevent29)

DEMO_RO(mhpmevent30)
DEMO_RO(mhpmevent31)

DEMO_RO(mcyclecfgh)
DEMO_RO(minstretcfgh)

DEMO_RO(mhpmevent3h)
DEMO_RO(mhpmevent4h)
DEMO_RO(mhpmevent5h)

DEMO_RO(mhpmevent6h)
DEMO_RO(mhpmevent7h)
DEMO_RO(mhpmevent8h)

DEMO_RO(mhpmevent9h)
DEMO_RO(mhpmevent10h)
DEMO_RO(mhpmevent11h)

DEMO_RO(mhpmevent12h)
DEMO_RO(mhpmevent13h)
DEMO_RO(mhpmevent14h)

DEMO_RO(mhpmevent15h)
DEMO_RO(mhpmevent16h)
DEMO_RO(mhpmevent17h)

DEMO_RO(mhpmevent18h)
DEMO_RO(mhpmevent19h)
DEMO_RO(mhpmevent20h)

DEMO_RO(mhpmevent21h)
DEMO_RO(mhpmevent22h)
DEMO_RO(mhpmevent23h)

DEMO_RO(mhpmevent24h)
DEMO_RO(mhpmevent25h)
DEMO_RO(mhpmevent26h)

DEMO_RO(mhpmevent27h)
DEMO_RO(mhpmevent28h)
DEMO_RO(mhpmevent29h)

DEMO_RO(mhpmevent30h)
DEMO_RO(mhpmevent31h)

DEMO_RO(tselect)
DEMO_RO(tdata1)
DEMO_RO(tdata2)
DEMO_RO(tdata3)

DEMO_RO(tinfo)
DEMO_RO(tcontrol)
DEMO_RO(mcontext)
DEMO_RO(mscontext)
/* Debug Mode only (0x7B0-0x7B3): even reads fault from M-mode.

DEMO_RO(dcsr)
DEMO_RO(dpc)
DEMO_RO(dscratch0)
DEMO_RO(dscratch1) */

DEMO_RO(miselect)
DEMO_RO(mireg)
DEMO_RO(mireg2)
DEMO_RO(mireg3)

DEMO_RO(mireg4)
DEMO_RO(mireg5)
DEMO_RO(mireg6)
DEMO_RO(mtopei)

/* =========================================================================
 * Section 5 — RW functions: csr_rw_<n>()
 * All 8 instruction forms per register.
 * ========================================================================= */

/* -- Unprivileged Floating-Point -- */

DEMO_ALL_FORMS(fflags)
DEMO_ALL_FORMS(frm)
DEMO_ALL_FORMS(fcsr)

/* -- Unprivileged Counter/Timer shadows -- */

DEMO_ALL_FORMS(cycle)
DEMO_ALL_FORMS(time)
DEMO_ALL_FORMS(instret)

DEMO_ALL_FORMS(hpmcounter3)
DEMO_ALL_FORMS(hpmcounter4)
DEMO_ALL_FORMS(hpmcounter5)

DEMO_ALL_FORMS(hpmcounter6)
DEMO_ALL_FORMS(hpmcounter7)
DEMO_ALL_FORMS(hpmcounter8)

DEMO_ALL_FORMS(hpmcounter9)
DEMO_ALL_FORMS(hpmcounter10)
DEMO_ALL_FORMS(hpmcounter11)

DEMO_ALL_FORMS(hpmcounter12)
DEMO_ALL_FORMS(hpmcounter13)
DEMO_ALL_FORMS(hpmcounter14)

DEMO_ALL_FORMS(hpmcounter15)
DEMO_ALL_FORMS(hpmcounter16)
DEMO_ALL_FORMS(hpmcounter17)

DEMO_ALL_FORMS(hpmcounter18)
DEMO_ALL_FORMS(hpmcounter19)
DEMO_ALL_FORMS(hpmcounter20)

DEMO_ALL_FORMS(hpmcounter21)
DEMO_ALL_FORMS(hpmcounter22)
DEMO_ALL_FORMS(hpmcounter23)

DEMO_ALL_FORMS(hpmcounter24)
DEMO_ALL_FORMS(hpmcounter25)
DEMO_ALL_FORMS(hpmcounter26)

DEMO_ALL_FORMS(hpmcounter27)
DEMO_ALL_FORMS(hpmcounter28)
DEMO_ALL_FORMS(hpmcounter29)

DEMO_ALL_FORMS(hpmcounter30)
DEMO_ALL_FORMS(hpmcounter31)
/* RV32-only high halves */

DEMO_ALL_FORMS(cycleh)
DEMO_ALL_FORMS(timeh)
DEMO_ALL_FORMS(instreth)

DEMO_ALL_FORMS(hpmcounter3h)
DEMO_ALL_FORMS(hpmcounter4h)
DEMO_ALL_FORMS(hpmcounter5h)

DEMO_ALL_FORMS(hpmcounter6h)
DEMO_ALL_FORMS(hpmcounter7h)
DEMO_ALL_FORMS(hpmcounter8h)

DEMO_ALL_FORMS(hpmcounter9h)
DEMO_ALL_FORMS(hpmcounter10h)
DEMO_ALL_FORMS(hpmcounter11h)

DEMO_ALL_FORMS(hpmcounter12h)
DEMO_ALL_FORMS(hpmcounter13h)
DEMO_ALL_FORMS(hpmcounter14h)

DEMO_ALL_FORMS(hpmcounter15h)
DEMO_ALL_FORMS(hpmcounter16h)
DEMO_ALL_FORMS(hpmcounter17h)

DEMO_ALL_FORMS(hpmcounter18h)
DEMO_ALL_FORMS(hpmcounter19h)
DEMO_ALL_FORMS(hpmcounter20h)

DEMO_ALL_FORMS(hpmcounter21h)
DEMO_ALL_FORMS(hpmcounter22h)
DEMO_ALL_FORMS(hpmcounter23h)

DEMO_ALL_FORMS(hpmcounter24h)
DEMO_ALL_FORMS(hpmcounter25h)
DEMO_ALL_FORMS(hpmcounter26h)

DEMO_ALL_FORMS(hpmcounter27h)
DEMO_ALL_FORMS(hpmcounter28h)
DEMO_ALL_FORMS(hpmcounter29h)

DEMO_ALL_FORMS(hpmcounter30h)
DEMO_ALL_FORMS(hpmcounter31h)

/* -- Supervisor -- */

DEMO_ALL_FORMS(sstatus)
DEMO_ALL_FORMS(sie)
DEMO_ALL_FORMS(stvec)

DEMO_ALL_FORMS(scounteren)
DEMO_ALL_FORMS(senvcfg)
DEMO_ALL_FORMS(scountinhibit)

DEMO_ALL_FORMS(sstateen0)
DEMO_ALL_FORMS(sstateen1)

DEMO_ALL_FORMS(sstateen2)
DEMO_ALL_FORMS(sstateen3)

DEMO_ALL_FORMS(sscratch)
DEMO_ALL_FORMS(sepc)
DEMO_ALL_FORMS(scause)

DEMO_ALL_FORMS(stval)
DEMO_ALL_FORMS(sip)
DEMO_ALL_FORMS(scountovf)

DEMO_ALL_FORMS(satp)
DEMO_ALL_FORMS(scontext)

DEMO_ALL_FORMS(stimecmp)
DEMO_ALL_FORMS(stimecmph)

DEMO_ALL_FORMS(siselect)
DEMO_ALL_FORMS(sireg)
DEMO_ALL_FORMS(sireg2)

DEMO_ALL_FORMS(sireg3)
DEMO_ALL_FORMS(sireg4)
DEMO_ALL_FORMS(sireg5)

DEMO_ALL_FORMS(sireg6)
DEMO_ALL_FORMS(stopei)

/* -- Hypervisor and VS -- */

DEMO_ALL_FORMS(hstatus)
DEMO_ALL_FORMS(hedeleg)
DEMO_ALL_FORMS(hideleg)

DEMO_ALL_FORMS(hie)
DEMO_ALL_FORMS(hcounteren)
DEMO_ALL_FORMS(hgeie)

DEMO_ALL_FORMS(hedelegh)

DEMO_ALL_FORMS(htval)
DEMO_ALL_FORMS(hip)
DEMO_ALL_FORMS(hvip)

DEMO_ALL_FORMS(htinst)
DEMO_ALL_FORMS(hgeip)

DEMO_ALL_FORMS(henvcfg)
DEMO_ALL_FORMS(henvcfgh)

DEMO_ALL_FORMS(hgatp)
DEMO_ALL_FORMS(hcontext)

DEMO_ALL_FORMS(htimedelta)
DEMO_ALL_FORMS(htimedeltah)

DEMO_ALL_FORMS(hstateen0)
DEMO_ALL_FORMS(hstateen1)

DEMO_ALL_FORMS(hstateen2)
DEMO_ALL_FORMS(hstateen3)

DEMO_ALL_FORMS(hstateen0h)
DEMO_ALL_FORMS(hstateen1h)

DEMO_ALL_FORMS(hstateen2h)
DEMO_ALL_FORMS(hstateen3h)

DEMO_ALL_FORMS(vsstatus)
DEMO_ALL_FORMS(vsie)
DEMO_ALL_FORMS(vstvec)

DEMO_ALL_FORMS(vsscratch)
DEMO_ALL_FORMS(vsepc)
DEMO_ALL_FORMS(vscause)

DEMO_ALL_FORMS(vstval)
DEMO_ALL_FORMS(vsip)
DEMO_ALL_FORMS(vsatp)

DEMO_ALL_FORMS(vstimecmp)
DEMO_ALL_FORMS(vstimecmph)

DEMO_ALL_FORMS(vsiselect)
DEMO_ALL_FORMS(vsireg)
DEMO_ALL_FORMS(vsireg2)

DEMO_ALL_FORMS(vsireg3)
DEMO_ALL_FORMS(vsireg4)
DEMO_ALL_FORMS(vsireg5)

DEMO_ALL_FORMS(vsireg6)
DEMO_ALL_FORMS(vstopei)

/* -- Machine -- */

DEMO_ALL_FORMS(mvendorid)
DEMO_ALL_FORMS(marchid)
DEMO_ALL_FORMS(mimpid)

DEMO_ALL_FORMS(mhartid)
DEMO_ALL_FORMS(mconfigptr)

DEMO_ALL_FORMS(mstatus)
DEMO_ALL_FORMS(misa)
DEMO_ALL_FORMS(medeleg)

DEMO_ALL_FORMS(mideleg)
DEMO_ALL_FORMS(mie)
DEMO_ALL_FORMS(mtvec)

DEMO_ALL_FORMS(mcounteren)
DEMO_ALL_FORMS(mstatush)
DEMO_ALL_FORMS(medelegh)

DEMO_ALL_FORMS(mscratch)
DEMO_ALL_FORMS(mepc)
DEMO_ALL_FORMS(mcause)

DEMO_ALL_FORMS(mtval)
DEMO_ALL_FORMS(mip)
DEMO_ALL_FORMS(mtinst)
DEMO_ALL_FORMS(mtval2)

DEMO_ALL_FORMS(menvcfg)
DEMO_ALL_FORMS(menvcfgh)

DEMO_ALL_FORMS(mseccfg)
DEMO_ALL_FORMS(mseccfgh)

DEMO_ALL_FORMS(mstateen0)
DEMO_ALL_FORMS(mstateen1)

DEMO_ALL_FORMS(mstateen2)
DEMO_ALL_FORMS(mstateen3)

DEMO_ALL_FORMS(mstateen0h)
DEMO_ALL_FORMS(mstateen1h)

DEMO_ALL_FORMS(mstateen2h)
DEMO_ALL_FORMS(mstateen3h)

DEMO_ALL_FORMS(pmpcfg0)
DEMO_ALL_FORMS(pmpcfg1)
DEMO_ALL_FORMS(pmpcfg2)

DEMO_ALL_FORMS(pmpcfg3)
DEMO_ALL_FORMS(pmpcfg4)
DEMO_ALL_FORMS(pmpcfg5)

DEMO_ALL_FORMS(pmpcfg6)
DEMO_ALL_FORMS(pmpcfg7)
DEMO_ALL_FORMS(pmpcfg8)

DEMO_ALL_FORMS(pmpcfg9)
DEMO_ALL_FORMS(pmpcfg10)
DEMO_ALL_FORMS(pmpcfg11)

DEMO_ALL_FORMS(pmpcfg12)
DEMO_ALL_FORMS(pmpcfg13)
DEMO_ALL_FORMS(pmpcfg14)

DEMO_ALL_FORMS(pmpcfg15)

DEMO_ALL_FORMS(pmpaddr0)
DEMO_ALL_FORMS(pmpaddr1)
DEMO_ALL_FORMS(pmpaddr2)

DEMO_ALL_FORMS(pmpaddr3)
DEMO_ALL_FORMS(pmpaddr4)
DEMO_ALL_FORMS(pmpaddr5)

DEMO_ALL_FORMS(pmpaddr6)
DEMO_ALL_FORMS(pmpaddr7)
DEMO_ALL_FORMS(pmpaddr8)

DEMO_ALL_FORMS(pmpaddr9)
DEMO_ALL_FORMS(pmpaddr10)
DEMO_ALL_FORMS(pmpaddr11)

DEMO_ALL_FORMS(pmpaddr12)
DEMO_ALL_FORMS(pmpaddr13)
DEMO_ALL_FORMS(pmpaddr14)

DEMO_ALL_FORMS(pmpaddr15)
DEMO_ALL_FORMS(pmpaddr16)
DEMO_ALL_FORMS(pmpaddr17)

DEMO_ALL_FORMS(pmpaddr18)
DEMO_ALL_FORMS(pmpaddr19)
DEMO_ALL_FORMS(pmpaddr20)

DEMO_ALL_FORMS(pmpaddr21)
DEMO_ALL_FORMS(pmpaddr22)
DEMO_ALL_FORMS(pmpaddr23)

DEMO_ALL_FORMS(pmpaddr24)
DEMO_ALL_FORMS(pmpaddr25)
DEMO_ALL_FORMS(pmpaddr26)

DEMO_ALL_FORMS(pmpaddr27)
DEMO_ALL_FORMS(pmpaddr28)
DEMO_ALL_FORMS(pmpaddr29)

DEMO_ALL_FORMS(pmpaddr30)
DEMO_ALL_FORMS(pmpaddr31)
DEMO_ALL_FORMS(pmpaddr32)

DEMO_ALL_FORMS(pmpaddr33)
DEMO_ALL_FORMS(pmpaddr34)
DEMO_ALL_FORMS(pmpaddr35)

DEMO_ALL_FORMS(pmpaddr36)
DEMO_ALL_FORMS(pmpaddr37)
DEMO_ALL_FORMS(pmpaddr38)

DEMO_ALL_FORMS(pmpaddr39)
DEMO_ALL_FORMS(pmpaddr40)
DEMO_ALL_FORMS(pmpaddr41)

DEMO_ALL_FORMS(pmpaddr42)
DEMO_ALL_FORMS(pmpaddr43)
DEMO_ALL_FORMS(pmpaddr44)

DEMO_ALL_FORMS(pmpaddr45)
DEMO_ALL_FORMS(pmpaddr46)
DEMO_ALL_FORMS(pmpaddr47)

DEMO_ALL_FORMS(pmpaddr48)
DEMO_ALL_FORMS(pmpaddr49)
DEMO_ALL_FORMS(pmpaddr50)

DEMO_ALL_FORMS(pmpaddr51)
DEMO_ALL_FORMS(pmpaddr52)
DEMO_ALL_FORMS(pmpaddr53)

DEMO_ALL_FORMS(pmpaddr54)
DEMO_ALL_FORMS(pmpaddr55)
DEMO_ALL_FORMS(pmpaddr56)

DEMO_ALL_FORMS(pmpaddr57)
DEMO_ALL_FORMS(pmpaddr58)
DEMO_ALL_FORMS(pmpaddr59)

DEMO_ALL_FORMS(pmpaddr60)
DEMO_ALL_FORMS(pmpaddr61)
DEMO_ALL_FORMS(pmpaddr62)

DEMO_ALL_FORMS(pmpaddr63)

DEMO_ALL_FORMS(mnscratch)
DEMO_ALL_FORMS(mnepc)

DEMO_ALL_FORMS(mncause)
DEMO_ALL_FORMS(mnstatus)

DEMO_ALL_FORMS(mcycle)
DEMO_ALL_FORMS(minstret)

DEMO_ALL_FORMS(mhpmcounter3)
DEMO_ALL_FORMS(mhpmcounter4)
DEMO_ALL_FORMS(mhpmcounter5)

DEMO_ALL_FORMS(mhpmcounter6)
DEMO_ALL_FORMS(mhpmcounter7)
DEMO_ALL_FORMS(mhpmcounter8)

DEMO_ALL_FORMS(mhpmcounter9)
DEMO_ALL_FORMS(mhpmcounter10)
DEMO_ALL_FORMS(mhpmcounter11)

DEMO_ALL_FORMS(mhpmcounter12)
DEMO_ALL_FORMS(mhpmcounter13)
DEMO_ALL_FORMS(mhpmcounter14)

DEMO_ALL_FORMS(mhpmcounter15)
DEMO_ALL_FORMS(mhpmcounter16)
DEMO_ALL_FORMS(mhpmcounter17)

DEMO_ALL_FORMS(mhpmcounter18)
DEMO_ALL_FORMS(mhpmcounter19)
DEMO_ALL_FORMS(mhpmcounter20)

DEMO_ALL_FORMS(mhpmcounter21)
DEMO_ALL_FORMS(mhpmcounter22)
DEMO_ALL_FORMS(mhpmcounter23)

DEMO_ALL_FORMS(mhpmcounter24)
DEMO_ALL_FORMS(mhpmcounter25)
DEMO_ALL_FORMS(mhpmcounter26)

DEMO_ALL_FORMS(mhpmcounter27)
DEMO_ALL_FORMS(mhpmcounter28)
DEMO_ALL_FORMS(mhpmcounter29)

DEMO_ALL_FORMS(mhpmcounter30)
DEMO_ALL_FORMS(mhpmcounter31)

DEMO_ALL_FORMS(mcycleh)
DEMO_ALL_FORMS(minstreth)

DEMO_ALL_FORMS(mhpmcounter3h)
DEMO_ALL_FORMS(mhpmcounter4h)
DEMO_ALL_FORMS(mhpmcounter5h)

DEMO_ALL_FORMS(mhpmcounter6h)
DEMO_ALL_FORMS(mhpmcounter7h)
DEMO_ALL_FORMS(mhpmcounter8h)

DEMO_ALL_FORMS(mhpmcounter9h)
DEMO_ALL_FORMS(mhpmcounter10h)
DEMO_ALL_FORMS(mhpmcounter11h)

DEMO_ALL_FORMS(mhpmcounter12h)
DEMO_ALL_FORMS(mhpmcounter13h)
DEMO_ALL_FORMS(mhpmcounter14h)

DEMO_ALL_FORMS(mhpmcounter15h)
DEMO_ALL_FORMS(mhpmcounter16h)
DEMO_ALL_FORMS(mhpmcounter17h)

DEMO_ALL_FORMS(mhpmcounter18h)
DEMO_ALL_FORMS(mhpmcounter19h)
DEMO_ALL_FORMS(mhpmcounter20h)

DEMO_ALL_FORMS(mhpmcounter21h)
DEMO_ALL_FORMS(mhpmcounter22h)
DEMO_ALL_FORMS(mhpmcounter23h)

DEMO_ALL_FORMS(mhpmcounter24h)
DEMO_ALL_FORMS(mhpmcounter25h)
DEMO_ALL_FORMS(mhpmcounter26h)

DEMO_ALL_FORMS(mhpmcounter27h)
DEMO_ALL_FORMS(mhpmcounter28h)
DEMO_ALL_FORMS(mhpmcounter29h)

DEMO_ALL_FORMS(mhpmcounter30h)
DEMO_ALL_FORMS(mhpmcounter31h)

DEMO_ALL_FORMS(mcountinhibit)
DEMO_ALL_FORMS(mcyclecfg)
DEMO_ALL_FORMS(minstretcfg)

DEMO_ALL_FORMS(mhpmevent3)
DEMO_ALL_FORMS(mhpmevent4)
DEMO_ALL_FORMS(mhpmevent5)

DEMO_ALL_FORMS(mhpmevent6)
DEMO_ALL_FORMS(mhpmevent7)
DEMO_ALL_FORMS(mhpmevent8)

DEMO_ALL_FORMS(mhpmevent9)
DEMO_ALL_FORMS(mhpmevent10)
DEMO_ALL_FORMS(mhpmevent11)

DEMO_ALL_FORMS(mhpmevent12)
DEMO_ALL_FORMS(mhpmevent13)
DEMO_ALL_FORMS(mhpmevent14)

DEMO_ALL_FORMS(mhpmevent15)
DEMO_ALL_FORMS(mhpmevent16)
DEMO_ALL_FORMS(mhpmevent17)

DEMO_ALL_FORMS(mhpmevent18)
DEMO_ALL_FORMS(mhpmevent19)
DEMO_ALL_FORMS(mhpmevent20)

DEMO_ALL_FORMS(mhpmevent21)
DEMO_ALL_FORMS(mhpmevent22)
DEMO_ALL_FORMS(mhpmevent23)

DEMO_ALL_FORMS(mhpmevent24)
DEMO_ALL_FORMS(mhpmevent25)
DEMO_ALL_FORMS(mhpmevent26)

DEMO_ALL_FORMS(mhpmevent27)
DEMO_ALL_FORMS(mhpmevent28)
DEMO_ALL_FORMS(mhpmevent29)

DEMO_ALL_FORMS(mhpmevent30)
DEMO_ALL_FORMS(mhpmevent31)

DEMO_ALL_FORMS(mcyclecfgh)
DEMO_ALL_FORMS(minstretcfgh)

DEMO_ALL_FORMS(mhpmevent3h)
DEMO_ALL_FORMS(mhpmevent4h)
DEMO_ALL_FORMS(mhpmevent5h)

DEMO_ALL_FORMS(mhpmevent6h)
DEMO_ALL_FORMS(mhpmevent7h)
DEMO_ALL_FORMS(mhpmevent8h)

DEMO_ALL_FORMS(mhpmevent9h)
DEMO_ALL_FORMS(mhpmevent10h)
DEMO_ALL_FORMS(mhpmevent11h)

DEMO_ALL_FORMS(mhpmevent12h)
DEMO_ALL_FORMS(mhpmevent13h)
DEMO_ALL_FORMS(mhpmevent14h)

DEMO_ALL_FORMS(mhpmevent15h)
DEMO_ALL_FORMS(mhpmevent16h)
DEMO_ALL_FORMS(mhpmevent17h)

DEMO_ALL_FORMS(mhpmevent18h)
DEMO_ALL_FORMS(mhpmevent19h)
DEMO_ALL_FORMS(mhpmevent20h)

DEMO_ALL_FORMS(mhpmevent21h)
DEMO_ALL_FORMS(mhpmevent22h)
DEMO_ALL_FORMS(mhpmevent23h)

DEMO_ALL_FORMS(mhpmevent24h)
DEMO_ALL_FORMS(mhpmevent25h)
DEMO_ALL_FORMS(mhpmevent26h)

DEMO_ALL_FORMS(mhpmevent27h)
DEMO_ALL_FORMS(mhpmevent28h)
DEMO_ALL_FORMS(mhpmevent29h)

DEMO_ALL_FORMS(mhpmevent30h)
DEMO_ALL_FORMS(mhpmevent31h)

DEMO_ALL_FORMS(tselect)
DEMO_ALL_FORMS(tdata1)
DEMO_ALL_FORMS(tdata2)

DEMO_ALL_FORMS(tdata3)
DEMO_ALL_FORMS(tinfo)
DEMO_ALL_FORMS(tcontrol)

DEMO_ALL_FORMS(mcontext)
DEMO_ALL_FORMS(mscontext)
/* Debug Mode only: illegal from M-mode.

DEMO_ALL_FORMS(dcsr)
DEMO_ALL_FORMS(dpc)

DEMO_ALL_FORMS(dscratch0)
DEMO_ALL_FORMS(dscratch1) */

DEMO_ALL_FORMS(miselect)
DEMO_ALL_FORMS(mireg)
DEMO_ALL_FORMS(mireg2)

DEMO_ALL_FORMS(mireg3)
DEMO_ALL_FORMS(mireg4)
DEMO_ALL_FORMS(mireg5)

DEMO_ALL_FORMS(mireg6)
DEMO_ALL_FORMS(mtopei)

/* =========================================================================
 * Section 6 — main()
 * Calls every RO function then every RW function.
 * Order within each half: Unprivileged → Supervisor → Hypervisor/VS → Machine
 * ========================================================================= */
int main(void) {
	/* ---- RO: Unprivileged ---- */
	csr_ro_fflags();
	csr_ro_frm();
	csr_ro_fcsr();
	csr_ro_cycle();
	csr_ro_time();
	csr_ro_instret();
	csr_ro_hpmcounter3();
	csr_ro_hpmcounter4();
	csr_ro_hpmcounter5();
	csr_ro_hpmcounter6();
	csr_ro_hpmcounter7();
	csr_ro_hpmcounter8();
	csr_ro_hpmcounter9();
	csr_ro_hpmcounter10();
	csr_ro_hpmcounter11();
	csr_ro_hpmcounter12();
	csr_ro_hpmcounter13();
	csr_ro_hpmcounter14();
	csr_ro_hpmcounter15();
	csr_ro_hpmcounter16();
	csr_ro_hpmcounter17();
	csr_ro_hpmcounter18();
	csr_ro_hpmcounter19();
	csr_ro_hpmcounter20();
	csr_ro_hpmcounter21();
	csr_ro_hpmcounter22();
	csr_ro_hpmcounter23();
	csr_ro_hpmcounter24();
	csr_ro_hpmcounter25();
	csr_ro_hpmcounter26();
	csr_ro_hpmcounter27();
	csr_ro_hpmcounter28();
	csr_ro_hpmcounter29();
	csr_ro_hpmcounter30();
	csr_ro_hpmcounter31();
	csr_ro_cycleh();
	csr_ro_timeh();
	csr_ro_instreth();
	csr_ro_hpmcounter3h();
	csr_ro_hpmcounter4h();
	csr_ro_hpmcounter5h();
	csr_ro_hpmcounter6h();
	csr_ro_hpmcounter7h();
	csr_ro_hpmcounter8h();
	csr_ro_hpmcounter9h();
	csr_ro_hpmcounter10h();
	csr_ro_hpmcounter11h();
	csr_ro_hpmcounter12h();
	csr_ro_hpmcounter13h();
	csr_ro_hpmcounter14h();
	csr_ro_hpmcounter15h();
	csr_ro_hpmcounter16h();
	csr_ro_hpmcounter17h();
	csr_ro_hpmcounter18h();
	csr_ro_hpmcounter19h();
	csr_ro_hpmcounter20h();
	csr_ro_hpmcounter21h();
	csr_ro_hpmcounter22h();
	csr_ro_hpmcounter23h();
	csr_ro_hpmcounter24h();
	csr_ro_hpmcounter25h();
	csr_ro_hpmcounter26h();
	csr_ro_hpmcounter27h();
	csr_ro_hpmcounter28h();
	csr_ro_hpmcounter29h();
	csr_ro_hpmcounter30h();
	csr_ro_hpmcounter31h();
	/* ---- RO: Supervisor ---- */
	csr_ro_sstatus();
	csr_ro_sie();
	csr_ro_stvec();
	csr_ro_scounteren();
	csr_ro_senvcfg();
	csr_ro_scountinhibit();
	csr_ro_sstateen0();
	csr_ro_sstateen1();
	csr_ro_sstateen2();
	csr_ro_sstateen3();
	csr_ro_sscratch();
	csr_ro_sepc();
	csr_ro_scause();
	csr_ro_stval();
	csr_ro_sip();
	csr_ro_scountovf();
	csr_ro_satp();
	csr_ro_scontext();
	csr_ro_stimecmp();
	csr_ro_stimecmph();
	csr_ro_siselect();
	csr_ro_sireg();
	csr_ro_sireg2();
	csr_ro_sireg3();
	csr_ro_sireg4();
	csr_ro_sireg5();
	csr_ro_sireg6();
	csr_ro_stopei();
	/* ---- RO: Hypervisor and VS ---- */
	csr_ro_hstatus();
	csr_ro_hedeleg();
	csr_ro_hideleg();
	csr_ro_hie();
	csr_ro_hcounteren();
	csr_ro_hgeie();
	csr_ro_hedelegh();
	csr_ro_htval();
	csr_ro_hip();
	csr_ro_hvip();
	csr_ro_htinst();
	csr_ro_hgeip();
	csr_ro_henvcfg();
	csr_ro_henvcfgh();
	csr_ro_hgatp();
	csr_ro_hcontext();
	csr_ro_htimedelta();
	csr_ro_htimedeltah();
	csr_ro_hstateen0();
	csr_ro_hstateen1();
	csr_ro_hstateen2();
	csr_ro_hstateen3();
	csr_ro_hstateen0h();
	csr_ro_hstateen1h();
	csr_ro_hstateen2h();
	csr_ro_hstateen3h();
	csr_ro_vsstatus();
	csr_ro_vsie();
	csr_ro_vstvec();
	csr_ro_vsscratch();
	csr_ro_vsepc();
	csr_ro_vscause();
	csr_ro_vstval();
	csr_ro_vsip();
	csr_ro_vsatp();
	csr_ro_vstimecmp();
	csr_ro_vstimecmph();
	csr_ro_vsiselect();
	csr_ro_vsireg();
	csr_ro_vsireg2();
	csr_ro_vsireg3();
	csr_ro_vsireg4();
	csr_ro_vsireg5();
	csr_ro_vsireg6();
	csr_ro_vstopei();
	/* ---- RO: Machine ---- */
	csr_ro_mvendorid();
	csr_ro_marchid();
	csr_ro_mimpid();
	csr_ro_mhartid();
	csr_ro_mconfigptr();
	csr_ro_mstatus();
	csr_ro_misa();
	csr_ro_medeleg();
	csr_ro_mideleg();
	csr_ro_mie();
	csr_ro_mtvec();
	csr_ro_mcounteren();
	csr_ro_mstatush();
	csr_ro_medelegh();
	csr_ro_mscratch();
	csr_ro_mepc();
	csr_ro_mcause();
	csr_ro_mtval();
	csr_ro_mip();
	csr_ro_mtinst();
	csr_ro_mtval2();
	csr_ro_menvcfg();
	csr_ro_menvcfgh();
	csr_ro_mseccfg();
	csr_ro_mseccfgh();
	csr_ro_mstateen0();
	csr_ro_mstateen1();
	csr_ro_mstateen2();
	csr_ro_mstateen3();
	csr_ro_mstateen0h();
	csr_ro_mstateen1h();
	csr_ro_mstateen2h();
	csr_ro_mstateen3h();
	csr_ro_pmpcfg0();
	csr_ro_pmpcfg1();
	csr_ro_pmpcfg2();
	csr_ro_pmpcfg3();
	csr_ro_pmpcfg4();
	csr_ro_pmpcfg5();
	csr_ro_pmpcfg6();
	csr_ro_pmpcfg7();
	csr_ro_pmpcfg8();
	csr_ro_pmpcfg9();
	csr_ro_pmpcfg10();
	csr_ro_pmpcfg11();
	csr_ro_pmpcfg12();
	csr_ro_pmpcfg13();
	csr_ro_pmpcfg14();
	csr_ro_pmpcfg15();
	csr_ro_pmpaddr0();
	csr_ro_pmpaddr1();
	csr_ro_pmpaddr2();
	csr_ro_pmpaddr3();
	csr_ro_pmpaddr4();
	csr_ro_pmpaddr5();
	csr_ro_pmpaddr6();
	csr_ro_pmpaddr7();
	csr_ro_pmpaddr8();
	csr_ro_pmpaddr9();
	csr_ro_pmpaddr10();
	csr_ro_pmpaddr11();
	csr_ro_pmpaddr12();
	csr_ro_pmpaddr13();
	csr_ro_pmpaddr14();
	csr_ro_pmpaddr15();
	csr_ro_pmpaddr16();
	csr_ro_pmpaddr17();
	csr_ro_pmpaddr18();
	csr_ro_pmpaddr19();
	csr_ro_pmpaddr20();
	csr_ro_pmpaddr21();
	csr_ro_pmpaddr22();
	csr_ro_pmpaddr23();
	csr_ro_pmpaddr24();
	csr_ro_pmpaddr25();
	csr_ro_pmpaddr26();
	csr_ro_pmpaddr27();
	csr_ro_pmpaddr28();
	csr_ro_pmpaddr29();
	csr_ro_pmpaddr30();
	csr_ro_pmpaddr31();
	csr_ro_pmpaddr32();
	csr_ro_pmpaddr33();
	csr_ro_pmpaddr34();
	csr_ro_pmpaddr35();
	csr_ro_pmpaddr36();
	csr_ro_pmpaddr37();
	csr_ro_pmpaddr38();
	csr_ro_pmpaddr39();
	csr_ro_pmpaddr40();
	csr_ro_pmpaddr41();
	csr_ro_pmpaddr42();
	csr_ro_pmpaddr43();
	csr_ro_pmpaddr44();
	csr_ro_pmpaddr45();
	csr_ro_pmpaddr46();
	csr_ro_pmpaddr47();
	csr_ro_pmpaddr48();
	csr_ro_pmpaddr49();
	csr_ro_pmpaddr50();
	csr_ro_pmpaddr51();
	csr_ro_pmpaddr52();
	csr_ro_pmpaddr53();
	csr_ro_pmpaddr54();
	csr_ro_pmpaddr55();
	csr_ro_pmpaddr56();
	csr_ro_pmpaddr57();
	csr_ro_pmpaddr58();
	csr_ro_pmpaddr59();
	csr_ro_pmpaddr60();
	csr_ro_pmpaddr61();
	csr_ro_pmpaddr62();
	csr_ro_pmpaddr63();
	csr_ro_mnscratch();
	csr_ro_mnepc();
	csr_ro_mncause();
	csr_ro_mnstatus();
	csr_ro_mcycle();
	csr_ro_minstret();
	csr_ro_mhpmcounter3();
	csr_ro_mhpmcounter4();
	csr_ro_mhpmcounter5();
	csr_ro_mhpmcounter6();
	csr_ro_mhpmcounter7();
	csr_ro_mhpmcounter8();
	csr_ro_mhpmcounter9();
	csr_ro_mhpmcounter10();
	csr_ro_mhpmcounter11();
	csr_ro_mhpmcounter12();
	csr_ro_mhpmcounter13();
	csr_ro_mhpmcounter14();
	csr_ro_mhpmcounter15();
	csr_ro_mhpmcounter16();
	csr_ro_mhpmcounter17();
	csr_ro_mhpmcounter18();
	csr_ro_mhpmcounter19();
	csr_ro_mhpmcounter20();
	csr_ro_mhpmcounter21();
	csr_ro_mhpmcounter22();
	csr_ro_mhpmcounter23();
	csr_ro_mhpmcounter24();
	csr_ro_mhpmcounter25();
	csr_ro_mhpmcounter26();
	csr_ro_mhpmcounter27();
	csr_ro_mhpmcounter28();
	csr_ro_mhpmcounter29();
	csr_ro_mhpmcounter30();
	csr_ro_mhpmcounter31();
	csr_ro_mcycleh();
	csr_ro_minstreth();
	csr_ro_mhpmcounter3h();
	csr_ro_mhpmcounter4h();
	csr_ro_mhpmcounter5h();
	csr_ro_mhpmcounter6h();
	csr_ro_mhpmcounter7h();
	csr_ro_mhpmcounter8h();
	csr_ro_mhpmcounter9h();
	csr_ro_mhpmcounter10h();
	csr_ro_mhpmcounter11h();
	csr_ro_mhpmcounter12h();
	csr_ro_mhpmcounter13h();
	csr_ro_mhpmcounter14h();
	csr_ro_mhpmcounter15h();
	csr_ro_mhpmcounter16h();
	csr_ro_mhpmcounter17h();
	csr_ro_mhpmcounter18h();
	csr_ro_mhpmcounter19h();
	csr_ro_mhpmcounter20h();
	csr_ro_mhpmcounter21h();
	csr_ro_mhpmcounter22h();
	csr_ro_mhpmcounter23h();
	csr_ro_mhpmcounter24h();
	csr_ro_mhpmcounter25h();
	csr_ro_mhpmcounter26h();
	csr_ro_mhpmcounter27h();
	csr_ro_mhpmcounter28h();
	csr_ro_mhpmcounter29h();
	csr_ro_mhpmcounter30h();
	csr_ro_mhpmcounter31h();
	csr_ro_mcountinhibit();
	csr_ro_mcyclecfg();
	csr_ro_minstretcfg();
	csr_ro_mhpmevent3();
	csr_ro_mhpmevent4();
	csr_ro_mhpmevent5();
	csr_ro_mhpmevent6();
	csr_ro_mhpmevent7();
	csr_ro_mhpmevent8();
	csr_ro_mhpmevent9();
	csr_ro_mhpmevent10();
	csr_ro_mhpmevent11();
	csr_ro_mhpmevent12();
	csr_ro_mhpmevent13();
	csr_ro_mhpmevent14();
	csr_ro_mhpmevent15();
	csr_ro_mhpmevent16();
	csr_ro_mhpmevent17();
	csr_ro_mhpmevent18();
	csr_ro_mhpmevent19();
	csr_ro_mhpmevent20();
	csr_ro_mhpmevent21();
	csr_ro_mhpmevent22();
	csr_ro_mhpmevent23();
	csr_ro_mhpmevent24();
	csr_ro_mhpmevent25();
	csr_ro_mhpmevent26();
	csr_ro_mhpmevent27();
	csr_ro_mhpmevent28();
	csr_ro_mhpmevent29();
	csr_ro_mhpmevent30();
	csr_ro_mhpmevent31();
	csr_ro_mcyclecfgh();
	csr_ro_minstretcfgh();
	csr_ro_mhpmevent3h();
	csr_ro_mhpmevent4h();
	csr_ro_mhpmevent5h();
	csr_ro_mhpmevent6h();
	csr_ro_mhpmevent7h();
	csr_ro_mhpmevent8h();
	csr_ro_mhpmevent9h();
	csr_ro_mhpmevent10h();
	csr_ro_mhpmevent11h();
	csr_ro_mhpmevent12h();
	csr_ro_mhpmevent13h();
	csr_ro_mhpmevent14h();
	csr_ro_mhpmevent15h();
	csr_ro_mhpmevent16h();
	csr_ro_mhpmevent17h();
	csr_ro_mhpmevent18h();
	csr_ro_mhpmevent19h();
	csr_ro_mhpmevent20h();
	csr_ro_mhpmevent21h();
	csr_ro_mhpmevent22h();
	csr_ro_mhpmevent23h();
	csr_ro_mhpmevent24h();
	csr_ro_mhpmevent25h();
	csr_ro_mhpmevent26h();
	csr_ro_mhpmevent27h();
	csr_ro_mhpmevent28h();
	csr_ro_mhpmevent29h();
	csr_ro_mhpmevent30h();
	csr_ro_mhpmevent31h();
	csr_ro_tselect();
	csr_ro_tdata1();
	csr_ro_tdata2();
	csr_ro_tdata3();
	csr_ro_tinfo();
	csr_ro_tcontrol();
	csr_ro_mcontext();
	csr_ro_mscontext();
	csr_ro_miselect();
	csr_ro_mireg();
	csr_ro_mireg2();
	csr_ro_mireg3();
	csr_ro_mireg4();
	csr_ro_mireg5();
	csr_ro_mireg6();
	csr_ro_mtopei();

	/* ---- RW: Unprivileged ---- */
	csr_rw_fflags();
	csr_rw_frm();
	csr_rw_fcsr();
	csr_rw_cycle();
	csr_rw_time();
	csr_rw_instret();
	csr_rw_hpmcounter3();
	csr_rw_hpmcounter4();
	csr_rw_hpmcounter5();
	csr_rw_hpmcounter6();
	csr_rw_hpmcounter7();
	csr_rw_hpmcounter8();
	csr_rw_hpmcounter9();
	csr_rw_hpmcounter10();
	csr_rw_hpmcounter11();
	csr_rw_hpmcounter12();
	csr_rw_hpmcounter13();
	csr_rw_hpmcounter14();
	csr_rw_hpmcounter15();
	csr_rw_hpmcounter16();
	csr_rw_hpmcounter17();
	csr_rw_hpmcounter18();
	csr_rw_hpmcounter19();
	csr_rw_hpmcounter20();
	csr_rw_hpmcounter21();
	csr_rw_hpmcounter22();
	csr_rw_hpmcounter23();
	csr_rw_hpmcounter24();
	csr_rw_hpmcounter25();
	csr_rw_hpmcounter26();
	csr_rw_hpmcounter27();
	csr_rw_hpmcounter28();
	csr_rw_hpmcounter29();
	csr_rw_hpmcounter30();
	csr_rw_hpmcounter31();
	csr_rw_cycleh();
	csr_rw_timeh();
	csr_rw_instreth();
	csr_rw_hpmcounter3h();
	csr_rw_hpmcounter4h();
	csr_rw_hpmcounter5h();
	csr_rw_hpmcounter6h();
	csr_rw_hpmcounter7h();
	csr_rw_hpmcounter8h();
	csr_rw_hpmcounter9h();
	csr_rw_hpmcounter10h();
	csr_rw_hpmcounter11h();
	csr_rw_hpmcounter12h();
	csr_rw_hpmcounter13h();
	csr_rw_hpmcounter14h();
	csr_rw_hpmcounter15h();
	csr_rw_hpmcounter16h();
	csr_rw_hpmcounter17h();
	csr_rw_hpmcounter18h();
	csr_rw_hpmcounter19h();
	csr_rw_hpmcounter20h();
	csr_rw_hpmcounter21h();
	csr_rw_hpmcounter22h();
	csr_rw_hpmcounter23h();
	csr_rw_hpmcounter24h();
	csr_rw_hpmcounter25h();
	csr_rw_hpmcounter26h();
	csr_rw_hpmcounter27h();
	csr_rw_hpmcounter28h();
	csr_rw_hpmcounter29h();
	csr_rw_hpmcounter30h();
	csr_rw_hpmcounter31h();
	/* ---- RW: Supervisor ---- */
	csr_rw_sstatus();
	csr_rw_sie();
	csr_rw_stvec();
	csr_rw_scounteren();
	csr_rw_senvcfg();
	csr_rw_scountinhibit();
	csr_rw_sstateen0();
	csr_rw_sstateen1();
	csr_rw_sstateen2();
	csr_rw_sstateen3();
	csr_rw_sscratch();
	csr_rw_sepc();
	csr_rw_scause();
	csr_rw_stval();
	csr_rw_sip();
	csr_rw_scountovf();
	csr_rw_satp();
	csr_rw_scontext();
	csr_rw_stimecmp();
	csr_rw_stimecmph();
	csr_rw_siselect();
	csr_rw_sireg();
	csr_rw_sireg2();
	csr_rw_sireg3();
	csr_rw_sireg4();
	csr_rw_sireg5();
	csr_rw_sireg6();
	csr_rw_stopei();
	/* ---- RW: Hypervisor and VS ---- */
	csr_rw_hstatus();
	csr_rw_hedeleg();
	csr_rw_hideleg();
	csr_rw_hie();
	csr_rw_hcounteren();
	csr_rw_hgeie();
	csr_rw_hedelegh();
	csr_rw_htval();
	csr_rw_hip();
	csr_rw_hvip();
	csr_rw_htinst();
	csr_rw_hgeip();
	csr_rw_henvcfg();
	csr_rw_henvcfgh();
	csr_rw_hgatp();
	csr_rw_hcontext();
	csr_rw_htimedelta();
	csr_rw_htimedeltah();
	csr_rw_hstateen0();
	csr_rw_hstateen1();
	csr_rw_hstateen2();
	csr_rw_hstateen3();
	csr_rw_hstateen0h();
	csr_rw_hstateen1h();
	csr_rw_hstateen2h();
	csr_rw_hstateen3h();
	csr_rw_vsstatus();
	csr_rw_vsie();
	csr_rw_vstvec();
	csr_rw_vsscratch();
	csr_rw_vsepc();
	csr_rw_vscause();
	csr_rw_vstval();
	csr_rw_vsip();
	csr_rw_vsatp();
	csr_rw_vstimecmp();
	csr_rw_vstimecmph();
	csr_rw_vsiselect();
	csr_rw_vsireg();
	csr_rw_vsireg2();
	csr_rw_vsireg3();
	csr_rw_vsireg4();
	csr_rw_vsireg5();
	csr_rw_vsireg6();
	csr_rw_vstopei();
	/* ---- RW: Machine ---- */
	csr_rw_mvendorid();
	csr_rw_marchid();
	csr_rw_mimpid();
	csr_rw_mhartid();
	csr_rw_mconfigptr();
	csr_rw_mstatus();
	csr_rw_misa();
	csr_rw_medeleg();
	csr_rw_mideleg();
	csr_rw_mie();
	csr_rw_mtvec();
	csr_rw_mcounteren();
	csr_rw_mstatush();
	csr_rw_medelegh();
	csr_rw_mscratch();
	csr_rw_mepc();
	csr_rw_mcause();
	csr_rw_mtval();
	csr_rw_mip();
	csr_rw_mtinst();
	csr_rw_mtval2();
	csr_rw_menvcfg();
	csr_rw_menvcfgh();
	csr_rw_mseccfg();
	csr_rw_mseccfgh();
	csr_rw_mstateen0();
	csr_rw_mstateen1();
	csr_rw_mstateen2();
	csr_rw_mstateen3();
	csr_rw_mstateen0h();
	csr_rw_mstateen1h();
	csr_rw_mstateen2h();
	csr_rw_mstateen3h();
	csr_rw_pmpcfg0();
	csr_rw_pmpcfg1();
	csr_rw_pmpcfg2();
	csr_rw_pmpcfg3();
	csr_rw_pmpcfg4();
	csr_rw_pmpcfg5();
	csr_rw_pmpcfg6();
	csr_rw_pmpcfg7();
	csr_rw_pmpcfg8();
	csr_rw_pmpcfg9();
	csr_rw_pmpcfg10();
	csr_rw_pmpcfg11();
	csr_rw_pmpcfg12();
	csr_rw_pmpcfg13();
	csr_rw_pmpcfg14();
	csr_rw_pmpcfg15();
	csr_rw_pmpaddr0();
	csr_rw_pmpaddr1();
	csr_rw_pmpaddr2();
	csr_rw_pmpaddr3();
	csr_rw_pmpaddr4();
	csr_rw_pmpaddr5();
	csr_rw_pmpaddr6();
	csr_rw_pmpaddr7();
	csr_rw_pmpaddr8();
	csr_rw_pmpaddr9();
	csr_rw_pmpaddr10();
	csr_rw_pmpaddr11();
	csr_rw_pmpaddr12();
	csr_rw_pmpaddr13();
	csr_rw_pmpaddr14();
	csr_rw_pmpaddr15();
	csr_rw_pmpaddr16();
	csr_rw_pmpaddr17();
	csr_rw_pmpaddr18();
	csr_rw_pmpaddr19();
	csr_rw_pmpaddr20();
	csr_rw_pmpaddr21();
	csr_rw_pmpaddr22();
	csr_rw_pmpaddr23();
	csr_rw_pmpaddr24();
	csr_rw_pmpaddr25();
	csr_rw_pmpaddr26();
	csr_rw_pmpaddr27();
	csr_rw_pmpaddr28();
	csr_rw_pmpaddr29();
	csr_rw_pmpaddr30();
	csr_rw_pmpaddr31();
	csr_rw_pmpaddr32();
	csr_rw_pmpaddr33();
	csr_rw_pmpaddr34();
	csr_rw_pmpaddr35();
	csr_rw_pmpaddr36();
	csr_rw_pmpaddr37();
	csr_rw_pmpaddr38();
	csr_rw_pmpaddr39();
	csr_rw_pmpaddr40();
	csr_rw_pmpaddr41();
	csr_rw_pmpaddr42();
	csr_rw_pmpaddr43();
	csr_rw_pmpaddr44();
	csr_rw_pmpaddr45();
	csr_rw_pmpaddr46();
	csr_rw_pmpaddr47();
	csr_rw_pmpaddr48();
	csr_rw_pmpaddr49();
	csr_rw_pmpaddr50();
	csr_rw_pmpaddr51();
	csr_rw_pmpaddr52();
	csr_rw_pmpaddr53();
	csr_rw_pmpaddr54();
	csr_rw_pmpaddr55();
	csr_rw_pmpaddr56();
	csr_rw_pmpaddr57();
	csr_rw_pmpaddr58();
	csr_rw_pmpaddr59();
	csr_rw_pmpaddr60();
	csr_rw_pmpaddr61();
	csr_rw_pmpaddr62();
	csr_rw_pmpaddr63();
	csr_rw_mnscratch();
	csr_rw_mnepc();
	csr_rw_mncause();
	csr_rw_mnstatus();
	csr_rw_mcycle();
	csr_rw_minstret();
	csr_rw_mhpmcounter3();
	csr_rw_mhpmcounter4();
	csr_rw_mhpmcounter5();
	csr_rw_mhpmcounter6();
	csr_rw_mhpmcounter7();
	csr_rw_mhpmcounter8();
	csr_rw_mhpmcounter9();
	csr_rw_mhpmcounter10();
	csr_rw_mhpmcounter11();
	csr_rw_mhpmcounter12();
	csr_rw_mhpmcounter13();
	csr_rw_mhpmcounter14();
	csr_rw_mhpmcounter15();
	csr_rw_mhpmcounter16();
	csr_rw_mhpmcounter17();
	csr_rw_mhpmcounter18();
	csr_rw_mhpmcounter19();
	csr_rw_mhpmcounter20();
	csr_rw_mhpmcounter21();
	csr_rw_mhpmcounter22();
	csr_rw_mhpmcounter23();
	csr_rw_mhpmcounter24();
	csr_rw_mhpmcounter25();
	csr_rw_mhpmcounter26();
	csr_rw_mhpmcounter27();
	csr_rw_mhpmcounter28();
	csr_rw_mhpmcounter29();
	csr_rw_mhpmcounter30();
	csr_rw_mhpmcounter31();
	csr_rw_mcycleh();
	csr_rw_minstreth();
	csr_rw_mhpmcounter3h();
	csr_rw_mhpmcounter4h();
	csr_rw_mhpmcounter5h();
	csr_rw_mhpmcounter6h();
	csr_rw_mhpmcounter7h();
	csr_rw_mhpmcounter8h();
	csr_rw_mhpmcounter9h();
	csr_rw_mhpmcounter10h();
	csr_rw_mhpmcounter11h();
	csr_rw_mhpmcounter12h();
	csr_rw_mhpmcounter13h();
	csr_rw_mhpmcounter14h();
	csr_rw_mhpmcounter15h();
	csr_rw_mhpmcounter16h();
	csr_rw_mhpmcounter17h();
	csr_rw_mhpmcounter18h();
	csr_rw_mhpmcounter19h();
	csr_rw_mhpmcounter20h();
	csr_rw_mhpmcounter21h();
	csr_rw_mhpmcounter22h();
	csr_rw_mhpmcounter23h();
	csr_rw_mhpmcounter24h();
	csr_rw_mhpmcounter25h();
	csr_rw_mhpmcounter26h();
	csr_rw_mhpmcounter27h();
	csr_rw_mhpmcounter28h();
	csr_rw_mhpmcounter29h();
	csr_rw_mhpmcounter30h();
	csr_rw_mhpmcounter31h();
	csr_rw_mcountinhibit();
	csr_rw_mcyclecfg();
	csr_rw_minstretcfg();
	csr_rw_mhpmevent3();
	csr_rw_mhpmevent4();
	csr_rw_mhpmevent5();
	csr_rw_mhpmevent6();
	csr_rw_mhpmevent7();
	csr_rw_mhpmevent8();
	csr_rw_mhpmevent9();
	csr_rw_mhpmevent10();
	csr_rw_mhpmevent11();
	csr_rw_mhpmevent12();
	csr_rw_mhpmevent13();
	csr_rw_mhpmevent14();
	csr_rw_mhpmevent15();
	csr_rw_mhpmevent16();
	csr_rw_mhpmevent17();
	csr_rw_mhpmevent18();
	csr_rw_mhpmevent19();
	csr_rw_mhpmevent20();
	csr_rw_mhpmevent21();
	csr_rw_mhpmevent22();
	csr_rw_mhpmevent23();
	csr_rw_mhpmevent24();
	csr_rw_mhpmevent25();
	csr_rw_mhpmevent26();
	csr_rw_mhpmevent27();
	csr_rw_mhpmevent28();
	csr_rw_mhpmevent29();
	csr_rw_mhpmevent30();
	csr_rw_mhpmevent31();
	csr_rw_mcyclecfgh();
	csr_rw_minstretcfgh();
	csr_rw_mhpmevent3h();
	csr_rw_mhpmevent4h();
	csr_rw_mhpmevent5h();
	csr_rw_mhpmevent6h();
	csr_rw_mhpmevent7h();
	csr_rw_mhpmevent8h();
	csr_rw_mhpmevent9h();
	csr_rw_mhpmevent10h();
	csr_rw_mhpmevent11h();
	csr_rw_mhpmevent12h();
	csr_rw_mhpmevent13h();
	csr_rw_mhpmevent14h();
	csr_rw_mhpmevent15h();
	csr_rw_mhpmevent16h();
	csr_rw_mhpmevent17h();
	csr_rw_mhpmevent18h();
	csr_rw_mhpmevent19h();
	csr_rw_mhpmevent20h();
	csr_rw_mhpmevent21h();
	csr_rw_mhpmevent22h();
	csr_rw_mhpmevent23h();
	csr_rw_mhpmevent24h();
	csr_rw_mhpmevent25h();
	csr_rw_mhpmevent26h();
	csr_rw_mhpmevent27h();
	csr_rw_mhpmevent28h();
	csr_rw_mhpmevent29h();
	csr_rw_mhpmevent30h();
	csr_rw_mhpmevent31h();
	csr_rw_tselect();
	csr_rw_tdata1();
	csr_rw_tdata2();
	csr_rw_tdata3();
	csr_rw_tinfo();
	csr_rw_tcontrol();
	csr_rw_mcontext();
	csr_rw_mscontext();
	csr_rw_miselect();
	csr_rw_mireg();
	csr_rw_mireg2();
	csr_rw_mireg3();
	csr_rw_mireg4();
	csr_rw_mireg5();
	csr_rw_mireg6();
	csr_rw_mtopei();

	return 0;
}
