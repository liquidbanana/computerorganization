
# calc_elem_addr from previous labs

.include "convenience.asm"
.text
.globl calc_addr
calc_addr:
	enter
	# Row address is the base address + index * sizeof(row) = a0 + a1*(sizeof(word)*n_elements in row) = a0 + a1*(4*a3)
	mul	t0, a3, 4
	mul	t0, t0, a1
	add	v0, a0, t0
	# Element address is the row address + index * sizeof(element) = row address + a2*4
	mul	t0, a2, 4
	add	v0, v0, t0
	pop	ra
	jr	ra
	leave
