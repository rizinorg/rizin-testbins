# SPDX-FileCopyrightText: 2026 RizinOrg <info@rizin.re>
# SPDX-License-Identifier: LGPL-3.0-only
#
# Intentionally invalid DWARF 4: the variable "no_value" has a DW_AT_location
# that is a non-empty expression (DW_OP_nop) which completes without leaving a
# value on the stack. A location expression must either be empty (zero
# operations, meaning "optimized out") or yield an address, register, implicit
# value or pieces, so this is not a valid location description. Everything
# else in the file is well-formed; "on_stack" has an ordinary DW_OP_fbreg
# location for comparison.
#
# Rizin used to crash on such an expression with a use-after-free and double
# free in rz_bin_dwarf_location_from_block(). It was originally hit on a real
# library, where misparsed location lists happened to produce one.
#
# This has to be written by hand: because the expression is invalid, no
# compiler emits it.
#
#   as -o dwarf-invalid-expr-no-value.o dwarf-invalid-expr-no-value.s
#   ld -n -o ../elf/dwarf/dwarf-invalid-expr-no-value-aarch64 dwarf-invalid-expr-no-value.o

	.text
	.globl	_start
	.type	_start, %function
_start:
.Lfn_begin:
	sub	sp, sp, #16
	str	wzr, [sp, #12]
	ldr	w0, [sp, #12]
	add	sp, sp, #16
	ret
.Lfn_end:
	.size	_start, .-_start

	.section	.debug_abbrev, "", %progbits
.Labbrev:
	.uleb128 1			// DW_TAG_compile_unit
	.uleb128 0x11
	.byte	1			// has children
	.uleb128 0x25, 0x08		// DW_AT_producer, DW_FORM_string
	.uleb128 0x13, 0x0b		// DW_AT_language, DW_FORM_data1
	.uleb128 0x03, 0x08		// DW_AT_name, DW_FORM_string
	.uleb128 0x11, 0x01		// DW_AT_low_pc, DW_FORM_addr
	.uleb128 0x12, 0x07		// DW_AT_high_pc, DW_FORM_data8
	.uleb128 0, 0

	.uleb128 2			// DW_TAG_subprogram
	.uleb128 0x2e
	.byte	1			// has children
	.uleb128 0x3f, 0x19		// DW_AT_external, DW_FORM_flag_present
	.uleb128 0x03, 0x08		// DW_AT_name, DW_FORM_string
	.uleb128 0x49, 0x13		// DW_AT_type, DW_FORM_ref4
	.uleb128 0x11, 0x01		// DW_AT_low_pc, DW_FORM_addr
	.uleb128 0x12, 0x07		// DW_AT_high_pc, DW_FORM_data8
	.uleb128 0x40, 0x18		// DW_AT_frame_base, DW_FORM_exprloc
	.uleb128 0, 0

	.uleb128 3			// DW_TAG_variable
	.uleb128 0x34
	.byte	0			// no children
	.uleb128 0x03, 0x08		// DW_AT_name, DW_FORM_string
	.uleb128 0x49, 0x13		// DW_AT_type, DW_FORM_ref4
	.uleb128 0x02, 0x18		// DW_AT_location, DW_FORM_exprloc
	.uleb128 0, 0

	.uleb128 4			// DW_TAG_base_type
	.uleb128 0x24
	.byte	0			// no children
	.uleb128 0x0b, 0x0b		// DW_AT_byte_size, DW_FORM_data1
	.uleb128 0x3e, 0x0b		// DW_AT_encoding, DW_FORM_data1
	.uleb128 0x03, 0x08		// DW_AT_name, DW_FORM_string
	.uleb128 0, 0

	.byte	0

	.section	.debug_info, "", %progbits
.Linfo:
	.4byte	.Linfo_end - .Linfo_ver	// unit_length
.Linfo_ver:
	.2byte	4			// version
	.4byte	.Labbrev		// debug_abbrev_offset
	.byte	8			// address_size

	.uleb128 1			// DW_TAG_compile_unit
	.asciz	"hand-written"
	.byte	0x0c			// DW_LANG_C99
	.asciz	"dwarf-invalid-expr-no-value.s"
	.8byte	.Lfn_begin
	.8byte	.Lfn_end - .Lfn_begin

	.uleb128 2			// DW_TAG_subprogram
	.asciz	"_start"
	.4byte	.Lint - .Linfo
	.8byte	.Lfn_begin
	.8byte	.Lfn_end - .Lfn_begin
	.uleb128 1
	.byte	0x9c			// DW_OP_call_frame_cfa

	.uleb128 3			// DW_TAG_variable
	.asciz	"no_value"
	.4byte	.Lint - .Linfo
	.uleb128 1
	.byte	0x96			// DW_OP_nop, invalid: leaves no value

	.uleb128 3			// DW_TAG_variable
	.asciz	"on_stack"
	.4byte	.Lint - .Linfo
	.uleb128 2
	.byte	0x91			// DW_OP_fbreg
	.sleb128 -4

	.byte	0			// end of subprogram children

.Lint:
	.uleb128 4			// DW_TAG_base_type
	.byte	4
	.byte	0x05			// DW_ATE_signed
	.asciz	"int"

	.byte	0			// end of compile unit children
.Linfo_end:
