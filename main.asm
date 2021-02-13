.586                                      ; create 32 bit code
.model flat, stdcall                      ; 32 bit memory model
option casemap :none                      ; case sensitive 
.mmx

ASSUME FS:NOTHING

;##########################################################################
; data section starts at baseadress + 0x1000
; baseaddress stored in mm0 register
; start of data in mm1 register
; mm2: kernel32.dll base address

    .data
		target_PID dd 0																				    ; offset:  0     4 bytes
		target_baseadress dd 0																	        ; offset:  4     4 bytes
		debugactiveprocess db 150,34,243,92,202,91,174,174,175,41,142,119,206,58,212,75,251,231         ; offset:  8    18 bytes
		debugactiveprocess2 db 150,34,243,92,202,91,174,174,175,41,142,119,206,58,212,75,251,231, 0     ; offset: 26    19 bytes
		
		
      item db 046h, 061h, 074h, 061h, 06ch, 041h, 070h, 070h, 045h, 078h, 069h, 074h, 041h

    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    call geteip
	call store_text_and_data_segment
	;call decode_debugactiveprocess		
	call decode_debugactiveprocess2
    call getkrnl32base
    

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

geteip proc
    mov eax, [esp]
    ret
geteip endp

store_text_and_data_segment proc
	lea eax, [eax - 5]
	movd mm0, eax
    lea eax, [eax+4096]
    movd mm1, eax
	ret
store_text_and_data_segment endp
	

decode_debugactiveprocess2 proc
	movd eax, mm1
	lea esi, [eax + 26]
	call geteip
	mov byte ptr [eax + 8], 0ebh
	mov byte ptr [eax + 9], 03h
	DB 075h, 0f1h                      ;this gets overwritten either way
	
	DB 00fh, 01fh, 084h, 0c6h, 006h, 0d2h, 0ebh, 03h  ;mov byte ptr [esi], 0d2h
	DB 00fh, 01fh, 084h, 0c6h, 046h, 001h, 047h, 0ebh ;mov byte ptr [esi + 1], 047h
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 002h, 091h, 0ebh ;mov byte ptr [esi + 2], 091h
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 003h, 029h, 0ebh ;mov byte ptr [esi + 3], 029h
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 004h, 0adh, 0ebh ;mov byte ptr [esi + 4], 0adh
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 005h, 01ah, 0ebh ;mov byte ptr [esi + 5], 01ah
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 006h, 0cdh, 0ebh ;mov byte ptr [esi + 6], 01ah
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 007h, 0dah, 0ebh ;mov byte ptr [esi + 7], 01ah
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 008h, 0c6h, 0ebh ;mov byte ptr [esi + 8], 01ah
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 009h, 05fh, 0ebh ;mov byte ptr [esi + 9], 05fh
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 10, 0ebh, 0ebh ;mov byte ptr [esi + 10], 0ebh
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 11, 027h, 0ebh ;mov byte ptr [esi + 11], 027h
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 12, 0bch, 0ebh ;mov byte ptr [esi + 12], 0bch
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 13, 055h, 0ebh ;mov byte ptr [esi + 13], 055h
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 14, 0b7h, 0ebh ;mov byte ptr [esi + 14], 0b7h
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 15, 02eh, 0ebh ;mov byte ptr [esi + 15], 02eh
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 084h, 0c6h, 046h, 16, 088h, 0ebh ;mov byte ptr [esi + 16], 088h
	DB 0fh, 01fh, 084h, 0 , 0 , 0, 0, 0
	DB 0fh, 01fh, 044h, 0 , 0
	DB 00fh, 01fh, 080h, 0c6h, 046h, 17, 094h ;mov byte ptr [esi + 17], 094h

	movd eax, mm1
    mov edi, 18
    or ebx, -1
	lea eax, [eax + 8]
	
	@@:
    add ebx, 1
    movzx edx, BYTE PTR [eax+ebx]
    xor [esi+ebx], dl
    sub edi, 1
    jnz @B
	
	ret

decode_debugactiveprocess2 endp

getkrnl32base proc
    xor edx, edx
    mov dl, 030h
    mov edx, dword ptr fs:[edx]
    mov edx, dword ptr [edx + 0ch]
    mov edx, dword ptr [edx + 01ch]
    target1:
    mov eax, dword ptr [edx + 08h]
    mov esi, dword ptr [edx + 020h]
    mov edx, dword ptr [edx]
    cmp byte ptr [esi + 0ch], 033h
    jne target1
    movd mm2, eax
    mov edi, eax
    add edi, dword ptr [eax + 03ch]
    mov edx, dword ptr [edi + 078h]
    add edx, eax
    mov edi, dword ptr [edx + 020h]
    add edi, eax
    xor ebp, ebp
    mov esi, dword ptr [edi + ebp*4]
    add esi, eax
    inc ebp
    cmp dword ptr [esi], 050746547h                     ;47 65 74 50 = GetP
    DB 075h, 0f2h                                       ;jne f2 
    cmp dword ptr [esi + 8], 065726464h                 ;64 64 72 65 = ddre
    DB 075h, 0e9h
    mov edi, dword ptr [edx + 024h]
    add edi, eax
    mov bp, word ptr [edi + ebp*2]
    mov edi, dword ptr [edx + 01ch]
    add edi, eax
    mov edi, dword ptr [edi + ebp*4 -4]
    add edi, eax                                        ;address of GetProcAdress now in edi
    DB 00fh, 01fh, 080h, 0ffh, 0d7h, 0ebh, 00ah			;NOP instruction with (call edi) + (jmp 0xa) encoding
    movd eax, mm1
    push eax
    movd eax, mm2
    push eax
    DB 0ebh, 0f2h										; jump to call edi, inside the previous 7 byte NOP
	
    call edi

    @@:
    add ebx, 1
    movzx edx, BYTE PTR [eax+ebx]
    xor [esi+ebx], dl
    sub edi, 1
    jnz @B




    jmp   near ptr eax
    DB 0EAh , 0ebh
    bios_reset DD 0ffff0000h
    jmp bios_reset

getkrnl32base endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
