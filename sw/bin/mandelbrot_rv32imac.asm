
bin/mandelbrot_rv32imac:	file format elf32-littleriscv

Disassembly of section .text:

000110d4 <_start>:
   110d4: 2271         	jal	0x11260 <main>
   110d6: 0001         	nop
   110d8: 0001         	nop
   110da: 0001         	nop
   110dc: 00100073     	ebreak

000110e0 <used_i32>:
   110e0: 8082         	ret

000110e2 <used_str>:
   110e2: 8082         	ret

000110e4 <used_image>:
   110e4: 8082         	ret

000110e6 <memset>:
   110e6: c619         	beqz	a2, 0x110f4 <memset+0xe>
   110e8: 962a         	add	a2, a2, a0
   110ea: 00b50023     	sb	a1, 0x0(a0)
   110ee: 0505         	addi	a0, a0, 0x1
   110f0: fec51de3     	bne	a0, a2, 0x110ea <memset+0x4>
   110f4: 8082         	ret

000110f6 <fixed_add>:
   110f6: 952e         	add	a0, a0, a1
   110f8: 8082         	ret

000110fa <fixed_sub>:
   110fa: 8d0d         	sub	a0, a0, a1
   110fc: 8082         	ret

000110fe <fixed_mul>:
   110fe: 02a58633     	mul	a2, a1, a0
   11102: 02a59533     	mulh	a0, a1, a0
   11106: 0522         	slli	a0, a0, 0x8
   11108: 8261         	srli	a2, a2, 0x18
   1110a: 8d51         	or	a0, a0, a2
   1110c: 8082         	ret

0001110e <fixed_int>:
   1110e: 0562         	slli	a0, a0, 0x18
   11110: 8082         	ret

00011112 <fixed_lt>:
   11112: 00b52533     	slt	a0, a0, a1
   11116: 8082         	ret

00011118 <complex_add>:
   11118: 9532         	add	a0, a0, a2
   1111a: 95b6         	add	a1, a1, a3
   1111c: 8082         	ret

0001111e <complex_mul>:
   1111e: 02a60833     	mul	a6, a2, a0
   11122: 02a612b3     	mulh	t0, a2, a0
   11126: 02b688b3     	mul	a7, a3, a1
   1112a: 02b69733     	mulh	a4, a3, a1
   1112e: 02a68333     	mul	t1, a3, a0
   11132: 02a69533     	mulh	a0, a3, a0
   11136: 02b606b3     	mul	a3, a2, a1
   1113a: 02b615b3     	mulh	a1, a2, a1
   1113e: 02a2         	slli	t0, t0, 0x8
   11140: 01885613     	srli	a2, a6, 0x18
   11144: 00566833     	or	a6, a2, t0
   11148: 0722         	slli	a4, a4, 0x8
   1114a: 0188d793     	srli	a5, a7, 0x18
   1114e: 0522         	slli	a0, a0, 0x8
   11150: 01835613     	srli	a2, t1, 0x18
   11154: 05a2         	slli	a1, a1, 0x8
   11156: 82e1         	srli	a3, a3, 0x18
   11158: 8f5d         	or	a4, a4, a5
   1115a: 8e49         	or	a2, a2, a0
   1115c: 8dd5         	or	a1, a1, a3
   1115e: 40e80533     	sub	a0, a6, a4
   11162: 95b2         	add	a1, a1, a2
   11164: 8082         	ret

00011166 <fixed_square_abs>:
   11166: 02a50633     	mul	a2, a0, a0
   1116a: 02a51533     	mulh	a0, a0, a0
   1116e: 0522         	slli	a0, a0, 0x8
   11170: 8261         	srli	a2, a2, 0x18
   11172: 8d51         	or	a0, a0, a2
   11174: 02b58633     	mul	a2, a1, a1
   11178: 02b595b3     	mulh	a1, a1, a1
   1117c: 05a2         	slli	a1, a1, 0x8
   1117e: 8261         	srli	a2, a2, 0x18
   11180: 8dd1         	or	a1, a1, a2
   11182: 952e         	add	a0, a0, a1
   11184: 8082         	ret

00011186 <clamp8>:
   11186: 0ff00593     	li	a1, 0xff
   1118a: 00b56463     	bltu	a0, a1, 0x11192 <clamp8+0xc>
   1118e: 0ff00513     	li	a0, 0xff
   11192: 8082         	ret

00011194 <rgb>:
   11194: 0542         	slli	a0, a0, 0x10
   11196: 05a2         	slli	a1, a1, 0x8
   11198: 8d4d         	or	a0, a0, a1
   1119a: 8d51         	or	a0, a0, a2
   1119c: 8082         	ret

0001119e <mandelbrot>:
   1119e: 1141         	addi	sp, sp, -0x10
   111a0: c622         	sw	s0, 0xc(sp)
   111a2: c426         	sw	s1, 0x8(sp)
   111a4: 4881         	li	a7, 0x0
   111a6: ff000837     	lui	a6, 0xff000
   111aa: fe8002b7     	lui	t0, 0xfe800
   111ae: 04000eb7     	lui	t4, 0x4000
   111b2: 1efd         	addi	t4, t4, -0x1
   111b4: 40000393     	li	t2, 0x400
   111b8: a021         	j	0x111c0 <mandelbrot+0x22>
   111ba: 0885         	addi	a7, a7, 0x1
   111bc: 08788e63     	beq	a7, t2, 0x11258 <mandelbrot+0xba>
   111c0: 4e01         	li	t3, 0x0
   111c2: 00f89f13     	slli	t5, a7, 0xf
   111c6: 00c89313     	slli	t1, a7, 0xc
   111ca: 9f42         	add	t5, t5, a6
   111cc: 932a         	add	t1, t1, a0
   111ce: a839         	j	0x111ec <mandelbrot+0x4e>
   111d0: 01069593     	slli	a1, a3, 0x10
   111d4: 07a2         	slli	a5, a5, 0x8
   111d6: 8ddd         	or	a1, a1, a5
   111d8: 8dd5         	or	a1, a1, a3
   111da: 0ff5c593     	xori	a1, a1, 0xff
   111de: 002e1613     	slli	a2, t3, 0x2
   111e2: 961a         	add	a2, a2, t1
   111e4: 0e05         	addi	t3, t3, 0x1
   111e6: c20c         	sw	a1, 0x0(a2)
   111e8: fc7e09e3     	beq	t3, t2, 0x111ba <mandelbrot+0x1c>
   111ec: 4781         	li	a5, 0x0
   111ee: 4681         	li	a3, 0x0
   111f0: 4601         	li	a2, 0x0
   111f2: 4581         	li	a1, 0x0
   111f4: 00fe1f93     	slli	t6, t3, 0xf
   111f8: 9f96         	add	t6, t6, t0
   111fa: 02c60733     	mul	a4, a2, a2
   111fe: 02c61433     	mulh	s0, a2, a2
   11202: 02b584b3     	mul	s1, a1, a1
   11206: 0422         	slli	s0, s0, 0x8
   11208: 8361         	srli	a4, a4, 0x18
   1120a: 8f41         	or	a4, a4, s0
   1120c: 02b59433     	mulh	s0, a1, a1
   11210: 0422         	slli	s0, s0, 0x8
   11212: 80e1         	srli	s1, s1, 0x18
   11214: 8c45         	or	s0, s0, s1
   11216: 008704b3     	add	s1, a4, s0
   1121a: 029ec463     	blt	t4, s1, 0x11242 <mandelbrot+0xa4>
   1121e: 02b604b3     	mul	s1, a2, a1
   11222: 02b615b3     	mulh	a1, a2, a1
   11226: 408f8633     	sub	a2, t6, s0
   1122a: 0791         	addi	a5, a5, 0x4
   1122c: 05a6         	slli	a1, a1, 0x9
   1122e: 80dd         	srli	s1, s1, 0x17
   11230: 963a         	add	a2, a2, a4
   11232: 8dc5         	or	a1, a1, s1
   11234: 99f9         	andi	a1, a1, -0x2
   11236: 95fa         	add	a1, a1, t5
   11238: 06c1         	addi	a3, a3, 0x10
   1123a: fc7790e3     	bne	a5, t2, 0x111fa <mandelbrot+0x5c>
   1123e: 4581         	li	a1, 0x0
   11240: bf79         	j	0x111de <mandelbrot+0x40>
   11242: 0ff00593     	li	a1, 0xff
   11246: 00b6e463     	bltu	a3, a1, 0x1124e <mandelbrot+0xb0>
   1124a: 0ff00693     	li	a3, 0xff
   1124e: f8b7e1e3     	bltu	a5, a1, 0x111d0 <mandelbrot+0x32>
   11252: 0ff00793     	li	a5, 0xff
   11256: bfad         	j	0x111d0 <mandelbrot+0x32>
   11258: 4432         	lw	s0, 0xc(sp)
   1125a: 44a2         	lw	s1, 0x8(sp)
   1125c: 0141         	addi	sp, sp, 0x10
   1125e: 8082         	ret

00011260 <main>:
   11260: 7111         	addi	sp, sp, -0x100
   11262: df86         	sw	ra, 0xfc(sp)
   11264: 00400537     	lui	a0, 0x400
   11268: f1050513     	addi	a0, a0, -0xf0
   1126c: 40a10133     	sub	sp, sp, a0
   11270: 0068         	addi	a0, sp, 0xc
   11272: 00400637     	lui	a2, 0x400
   11276: 4581         	li	a1, 0x0
   11278: 35bd         	jal	0x110e6 <memset>
   1127a: 0068         	addi	a0, sp, 0xc
   1127c: 370d         	jal	0x1119e <mandelbrot>
   1127e: 0068         	addi	a0, sp, 0xc
   11280: 40000593     	li	a1, 0x400
   11284: 40000613     	li	a2, 0x400
   11288: 3db1         	jal	0x110e4 <used_image>
   1128a: 4501         	li	a0, 0x0
   1128c: 004005b7     	lui	a1, 0x400
   11290: f1058593     	addi	a1, a1, -0xf0
   11294: 912e         	add	sp, sp, a1
   11296: 50fe         	lw	ra, 0xfc(sp)
   11298: 6111         	addi	sp, sp, 0x100
   1129a: 8082         	ret
