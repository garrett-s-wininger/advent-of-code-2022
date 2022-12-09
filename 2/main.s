.data

read_only_mode:
	.asciz "r"

invalid_args_message:
	.asciz "Usage: ./main <filepath>"

cant_open_file_message:
	.asciz "Unable to open requested file"

current_line:
	.space 4

total_score:
	.space 30

total_score_format:
	.asciz "Total Score: %d"

.text
.global main

main:
	push %r12
	push %r13

	# Use R13 as our score accumulator
	xor %r13, %r13

	cmp $2, %rdi
	jne print_invalid_args

_open_file:
	mov 8(%rsi), %rdi
	lea read_only_mode(%rip), %rsi
	call fopen

	cmp $0, %rax
	je print_cant_open_file
	mov %rax, %r12

_read_line:
	lea current_line(%rip), %rdi
	mov $1, %rsi
	mov $4, %rdx
	mov %r12, %rcx
	call fread

	cmp $4, %rax
	je _print_read_line
	jmp _end
	
_print_read_line:
	# We're reading in a fixed format, replace newline with null
	lea current_line(%rip), %rax
	movb $0, 3(%rax)

	# Print line as normal
	lea current_line(%rip), %rdi
	call puts

	# Add score to total
	call calculate_score
	add %rax, %r13

	# Fill in total score format
	lea total_score(%rip), %rdi
	mov $30, %rsi
	lea total_score_format(%rip), %rdx
	mov %r13, %rcx
	xor %rax, %rax
	call snprintf

	# Print total score
	lea total_score(%rip), %rdi
	call puts
	jmp _read_line
	
_end:
	pop %r13
	pop %r12
	jmp exit_success

calculate_score:
	push %rbx
	push %r12
	push %r13
	xor %r12, %r12
	lea current_line(%rip), %rbx

	cmpb $88, 2(%rbx)
	je _score_rock_selection
	cmpb $89, 2(%rbx)
	je _score_paper_selection
	cmpb $90, 2(%rbx)
	je _score_scissor_selection

_score_rock_selection:
	add $1, %r12
	jmp _score_win_loss_draw

_score_paper_selection:
	add $2, %r12
	jmp _score_win_loss_draw

_score_scissor_selection:
	add $3, %r12
	jmp _score_win_loss_draw

_score_win_loss_draw:
	cmpb $65, (%rbx)
	je _score_opponent_rock_selection
	cmpb $66, (%rbx)
	je _score_opponent_paper_selection
	cmpb $67, (%rbx)
	je _score_opponent_scissor_selection

_score_opponent_rock_selection:
	cmpb $88, 2(%rbx)
	je _add_draw_score
	cmpb $89, 2(%rbx)
	je _add_win_score
	cmpb $90, 2(%rbx)
	je _end_score_calculation

_score_opponent_paper_selection:
	cmpb $88, 2(%rbx)
	je _end_score_calculation
	cmpb $89, 2(%rbx)
	je _add_draw_score
	cmpb $90, 2(%rbx)
	je _add_win_score

_score_opponent_scissor_selection:
	cmpb $88, 2(%rbx)
	je _add_win_score
	cmpb $89, 2(%rbx)
	je _end_score_calculation
	cmpb $90, 2(%rbx)
	je _add_draw_score

_add_win_score:
	add $6, %r12
	jmp _end_score_calculation

_add_draw_score:
	add $3, %r12
	jmp _end_score_calculation

_end_score_calculation:
	mov %r12, %rax
	pop %r13
	pop %r12
	pop %rbx
	ret

print_invalid_args:
	lea invalid_args_message(%rip), %rdi
	call puts
	jmp exit_failure

print_cant_open_file:
	lea cant_open_file_message(%rip), %rdi
	call puts
	jmp exit_failure

exit_success:
	mov $60, %rax
	xor %rdi, %rdi
	syscall

exit_failure:
	mov $60, %rax
	mov $1, %rdi
	syscall

