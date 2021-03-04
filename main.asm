.586                                      ; create 32 bit code
.model flat, stdcall                      ; 32 bit memory model
option casemap :none                      ; case sensitive 
.mmx

ASSUME FS:NOTHING

;##########################################################################
; data section starts at baseadress + 0x1000
; mm0: base address
; mm1: data address
; mm2: kernel32.dll base address
; mm3: GetProcAdress pointer

    .data
		target_PID dd 13016																				; offset:  0     4 bytes
		target_baseadress dd 0																	        ; offset:  4     4 bytes
		debugactiveprocess db 150,34,243,92,202,91,174,174,175,41,142,119,206,58,212,75,251,231         ; offset:  8    18 bytes
		debugactiveprocess2 db 150,34,243,92,202,91,174,174,175,41,142,119,206,58,212,75,251,231, 0     ; offset: 26    19 bytes    "DebugActiveProcess" after decryption
		
		openprocess db 154,95,216,142,19,7,1,173,4,186,246												; offset: 45    11 bytes        
		openprocess2 db 154,95,216,142,19,7,1,173,4,186,246,0									        ; offset: 56    12 bytes    "OpenProcess"
		
		debugactiveprocessstop  db 179,95,23,8,252,13,149,104,83,173,44,86,227,155,113,228              ; offset: 68    22 bytes    
		                        db 236,54,3,25,33,48
		debugactiveprocessstop2 db 179,95,23,8,252,13,149,104,83,173,44,86,227,155,113,228              ; offset: 90    23 bytes    "DebugActiveProcessStop"
		                        db 236,54,3,25,33,48,0
		
		terminateprocess db 177,104,23,196,155,202,20,53,107,168,170,80,216,52,81,146					; offset: 113   16 bytes     
		terminateprocess2 db 177,104,23,196,155,202,20,53,107,168,170,80,216,52,81,146,0				; offset: 129   17 bytes    "TerminateProcess" 
		
		writeprocessmemory db 141,248,79,51,140,188,100,197,88,77,197,17,34,24,90,141, 66,81            ; offset: 146   18 bytes
		writeprocessmemory2 db 141,248,79,51,140,188,100,197,88,77,197,17,34,24,90,141, 66,81,0         ; offset: 164   19 bytes    "WriteProcessMemory"
		
		virtualprotectex db 179,106,147,115,243,109,52,109,114,43,45,164,81,14,165,228					; offset: 183   16 bytes
		virtualprotectex2 db 179,106,147,115,243,109,52,109,114,43,45,164,81,14,165,228,0			    ; offset: 199   17 bytes    "VirtualProtectEx"
		

    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    call geteip
	call store_text_and_data_segment
	call installexceptionhandler ;test
	call getkrnl32base
	call locateGetProcAddress 					;Must be called right after getkrnl32base
	call deobfuscate_strings
	call find_winapi_addresses
	
	call attach_debugger
    
    

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

geteip proc
    mov eax, [esp]
    ;ret
	pop ecx
	jmp ecx
geteip endp

installexceptionhandler proc
	;Use address of exception routine instead of a call to hide execution flow
	; Set exception handler address by relative offset (mov esi, offset getkrnl32base)
	call geteip
	lea esi, [eax + 024h]
	
	;Install exception handler
    push esi
    push dword ptr fs:[0]
    mov dword ptr fs:[0], esp
	
	;Stack is destroyed after exception. When getkrnl32base is called by the handler we need to store return address in a non volatile
	;register mm7
	movd esi, mm0
	lea esi, [esi + 014h]
	movd mm7, esi
	
	;Antidebug trick set trap flag. Exception handler called  (normal execution), under debugger execution will proceed
	pushfd
    xor dword ptr ss : [esp] , 100H
    popfd

installexceptionhandler endp

getkrnl32base proc
	;Return address stored in mm7, gets put there before exception occurs
	movd eax, mm7
	push eax
	
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
	
	ret
getkrnl32base endp

store_text_and_data_segment proc
	lea eax, [eax - 5]
	movd mm0, eax
    lea eax, [eax+4096]
    movd mm1, eax
	ret
store_text_and_data_segment endp

deobfuscate_strings proc
	call decode_debugactiveprocess_string
	call decode_openprocess_string
	call decode_debugactiveprocessstop_string
	call decode_terminateprocess_string
	call decode_writeprocessmemory_string
	call decode_virtualprotectex_string
	
	ret
deobfuscate_strings endp

decode_debugactiveprocess_string proc
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

decode_debugactiveprocess_string endp
	
decode_openprocess_string proc
	movd eax, mm1
	lea esi, [eax + 56]
	
	mov DWORD PTR [esi+4], 3463345475
    mov BYTE PTR [esi+9], 201
    mov BYTE PTR [esi+8], 97
    mov BYTE PTR [esi+10], 133
    mov DWORD PTR [esi+0], 3770494933
	
	movd eax, mm1
    mov edi, 11
    or ebx, -1
	lea eax, [eax + 45]
	
	@@:
    add ebx, 1
    movzx edx, BYTE PTR [eax+ebx]
    xor [esi+ebx], dl
    sub edi, 1
    jnz @B
	
	
	ret
decode_openprocess_string endp

decode_debugactiveprocessstop_string proc
	movd eax, mm1
	lea esi, [eax + 90]
	
	mov DWORD PTR [esi+16], 1833977247
    mov BYTE PTR [esi+20], 78
    mov BYTE PTR [esi+21], 64
    mov DWORD PTR [esi+12], 2165503121
    mov DWORD PTR [esi+0], 2104834807
    mov DWORD PTR [esi+4], 485903515
    mov DWORD PTR [esi+8], 105503546
	
	movd eax, mm1
    mov edi, 22
    or ebx, -1
	lea eax, [eax + 68]
	
	@@:
    add ebx, 1
    movzx edx, BYTE PTR [eax+ebx]
    xor [esi+ebx], dl
    sub edi, 1
    jnz @B
	
	ret
decode_debugactiveprocessstop_string endp

decode_terminateprocess_string proc
	movd eax, mm1
	lea esi, [eax + 129]
	
	mov DWORD PTR [esi+12], 3777122747
    mov DWORD PTR [esi+4], 1098228978
    mov DWORD PTR [esi+8], 1071183886
    mov DWORD PTR [esi+0], 2841972197
	
	movd eax, mm1
    mov edi, 16
    or ebx, -1
	lea eax, [eax + 113]
	
	@@:
    add ebx, 1
    movzx edx, BYTE PTR [eax+ebx]
    xor [esi+ebx], dl
    sub edi, 1
    jnz @B
	
	ret

decode_terminateprocess_string endp

decode_writeprocessmemory_string proc
	movd eax, mm1
	lea esi, [eax + 164]
	
	mov DWORD PTR [esi+4], 2853629161
    mov DWORD PTR [esi+12], 3795287407
    mov DWORD PTR [esi+8], 1656105019
    mov BYTE PTR [esi+17], 40
    mov DWORD PTR [esi+0], 1193708250
    mov BYTE PTR [esi+16], 48
	
	movd eax, mm1
    mov edi, 18
    or ebx, -1
	lea eax, [eax + 146]
	
	@@:
    add ebx, 1
    movzx edx, BYTE PTR [eax+ebx]
    xor [esi+ebx], dl
    sub edi, 1
    jnz @B
	
	ret
decode_writeprocessmemory_string endp

decode_virtualprotectex_string proc
	movd eax, mm1
	lea esi, [eax + 199]
	
	mov DWORD PTR [esi+12], 2631957042
    mov DWORD PTR [esi+8], 3243852800
    mov DWORD PTR [esi+4], 1029180550
    mov DWORD PTR [esi+0], 132187109

	movd eax, mm1
    mov edi, 16
    or ebx, -1
	lea eax, [eax + 183]
	
	@@:
    add ebx, 1
    movzx edx, BYTE PTR [eax+ebx]
    xor [esi+ebx], dl
    sub edi, 1
    jnz @B
	
	ret
decode_virtualprotectex_string endp


attach_debugger proc
	;Call debugactiveprocess with pid of target
	movd esi, mm1
	lea edi, [esi + 8]
	mov edi, dword ptr [edi]
	DB 00fh, 01fh, 080h, 0ffh, 0d7h, 0ebh, 008h			;NOP instruction with (call edi) + (jmp 08a) encoding
	
    movd eax, mm1
	mov ebx, dword ptr [eax]
    push ebx											;Push PID
    DB 0ebh, 0f4h										; jump to call edi, inside the previous 7 byte NOP
	
	movd mm4, eax										;Move return value from debugactiveprocess to mm4 to check for debuggerpresence later
	
	;OpenProcess with processallaccess so handle can be used to both terminate process and writeprocessmemory
	push ebx
	push 0
	push 01FFFFFh
	lea edi, [esi + 12]
	mov edi, dword ptr [edi]
	call edi
	movd mm5, eax     									;move process handle to mm5
	
	movd eax, mm4
	cmp eax, 0
	jne nodebuggerpresent
	
	;Terminate target process here if debugger is present, proceed to nodebuggerpresent if no debugger attached to target
	;If this code is called our goal is reached, we can kill ourself aswell after killing target
	lea edi, [esi + 20]
	mov edi, dword ptr [edi]
	push 0FFFFFFFFh
	movd eax, mm5
	push eax
	call edi
	
	;Kill self process, maybe edit handle instead so rest of functions doesnt work correctly
	jmp sleeploop
	;xor eax, eax
	;call eax
	
	nodebuggerpresent:
	;Start by detaching the debugger that was attached
	lea edi, [esi + 16]
	mov edi, dword ptr [edi]
	push ebx
	call edi
	
	;We are now going to call virtualprotectex and writeprocessmemory on target to overwrite some instructions that are needed to run target successfully
	
	;Call virtualprotectex
	lea edi, [esi + 32]
	push edi					; PDWORD oldprotect
	push 040h					; PAGE EXECUTE/READ/WRITE
	push 3						; sets protection of whole page either way
	lea edi, [esi + 4]
	mov edi, dword ptr [edi]
	push edi					; LPVOID address
	movd eax, mm5
	push eax                    ; HANDLE processhandle
	lea edi, [esi + 28]
	mov edi, dword ptr [edi]
	call edi					; Call virtualprotectex
	
	;Call writeprocessmemory
	;BOOL WriteProcessMemory(
    ;HANDLE  hProcess,
    ;LPVOID  lpBaseAddress,
    ;LPCVOID lpBuffer,
    ;SIZE_T  nSize,
    ;SIZE_T  *lpNumberOfBytesWritten
    ;);
	
	lea edi, [esi + 32]
	push edi					;lpNumberOfBytesWritten
	push 4						;nSize
	add edi, 8
	mov dword ptr[edi], 074736572h 
	push edi					;buffer
	lea edi, [esi + 4]
	mov edi, dword ptr[edi]     ;dette er en test
	push edi					;baseaddress
	movd eax, mm5
	push eax					;HANDLE processhandle
	lea edi, [esi + 24]
	mov edi, dword ptr [edi]
	call edi					;Call WriteProcessMemory
	
	mov byte ptr [esi + 220], 1 ;Read from parent program to check when routine is completed
	;Sleep endlessly
	sleeploop:
	push 1000
	lea edi, [esi + 36]
	mov edi, dword ptr [edi]
	call edi
	jmp sleeploop
	
	ret
	
attach_debugger endp

find_winapi_addresses proc
	;Use GetProcAdress to find address of winapi funcs and write address to .data, edi, esi, ebx non volatile
	
	movd esi, mm1 	       ;addr of data section
	lea eax, [esi + 26]    ;"DebugActiveProcess"
	push eax             
	movd edi, mm2		   ;kernel32.dll module handle/address
	push edi
	movd ebx, mm3		   ;GetProcAdress
	call ebx		
	mov dword ptr [esi + 8], eax
	
	;Find OpenProcess address
	lea eax, [esi + 56]
	push eax
	push edi
	call ebx
	mov dword ptr [esi + 12], eax
	
	;Find DebugActiveProcessStop address
	lea eax, [esi + 90]
	push eax
	push edi
	call ebx
	mov dword ptr [esi + 16], eax
	
	;Find TerminateProcess address
	lea eax, [esi + 129]
	push eax
	push edi
	call ebx
	mov dword ptr [esi + 20], eax
	
	;Find writeprocessmemory address
	lea eax, [esi + 164]
	push eax
	push edi
	call ebx
	mov dword ptr [esi + 24], eax
	
	;Find virtualprotectex address
	lea eax, [esi + 199]
	push eax
	push edi
	call ebx
	mov dword ptr [esi + 28], eax
	
	;Delete strings in data section
	lea esi, [esi + 32]
	xor eax, eax
	mov ecx, 45
	
	target:
	mov dword ptr[esi + 4*ecx], eax
	dec ecx
	cmp ecx, 0
	jne target
	
	;Find Sleep address (stored at data + 36)
	mov byte ptr [esi], 053h
	mov byte ptr [esi + 1], 06ch
	mov byte ptr [esi + 2], 065h
	mov byte ptr [esi + 3], 065h
	mov byte ptr [esi + 4], 070h
	mov byte ptr [esi + 5], 0
	push esi
	push edi
	call ebx
	mov dword ptr [esi + 4], eax 	
	
	ret

find_winapi_addresses endp


locateGetProcAddress proc
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
	movd mm3, edi
	
	ret
locateGetProcAddress endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
