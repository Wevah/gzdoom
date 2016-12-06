;*
;* tmap.nas
;* The texture-mapping inner loops in pure assembly language.
;*
;*---------------------------------------------------------------------------
;* Copyright 1998-2006 Randy Heit
;* All rights reserved.
;*
;* Redistribution and use in source and binary forms, with or without
;* modification, are permitted provided that the following conditions
;* are met:
;*
;* 1. Redistributions of source code must retain the above copyright
;*    notice, this list of conditions and the following disclaimer.
;* 2. Redistributions in binary form must reproduce the above copyright
;*    notice, this list of conditions and the following disclaimer in the
;*    documentation and/or other materials provided with the distribution.
;* 3. The name of the author may not be used to endorse or promote products
;*    derived from this software without specific prior written permission.
;*
;* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
;* IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
;* OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
;* IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
;* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
;* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
;* THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;*---------------------------------------------------------------------------
;*

BITS 32

%include "valgrind.inc"

; Segment/section definition macros. 

	SECTION .data

%define SPACEFILLER4 (0x44444444)

; If you change this in r_draw.c, be sure to change it here, too!
FUZZTABLE	equ	50

%ifndef M_TARGET_LINUX

%define ylookup			_ylookup
%define centery			_centery
%define fuzzpos			_fuzzpos
%define fuzzoffset		_fuzzoffset
%define NormalLight		_NormalLight
%define viewheight		_viewheight
%define fuzzviewheight	_fuzzviewheight
%define CPU				_CPU

%define dc_pitch		_dc_pitch
%define dc_colormap		_dc_colormap
%define dc_color		_dc_color
%define dc_iscale		_dc_iscale
%define dc_texturefrac	_dc_texturefrac
%define dc_srcblend		_dc_srcblend
%define dc_destblend	_dc_destblend
%define dc_source		_dc_source
%define dc_yl			_dc_yl
%define dc_yh			_dc_yh
%define dc_x			_dc_x
%define dc_count		_dc_count
%define dc_dest			_dc_dest
%define dc_destorg		_dc_destorg

%define Col2RGB8		_Col2RGB8
%define RGB32k			_RGB32k

%define dc_ctspan		_dc_ctspan
%define dc_temp			_dc_temp

%define ds_xstep		_ds_xstep
%define ds_ystep		_ds_ystep
%define ds_colormap		_ds_colormap
%define ds_source		_ds_source
%define ds_x1			_ds_x1
%define ds_x2			_ds_x2
%define ds_xfrac		_ds_xfrac
%define ds_yfrac		_ds_yfrac
%define ds_y			_ds_y

%define ds_cursource	_ds_cursource
%define ds_curcolormap	_ds_curcolormap

%define R_SetSpanSource_ASM		_R_SetSpanSource_ASM
%define R_SetSpanSize_ASM		_R_SetSpanSize_ASM
%define R_SetSpanColormap_ASM	_R_SetSpanColormap_ASM
%define R_SetupShadedCol		_R_SetupShadedCol
%define R_SetupAddCol			_R_SetupAddCol
%define R_SetupAddClampCol		_R_SetupAddClampCol

%endif

EXTERN ylookup
EXTERN centery
EXTERN fuzzpos
EXTERN fuzzoffset
EXTERN NormalLight
EXTERN viewheight
EXTERN fuzzviewheight
EXTERN CPU

EXTERN dc_pitch
EXTERN dc_colormap
EXTERN dc_color
EXTERN dc_iscale
EXTERN dc_texturefrac
EXTERN dc_srcblend
EXTERN dc_destblend
EXTERN dc_source
EXTERN dc_yl
EXTERN dc_yh
EXTERN dc_x
EXTERN dc_count
EXTERN dc_dest
EXTERN dc_destorg

EXTERN dc_ctspan
EXTERN dc_temp

EXTERN Col2RGB8
EXTERN RGB32k

EXTERN ds_xstep
EXTERN ds_ystep
EXTERN ds_colormap
EXTERN ds_source
EXTERN ds_x1
EXTERN ds_x2
EXTERN ds_xfrac
EXTERN ds_yfrac
EXTERN ds_y

GLOBAL ds_cursource
GLOBAL ds_curcolormap


ds_cursource:
	DD 0

ds_curcolormap:
	DD 0


; Local stuff:
lastAddress	DD 0
pixelcount	DD 0

	SECTION .text


GLOBAL @R_SetSpanSource_ASM@4
GLOBAL R_SetSpanSource_ASM

R_SetSpanSource_ASM:
	mov	ecx,[esp+4]

@R_SetSpanSource_ASM@4:
	mov	[spreada+2],ecx
	mov	[spreadb+2],ecx
	mov	[spreadc+2],ecx
	mov	[spreadd+2],ecx
	mov	[spreade+2],ecx
	mov	[spreadf+2],ecx
	mov	[spreadg+2],ecx

	mov	[mspreada+2],ecx
	mov	[mspreadb+2],ecx
	mov	[mspreadc+2],ecx
	mov	[mspreadd+2],ecx
	mov	[mspreade+2],ecx
	mov	[mspreadf+2],ecx
	mov	[mspreadg+2],ecx
	
	selfmod spreada, mspreadg+6

	mov	[ds_cursource],ecx
	ret

GLOBAL @R_SetSpanColormap_ASM@4
GLOBAL R_SetSpanColormap_ASM

R_SetSpanColormap_ASM:
	mov ecx,[esp+4]

@R_SetSpanColormap_ASM@4:
	mov	[spmapa+2],ecx
	mov	[spmapb+2],ecx
	mov	[spmapc+2],ecx
	mov	[spmapd+2],ecx
	mov	[spmape+2],ecx
	mov	[spmapf+2],ecx
	mov	[spmapg+2],ecx

	mov	[mspmapa+2],ecx
	mov	[mspmapb+2],ecx
	mov	[mspmapc+2],ecx
	mov	[mspmapd+2],ecx
	mov	[mspmape+2],ecx
	mov	[mspmapf+2],ecx
	mov	[mspmapg+2],ecx
	
	selfmod spmapa, mspmapg+6

	mov	[ds_curcolormap],ecx
	ret

GLOBAL R_SetSpanSize_ASM

EXTERN	SetTiltedSpanSize

R_SetSpanSize_ASM:
	mov	edx,[esp+4]
	mov	ecx,[esp+8]
	call	SetTiltedSpanSize
	
	mov	[dsy1+2],dl
	mov	[dsy2+2],dl
	
	mov	[dsx1+2],cl
	mov	[dsx2+2],cl
	mov	[dsx3+2],cl
	mov	[dsx4+2],cl
	mov	[dsx5+2],cl
	mov	[dsx6+2],cl
	mov	[dsx7+2],cl
	
	mov	[dmsy1+2],dl
	mov	[dmsy2+2],dl
	
	mov	[dmsx1+2],cl
	mov	[dmsx2+2],cl
	mov	[dmsx3+2],cl
	mov	[dmsx4+2],cl
	mov	[dmsx5+2],cl
	mov	[dmsx6+2],cl
	mov	[dmsx7+2],cl

	push	ecx
	add	ecx,edx
	mov	eax,1
	shl	eax,cl
	dec	eax
	mov	[dsm1+2],eax
	mov	[dsm5+1],eax
	mov	[dsm6+1],eax
	mov	[dsm7+1],eax
	
	mov	[dmsm1+2],eax
	mov	[dmsm5+1],eax
	mov	[dmsm6+1],eax
	mov	[dmsm7+1],eax
	pop	ecx
	ror	eax,cl
	mov	[dsm2+2],eax
	mov	[dsm3+2],eax
	mov	[dsm4+2],eax

	mov	[dmsm2+2],eax
	mov	[dmsm3+2],eax
	mov	[dmsm4+2],eax
	and	eax,0xffff
	not	eax
	mov	[dsm8+2],eax
	mov	[dsm9+2],eax

	mov	[dmsm8+2],eax
	mov	[dmsm9+2],eax
	
	neg	dl
	mov	[dsy3+2],dl
	mov	[dsy4+2],dl

	mov	[dmsy3+2],dl
	mov	[dmsy4+2],dl
	
	selfmod dsy1, dmsm7+6
	
aret:	ret

%ifdef M_TARGET_MACHO
	SECTION .text align=64
%else
	SECTION .rtext	progbits alloc exec write align=64
%endif

%ifdef M_TARGET_MACHO
GLOBAL _rtext_tmap_start
_rtext_tmap_start:
%endif

rtext_start:

GLOBAL @R_DrawSpanP_ASM@0
GLOBAL _R_DrawSpanP_ASM
GLOBAL R_DrawSpanP_ASM

; eax: scratch
; ebx: zero
; ecx: yfrac at top end, xfrac int part at low end
; edx: xfrac frac part at top end
; edi: dest
; ebp: scratch
; esi: count
; [esp]: xstep
; [esp+4]: ystep

	align	16

@R_DrawSpanP_ASM@0:
_R_DrawSpanP_ASM:
R_DrawSpanP_ASM:
	mov	eax,[ds_x2]
	 mov	ecx,[ds_x1]
	sub	eax,ecx
	 jl	near rdspret		; count < 0: nothing to do, so leave

	push	ebx
	push	edi
	push	ebp
	push	esi
	sub		esp, 8

	mov	edi,ecx
	add	edi,[dc_destorg]
	 mov	ecx,[ds_y]
	add	edi,[ylookup+ecx*4]
	 mov	edx,[ds_xstep]
dsy1:	shl	edx,6
	 mov	ebp,[ds_xstep]
dsy3:	shr	ebp,26
	 xor	ebx,ebx
	lea	esi,[eax+1]
	 mov	[esp],edx
	mov	edx,[ds_ystep]
	 mov	ecx,[ds_xfrac]
dsy4:	shr	ecx,26
dsm8:	 and	edx,strict dword 0xffffffc0
	or	ebp,edx
	 mov	[esp+4],ebp
	mov	ebp,[ds_yfrac]
	 mov	edx,[ds_xfrac]
dsy2:	shl	edx,6
dsm9:	 and	ebp,strict dword 0xffffffc0
	or	ecx,ebp
	 shr	esi,1
	jnc	dseven1

; do odd pixel

		mov	ebp,ecx
dsx1:		rol	ebp,6
dsm1:		and	ebp,0xfff
		 add	edx,[esp]
		adc	ecx,[esp+4]
spreada		 mov	bl,[ebp+SPACEFILLER4]
spmapa		mov	bl,[ebx+SPACEFILLER4]
		mov	[edi],bl
		 inc	edi

dseven1		shr	esi,1
		 jnc	dsrest

; do two more pixels
		mov	ebp,ecx
		 add	edx,[esp]
		adc	ecx,[esp+4]
dsm2:		 and	ebp,0xfc00003f
dsx2:		rol	ebp,6
		mov	eax,ecx
		 add	edx,[esp]
		adc	ecx,[esp+4]
spreadb		 mov	bl,[ebp+SPACEFILLER4]	;read texel1
dsx3:		rol	eax,6
dsm6:		and	eax,0xfff
spmapb		 mov	bl,[ebx+SPACEFILLER4]	;map texel1
		mov	[edi],bl		;store texel1
		 add	edi,2
spreadc		mov	bl,[eax+SPACEFILLER4]	;read texel2
spmapc		mov	bl,[ebx+SPACEFILLER4]	;map texel2
		mov	[edi-1],bl		;store texel2

; do the rest

dsrest		test	esi,esi
		jz near	dsdone

		align 16

dsloop		mov	ebp,ecx
spstep1d	 add	edx,[esp]
spstep2d	adc	ecx,[esp+4]
dsm3:		 and	ebp,0xfc00003f
dsx4:		rol	ebp,6
		mov	eax,ecx
spstep1e	 add	edx,[esp]
spstep2e	adc	ecx,[esp+4]
spreadd		 mov	bl,[ebp+SPACEFILLER4]	;read texel1
dsx5:		rol	eax,6
dsm5:		and	eax,0xfff
spmapd		 mov	bl,[ebx+SPACEFILLER4]	;map texel1
		mov	[edi],bl		;store texel1
		 mov	ebp,ecx
spreade		mov	bl,[eax+SPACEFILLER4]	;read texel2
spstep1f	 add	edx,[esp]
spstep2f	adc	ecx,[esp+4]
dsm4:		 and	ebp,0xfc00003f
dsx6:		rol	ebp,6
spmape		mov	bl,[ebx+SPACEFILLER4]	;map texel2
		 mov	eax,ecx
		mov	[edi+1],bl		;store texel2
spreadf		 mov	bl,[ebp+SPACEFILLER4]	;read texel3
spmapf		mov	bl,[ebx+SPACEFILLER4]	;map texel3
		 add	edi,4
dsx7:		rol	eax,6
dsm7:		and	eax,0xfff
		 mov	[edi-2],bl		;store texel3
spreadg		mov	bl,[eax+SPACEFILLER4]	;read texel4
spstep1g	 add	edx,[esp]
spstep2g	adc	ecx,[esp+4]
spmapg		 mov	bl,[ebx+SPACEFILLER4]	;map texel4
		dec	esi
		 mov	[edi-1],bl		;store texel4
		jnz near dsloop

dsdone	add esp,8
	pop	esi
	pop	ebp
	pop	edi
	pop	ebx

rdspret	ret

; This is the same as the previous routine, except it doesn't draw pixels
; where the texture's color value is 0.

GLOBAL @R_DrawSpanMaskedP_ASM@0
GLOBAL _R_DrawSpanMaskedP_ASM
GLOBAL R_DrawSpanMaskedP_ASM

; eax: scratch
; ebx: zero
; ecx: yfrac at top end, xfrac int part at low end
; edx: xfrac frac part at top end
; edi: dest
; ebp: scratch
; esi: count
; [esp]: xstep
; [esp+4]: ystep

	align	16

@R_DrawSpanMaskedP_ASM@0:
_R_DrawSpanMaskedP_ASM:
R_DrawSpanMaskedP_ASM:
	mov	eax,[ds_x2]
	 mov	ecx,[ds_x1]
	sub	eax,ecx
	 jl	rdspret		; count < 0: nothing to do, so leave

	push	ebx
	push	edi
	push	ebp
	push	esi
	sub		esp,8

	mov	edi,ecx
	add	edi,[dc_destorg]
	 mov	ecx,[ds_y]
	add	edi,[ylookup+ecx*4]
	 mov	edx,[ds_xstep]
dmsy1:	shl	edx,6
	 mov	ebp,[ds_xstep]
dmsy3:	shr	ebp,26
	 xor	ebx,ebx
	lea	esi,[eax+1]
	 mov	[esp],edx
	mov	edx,[ds_ystep]
	 mov	ecx,[ds_xfrac]
dmsy4:	shr	ecx,26
dmsm8:	 and	edx,strict dword 0xffffffc0
	or	ebp,edx
	 mov	[esp+4],ebp
	mov	ebp,[ds_yfrac]
	 mov	edx,[ds_xfrac]
dmsy2:	shl	edx,6
dmsm9:	 and	ebp,strict dword 0xffffffc0
	or	ecx,ebp
	 shr	esi,1
	jnc	dmseven1

; do odd pixel

		mov	ebp,ecx
dmsx1:		rol	ebp,6
dmsm1:		and	ebp,0xfff
		 add	edx,[esp]
		adc	ecx,[esp+4]
mspreada	 mov	bl,[ebp+SPACEFILLER4]
		cmp	bl,0
		 je	mspskipa
mspmapa		mov	bl,[ebx+SPACEFILLER4]
		mov	[edi],bl
mspskipa:	 inc	edi

dmseven1	shr	esi,1
		 jnc	dmsrest

; do two more pixels
		mov	ebp,ecx
		 add	edx,[esp]
		adc	ecx,[esp+4]
dmsm2:		 and	ebp,0xfc00003f
dmsx2:		rol	ebp,6
		mov	eax,ecx
		 add	edx,[esp]
		adc	ecx,[esp+4]
mspreadb	 mov	bl,[ebp+SPACEFILLER4]	;read texel1
dmsx3:		rol	eax,6
dmsm6:		and	eax,0xfff
		cmp	bl,0
		 je	mspskipb
mspmapb		 mov	bl,[ebx+SPACEFILLER4]	;map texel1
		mov	[edi],bl		;store texel1
mspskipb	 add	edi,2
mspreadc	mov	bl,[eax+SPACEFILLER4]	;read texel2
		cmp	bl,0
		 je	dmsrest
mspmapc		mov	bl,[ebx+SPACEFILLER4]	;map texel2
		mov	[edi-1],bl		;store texel2

; do the rest

dmsrest		test	esi,esi
		jz near	dmsdone

		align 16

dmsloop		mov	ebp,ecx
mspstep1d	 add	edx,[esp]
mspstep2d	adc	ecx,[esp+4]
dmsm3:		 and	ebp,0xfc00003f
dmsx4:		rol	ebp,6
		mov	eax,ecx
mspstep1e	 add	edx,[esp]
mspstep2e	adc	ecx,[esp+4]
mspreadd	 mov	bl,[ebp+SPACEFILLER4]	;read texel1
dmsx5:		rol	eax,6
dmsm5:		and	eax,0xfff
		 cmp	bl,0
		mov	ebp,ecx
		 je	mspreade
mspmapd		mov	bl,[ebx+SPACEFILLER4]	;map texel1
		mov	[edi],bl		;store texel1
mspreade	mov	bl,[eax+SPACEFILLER4]	;read texel2
mspstep1f	 add	edx,[esp]
mspstep2f	adc	ecx,[esp+4]
dmsm4:		 and	ebp,0xfc00003f
dmsx6:		rol	ebp,6
		 cmp	bl,0
		mov	eax,ecx
		 je	mspreadf
mspmape		mov	bl,[ebx+SPACEFILLER4]	;map texel2
		mov	[edi+1],bl		;store texel2
mspreadf	 mov	bl,[ebp+SPACEFILLER4]	;read texel3
		add	edi,4
dmsx7:		rol	eax,6
dmsm7:		and	eax,0xfff
		cmp	bl,0
		 je	mspreadg
mspmapf		mov	bl,[ebx+SPACEFILLER4]	;map texel3
		 mov	[edi-2],bl		;store texel3
mspreadg	mov	bl,[eax+SPACEFILLER4]	;read texel4
mspstep1g	 add	edx,[esp]
mspstep2g	adc	ecx,[esp+4]
		cmp	bl,0
		 je	mspskipg
mspmapg		 mov	bl,[ebx+SPACEFILLER4]	;map texel4
		mov	[edi-1],bl		;store texel4
mspskipg	dec	esi
		 jnz near dmsloop

dmsdone	add esp,8
	pop	esi
	pop	ebp
	pop	edi
	pop	ebx

	ret




GLOBAL rt_shaded4cols_asm
GLOBAL _rt_shaded4cols_asm

rt_shaded4cols_asm:
_rt_shaded4cols_asm:
		mov		ecx,[esp+8]
		push	ebp
		mov		ebp,[esp+16]
		sub		ebp,ecx
		js		near s4nil
		mov		eax,[ylookup+ecx*4]
		add		eax,[dc_destorg]				; eax = destination
		push	ebx
		push	esi
		mov		esi,[dc_temp]
		inc		ebp								; ebp = count
		add		eax,[esp+16]
		push	edi
		lea		esi,[esi+ecx*4]				; esi = source

		align	16

s4loop:	movzx	edx,byte [esi]
		movzx	ecx,byte [esi+1]
s4cm1:	movzx	edx,byte [SPACEFILLER4+edx]		; colormap
s4cm2:	movzx	edi,byte [SPACEFILLER4+ecx]		; colormap
		shl		edx,8
		movzx	ebx,byte [eax]
		shl		edi,8
		movzx	ecx,byte [eax+1]
		sub		ebx,edx
		sub		ecx,edi
		mov		ebx,[Col2RGB8+0x10000+ebx*4]
		mov		ecx,[Col2RGB8+0x10000+ecx*4]
s4fg1:	add		ebx,[SPACEFILLER4+edx*4]
s4fg2:	add		ecx,[SPACEFILLER4+edi*4]
		or		ebx,0x1f07c1f
		or		ecx,0x1f07c1f
		mov		edx,ebx
		shr		ebx,15
		mov		edi,ecx
		shr		ecx,15
		and		edx,ebx
		and		ecx,edi
		mov		bl,[RGB32k+edx]
		movzx	edx,byte [esi+2]
		mov		bh,[RGB32k+ecx]
		movzx	ecx,byte [esi+3]
		mov		[eax],bl
		mov		[eax+1],bh

s4cm3:	movzx	edx,byte [SPACEFILLER4+edx]		; colormap
s4cm4:	movzx	edi,byte [SPACEFILLER4+ecx]		; colormap
		shl		edx,8
		movzx	ebx,byte [eax+2]
		shl		edi,8
		movzx	ecx,byte [eax+3]
		sub		ebx,edx
		sub		ecx,edi
		mov		ebx,[Col2RGB8+0x10000+ebx*4]
		mov		ecx,[Col2RGB8+0x10000+ecx*4]
s4fg3:	add		ebx,[SPACEFILLER4+edx*4]
s4fg4:	add		ecx,[SPACEFILLER4+edi*4]
		or		ebx,0x1f07c1f
		or		ecx,0x1f07c1f
		mov		edx,ebx
		shr		ebx,15
		mov		edi,ecx
		shr		ecx,15
		and		edx,ebx
		and		ecx,edi
s4p:	add		eax,320							; pitch
		add		esi,4
		mov		bl,[RGB32k+edx]
		mov		bh,[RGB32k+ecx]
s4p2:	mov		[eax-320+2],bl
s4p3:	mov		[eax-320+3],bh
		dec		ebp
		jne		s4loop

		pop		edi
		pop		esi
		pop		ebx
s4nil:	pop		ebp
		ret

		align 16

GLOBAL	rt_add4cols_asm
GLOBAL	_rt_add4cols_asm

rt_add4cols_asm:
_rt_add4cols_asm:
		mov		ecx,[esp+8]
		push	edi
		mov		edi,[esp+16]
		sub		edi,ecx
		js		near a4nil
		mov		eax,[ylookup+ecx*4]
		add		eax,[dc_destorg]
		push	ebx
		push	esi
		mov		esi,[dc_temp]
		push	ebp
		inc		edi
		add		eax,[esp+20]
		lea		esi,[esi+ecx*4]
		
		align 16
a4loop:
		movzx	ebx,byte [esi]
		movzx	edx,byte [esi+1]
		movzx	ecx,byte [eax]
		movzx	ebp,byte [eax+1]
a4cm1:	movzx	ebx,byte [SPACEFILLER4+ebx]		; colormap
a4cm2:	movzx	edx,byte [SPACEFILLER4+edx]		; colormap
a4bg1:	mov		ecx,[SPACEFILLER4+ecx*4]		; bg2rgb
a4bg2:	mov		ebp,[SPACEFILLER4+ebp*4]		; bg2rgb
a4fg1:	add		ecx,[SPACEFILLER4+ebx*4]		; fg2rgb
a4fg2:	add		ebp,[SPACEFILLER4+edx*4]		; fg2rgb
		or		ecx,0x01f07c1f
		or		ebp,0x01f07c1f
		mov		ebx,ecx
		shr		ecx,15
		mov		edx,ebp
		shr		ebp,15
		and		ecx,ebx
		and		ebp,edx
		movzx	ebx,byte [esi+2]
		movzx	edx,byte [esi+3]
		mov		cl,[RGB32k+ecx]
		mov		ch,[RGB32k+ebp]
		mov		[eax],cl
		mov		[eax+1],ch

		movzx	ecx,byte [eax+2]
		movzx	ebp,byte [eax+3]
a4cm3:	movzx	ebx,byte [SPACEFILLER4+ebx]		; colormap
a4cm4:	movzx	edx,byte [SPACEFILLER4+edx]		; colormap
a4bg3:	mov		ecx,[SPACEFILLER4+ecx*4]		; bg2rgb
a4bg4:	mov		ebp,[SPACEFILLER4+ebp*4]		; bg2rgb
a4fg3:	add		ecx,[SPACEFILLER4+ebx*4]		; fg2rgb
a4fg4:	add		ebp,[SPACEFILLER4+edx*4]		; fg2rgb
		or		ecx,0x01f07c1f
		or		ebp,0x01f07c1f
		mov		ebx,ecx
		shr		ecx,15
		mov		edx,ebp
		shr		ebp,15
		and		ebx,ecx
		and		edx,ebp
		mov		cl,[RGB32k+ebx]
		mov		ch,[RGB32k+edx]
		mov		[eax+2],cl
		mov		[eax+3],ch

		add		esi,4
a4p:	add		eax,320							; pitch
		sub		edi,1
		jne		a4loop
		pop		ebp
		pop		esi
		pop		ebx
a4nil:	pop		edi
		ret

		align 16

GLOBAL	rt_addclamp4cols_asm
GLOBAL	_rt_addclamp4cols_asm

rt_addclamp4cols_asm:
_rt_addclamp4cols_asm:
		mov		ecx,[esp+8]
		push	edi
		mov		edi,[esp+16]
		sub		edi,ecx
		js		near ac4nil
		mov		eax,[ylookup+ecx*4]
		add		eax,[dc_destorg]
		push	ebx
		push	esi
		mov		esi,[dc_temp]
		push	ebp
		inc		edi
		add		eax,[esp+20]
		lea		esi,[esi+ecx*4]
		push	edi
		
		align	16
ac4loop:
		movzx	ebx,byte [esi]
		movzx	edx,byte [esi+1]
		mov		[esp],edi
ac4cm1:	movzx	ebx,byte [SPACEFILLER4+ebx]		; colormap
ac4cm2:	movzx	edx,byte [SPACEFILLER4+edx]		; colormap
		movzx	ecx,byte [eax]
		movzx	ebp,byte [eax+1]
ac4fg1:	mov		ebx,[SPACEFILLER4+ebx*4]		; fg2rgb
ac4fg2:	mov		edx,[SPACEFILLER4+edx*4]		; fg2rgb
ac4bg1:	add		ebx,[SPACEFILLER4+ecx*4]		; bg2rgb
ac4bg2:	add		edx,[SPACEFILLER4+ebp*4]		; bg2rgb
		mov		ecx,ebx
		or		ebx,0x01f07c1f
		and		ecx,0x40100400
		and		ebx,0x3fffffff
		mov		edi,ecx
		shr		ecx,5
		mov		ebp,edx
		sub		edi,ecx
		or		edx,0x01f07c1f
		or		ebx,edi
		mov		ecx,ebx
		shr		ebx,15
		and		ebp,0x40100400
		and		ebx,ecx
		and		edx,0x3fffffff
		mov		edi,ebp
		shr		ebp,5
		mov		cl,[RGB32k+ebx]
		sub		edi,ebp
		mov		[eax],cl
		or		edx,edi
		mov		ebp,edx
		shr		edx,15
		movzx	ebx,byte [esi+2]
		and		ebp,edx
		movzx	edx,byte [esi+3]
ac4cm3:	movzx	ebx,byte [SPACEFILLER4+ebx]		; colormap
		mov		cl,[RGB32k+ebp]
ac4cm4:	movzx	edx,byte [SPACEFILLER4+edx]		; colormap
		mov		[eax+1],cl
		movzx	ecx,byte [eax+2]
		movzx	ebp,byte [eax+3]
ac4fg3:	mov		ebx,[SPACEFILLER4+ebx*4]		; fg2rgb
ac4fg4:	mov		edx,[SPACEFILLER4+edx*4]		; fg2rgb
ac4bg3:	add		ebx,[SPACEFILLER4+ecx*4]		; bg2rgb
ac4bg4:	add		edx,[SPACEFILLER4+ebp*4]		; bg2rgb
		mov		ecx,ebx
		or		ebx,0x01f07c1f
		and		ecx,0x40100400
		and		ebx,0x3fffffff
		mov		edi,ecx
		shr		ecx,5
		mov		ebp,edx
		sub		edi,ecx
		or		edx,0x01f07c1f
		or		ebx,edi
		mov		ecx,ebx
		shr		ebx,15
		and		ebp,0x40100400
		and		ebx,ecx
		and		edx,0x3fffffff
		mov		edi,ebp
		shr		ebp,5
		mov		cl,[RGB32k+ebx]
		sub		edi,ebp
		mov		[eax+2],cl
		or		edx,edi
		mov		edi,[esp]
		mov		ebp,edx
		shr		edx,15
		add		esi,4
		and		edx,ebp
		mov		cl,[RGB32k+edx]
		mov		[eax+3],cl

ac4p:	add		eax,320							; pitch
		sub		edi,1
		jne		ac4loop
		pop		edi

		pop		ebp
		pop		esi
		pop		ebx
ac4nil:	pop		edi
		ret

rtext_end:
%ifdef M_TARGET_MACHO
GLOBAL _rtext_tmap_end
_rtext_tmap_end:
%endif
		align	16

;************************

	SECTION .text

GLOBAL	R_SetupShadedCol
GLOBAL	@R_SetupShadedCol@0

# Patch the values of dc_colormap and dc_color into the shaded column drawer.

R_SetupShadedCol:
@R_SetupShadedCol@0:
		mov		eax,[dc_colormap]
		cmp		[s4cm1+3],eax
		je		.cmdone
		mov		[s4cm1+3],eax
		mov		[s4cm2+3],eax
		mov		[s4cm3+3],eax
		mov		[s4cm4+3],eax
.cmdone	mov		eax,[dc_color]
		lea		eax,[Col2RGB8+eax*4]
		cmp		[s4fg1+3],eax
		je		.cdone
		mov		[s4fg1+3],eax
		mov		[s4fg2+3],eax
		mov		[s4fg3+3],eax
		mov		[s4fg4+3],eax
		selfmod s4cm1, s4fg4+7
.cdone	ret

GLOBAL	R_SetupAddCol
GLOBAL	@R_SetupAddCol@0

# Patch the values of dc_colormap, dc_srcblend, and dc_destblend into the
# unclamped adding column drawer.

R_SetupAddCol:
@R_SetupAddCol@0:
		mov		eax,[dc_colormap]
		cmp		[a4cm1+3],eax
		je		.cmdone
		mov		[a4cm1+3],eax
		mov		[a4cm2+3],eax
		mov		[a4cm3+3],eax
		mov		[a4cm4+3],eax
.cmdone	mov		eax,[dc_srcblend]
		cmp		[a4fg1+3],eax
		je		.sbdone
		mov		[a4fg1+3],eax
		mov		[a4fg2+3],eax
		mov		[a4fg3+3],eax
		mov		[a4fg4+3],eax
.sbdone	mov		eax,[dc_destblend]
		cmp		[a4bg1+3],eax
		je		.dbdone
		mov		[a4bg1+3],eax
		mov		[a4bg2+3],eax
		mov		[a4bg3+3],eax
		mov		[a4bg4+3],eax
		selfmod a4cm1, a4bg4+7
.dbdone	ret

GLOBAL	R_SetupAddClampCol
GLOBAL	@R_SetupAddClampCol@0

# Patch the values of dc_colormap, dc_srcblend, and dc_destblend into the
# add with clamping column drawer.

R_SetupAddClampCol:
@R_SetupAddClampCol@0:
		mov		eax,[dc_colormap]
		cmp		[ac4cm1+3],eax
		je		.cmdone
		mov		[ac4cm1+3],eax
		mov		[ac4cm2+3],eax
		mov		[ac4cm3+3],eax
		mov		[ac4cm4+3],eax
.cmdone	mov		eax,[dc_srcblend]
		cmp		[ac4fg1+3],eax
		je		.sbdone
		mov		[ac4fg1+3],eax
		mov		[ac4fg2+3],eax
		mov		[ac4fg3+3],eax
		mov		[ac4fg4+3],eax
.sbdone	mov		eax,[dc_destblend]
		cmp		[ac4bg1+3],eax
		je		.dbdone
		mov		[ac4bg1+3],eax
		mov		[ac4bg2+3],eax
		mov		[ac4bg3+3],eax
		mov		[ac4bg4+3],eax
		selfmod ac4cm1, ac4bg4+7
.dbdone	ret

EXTERN setvlinebpl_
EXTERN setpitch3

GLOBAL	@ASM_PatchPitch@0
GLOBAL	_ASM_PatchPitch
GLOBAL	ASM_PatchPitch

ASM_PatchPitch:
_ASM_PatchPitch:
@ASM_PatchPitch@0:
		mov		eax,[dc_pitch]
		mov		[s4p+1],eax
		mov		[a4p+1],eax
		mov		[ac4p+1],eax
		mov		ecx,eax
		neg		ecx
		inc		ecx
		inc		ecx
		mov		[s4p2+2],ecx
		inc		ecx
		mov		[s4p3+2],ecx
		selfmod rtext_start, rtext_end
		call	setpitch3
		jmp		setvlinebpl_
