#Aline da Silva Andrade - RA 104763
#Bruno Bernardo de Moura - RA 101888
#Bruno Malosti dos Santos - RA 101889
#Carolina Locatelli Colla - RA 103219


.data
.eqv _bmpAddress	0x10040000

preto:			.word	0x00000000 # preto
branco:			.word	0x00ffffff # branco
vermelho:		.word	0x00B22222 # vermelho
azul:			.word   0x00008B8B # azul
cinza:			.word   0x00696969 # cinza

Alfabeto: .ascii "ABCDEFGHP"
PosicaoInvalida: .asciiz "Posicao invalida, digite outra posicao!\n"
MovimentoInvalida: .asciiz "Movimento invalido, digite novamente!\n"
JogadorInvalido: .asciiz "Voce nao pode mexer esta peca!\n"
Auxiliar: .asciiz " "

#               X	Y	Cor	EH_DAMA?
Dama:.word 	32,	68,	-1,	0,
	     	32,	84,	-1,	0,
	      	32,	100,	-1,	0,
	      	32,	116,	-1,	0,
	      	40,	60,	-1,	0,
	      	40,	76,	-1,	0,
	      	40, 	92,	-1,	0,
	      	40, 	108, 	-1, 	0,
	      	48, 	68, 	-1, 	0,
	      	48, 	84, 	-1, 	0,
	      	48, 	100, 	-1, 	0,
	      	48, 	116, 	-1, 	0,     #FIM DO PRIMEIRO JOGADOR
	      	  	
	      	72, 	60, 	1, 	0,
	      	72, 	76, 	1, 	0,
	      	72, 	92, 	1, 	0,
	      	72, 	108, 	1, 	0,
	      	80, 	68, 	1, 	0,
	      	80, 	84, 	1, 	0,
	      	80, 	100, 	1, 	0,
	      	80, 	116, 	1, 	0,
	      	88, 	60, 	1, 	0,
	      	88, 	76, 	1, 	0,
	      	88, 	92, 	1, 	0,
	      	88, 	108, 	1, 	0      #FIM DO SEGUNDO JOGADOR   	      		      	   	      	   	      		      	   	      	          		      	   	      	   	      		      	   	      	    

.text

.macro push(%valor) ############# PUSH ##############
	addi $sp, $sp, -4
	sw %valor, 0($sp)
.end_macro

.macro pop(%valor) ############# POP ##############
	lw %valor, 0($sp)
	addi $sp, $sp,4
.end_macro

.macro scanInt(%valor) ############# SCAN_INT ############## 
	push($v0)
	li  $v0, 5        
    	syscall 
    	la  %valor, 0($v0)
    	pop($v0)
.end_macro

.macro printInt(%valor) ############# PRINT_INT ##############
	push($v0)
	push($a0)
	
	li  $v0, 1          
    	move $a0, %valor
    	syscall
    	printString(Auxiliar)
    	pop($a0)
    	pop($v0)
    	
.end_macro

.macro scanChar(%valor) ############# SCAN_CHAR ############## 
	push($v0)
	li  $v0, 12           
    	syscall
    	la  %valor, 0($v0)
    	pop($v0)
.end_macro

.macro printChar(%valor) ############# PRINT_CHAR ##############
	push($v0)
	push($a0)
	li  $v0,  11          
    	move $a0, %valor
    	syscall 	
    	pop($a0)
    	pop($v0)
.end_macro

.macro printString(%valor)	############# PRINT_STRING ##############
	push($v0)
	push($a0)	
	li $v0, 4
	la $a0, %valor
	syscall	
	pop($a0)
    	pop($v0)
.end_macro


.macro pause(%valor) ############# pause ##############
	push($v0)
    	push($a0)	
	li $v0, 32
	li $a0, %valor
	syscall	
	pop($a0)
    	pop($v0)
.end_macro

.macro Dir_Inf(%Xini, %Yini, %VetX, %VetY, %Xfinal)
	Dir_Inf_Loop:
		push(%VetX)
		push(%VetY)
		
		push($t0)
		push($t1)
		push($a2)
		push($a3)
		
		addi $t0, %Xini, 1
		addi $t1, %Yini, 1
		
		move $a2, $t0
		move $a3, $t1 
		
		jal BuscaNoVetor #Se retornar -1, nao comera ninguem, caso contrario sim
		
		bne $a2, -1, Come_Dir_Inf
	Volta_Dir_Inf:
		pop($a3)
		pop($a2)	
		pop($t1)
		pop($t0)
		
		beq %Xfinal, 88, DamaKing_Dir_Inf #COLUNA B
	
	Volta_DamaKing_Dir_Inf:
		
		addi %Xini, %Xini, 1 #Incrementa X
		addi %Yini, %Yini, 1 #Incrementa Y
			
		push(%Xini)
		push(%Yini)
		push(%Xfinal)
						
		sw %Xini, Dama(%VetX) #Salva X 		
		sw %Yini, Dama(%VetY) #Salva Y
	
	
		jal Tabuleiro
  		jal PrintVetor
		
		pop(%Xfinal)
		pop(%Yini)
		pop(%Xini)
		pop(%VetY)
		pop(%VetX)
		
		beq %Xfinal, %Xini, End_Dir_Inf
		j Dir_Inf_Loop

	DamaKing_Dir_Inf:

		push(%VetX)
		push($t0)
	
		addi %VetX, %VetX, 12
		li $t0, 1
		sw $t0, Dama(%VetX)

		pop($t0)
		pop(%VetX)

		j Volta_DamaKing_Dir_Inf

		Come_Dir_Inf:
		addi $a2, $a2, 8
		sw $zero, Dama($a2) # Apaga Dama
		
		beq $s7, 1, Come_P1_True
		addi $s7, $s7, -1
		
		j Volta_Dir_Inf	
	
	Come_P1_True:
		addi $s7, $s7, 1
		j Volta_Dir_Inf
		 	
	
End_Dir_Inf:

.end_macro


.macro Dir_Sup(%Xini, %Yini, %VetX, %VetY, %Xfinal)
	Dir_Sup_Loop:
		push(%VetX)
		push(%VetY)

		push($t0)
		push($t1)
		push($a2)
		push($a3)
		
		addi $t0, %Xini, 1
		addi $t1, %Yini, -1
		
		move $a2, $t0
		move $a3, $t1 
		
		jal BuscaNoVetor #Se retornar -1, nao comera ninguem, caso contrario sim
		
		bne $a2, -1, Come_Dir_Sup
	Volta_Dir_Sup:
		pop($a3)
		pop($a2)	
		pop($t1)
		pop($t0)

		beq %Xfinal, 88, DamaKing_Dir_Sup #COLUNA B
	
	Volta_DamaKing_Dir_Sup:
						
		addi %Xini, %Xini, 1 #Incrementa X
		addi %Yini, %Yini, -1 #Incrementa Y
		
		push(%Xini)
		push(%Yini)
		push(%Xfinal)
						
		sw %Xini, Dama(%VetX) #Salva X 		
		sw %Yini, Dama(%VetY) #Salva Y

		jal Tabuleiro
  		jal PrintVetor
		
		pop(%Xfinal)
		pop(%Yini)
		pop(%Xini)
		pop(%VetY)
		pop(%VetX)
		
		beq %Xfinal, %Xini, End_Dir_Sup
		j Dir_Sup_Loop
	
	DamaKing_Dir_Sup:

		push(%VetX)
		push($t0)
	
		addi %VetX, %VetX, 12
		li $t0, 1
		sw $t0, Dama(%VetX)

		pop($t0)
		pop(%VetX)

		j Volta_DamaKing_Dir_Sup

				
	Come_Dir_Sup:
		addi $a2, $a2, 8
		sw $zero, Dama($a2) # Apaga Dama
		
		beq $s7, 1, Come_P1_True
		addi $s7, $s7, -1
		
		j Volta_Dir_Sup	
	
	Come_P1_True:
		addi $s7, $s7, 1
		j Volta_Dir_Sup
		
	End_Dir_Sup:

.end_macro

.macro Esq_Inf(%Xini, %Yini, %VetX, %VetY, %Xfinal)
	Esq_Inf_Loop:
		push(%VetX)
		push(%VetY)
	
		push($t0)
		push($t1)
		push($a2)
		push($a3)
		
		addi $t0, %Xini, -1
		addi $t1, %Yini, 1
		
		move $a2, $t0
		move $a3, $t1 
		
		jal BuscaNoVetor #Se retornar -1, nao comera ninguem, caso contrario sim
		
		bne $a2, -1, Come_Esq_Inf
	Volta_Esq_Inf:
		pop($a3)
		pop($a2)	
		pop($t1)
		pop($t0)
		
		beq %Xfinal, 32, DamaKing_Esq_Inf #COLUNA A
	
	Volta_DamaKing_Esq_Inf:
								
		addi %Xini, %Xini, -1 #Incrementa X
		addi %Yini, %Yini, 1 #Incrementa Y
		
		push(%Xini)
		push(%Yini)
		push(%Xfinal)
						
		sw %Xini, Dama(%VetX) #Salva X 		
		sw %Yini, Dama(%VetY) #Salva Y

		jal Tabuleiro
  		jal PrintVetor
		
		pop(%Xfinal)
		pop(%Yini)
		pop(%Xini)
		pop(%VetY)
		pop(%VetX)
		
		beq %Xfinal, %Xini, End_Esq_Inf
		j Esq_Inf_Loop

	DamaKing_Esq_Inf:

		push(%VetX)
		push($t0)
	
		addi %VetX, %VetX, 12
		li $t0, 1
		sw $t0, Dama(%VetX)

		pop($t0)
		pop(%VetX)

		j Volta_DamaKing_Esq_Inf

						
	Come_Esq_Inf:
		addi $a2, $a2, 8
		sw $zero, Dama($a2) # Apaga Dama
		
		beq $s7, 1, Come_P1_True
		addi $s7, $s7, -1
		
		j Volta_Esq_Inf	
	
	Come_P1_True:
		addi $s7, $s7, 1
		j Volta_Esq_Inf
		
	End_Esq_Inf:

.end_macro
	
.macro Esq_Sup(%Xini, %Yini, %VetX, %VetY, %Xfinal)
	Esq_Sup_Loop:
		push(%VetX)
		push(%VetY)
		
		push($t0)
		push($t1)
		push($a2)
		push($a3)
		
		addi $t0, %Xini, -1
		addi $t1, %Yini, -1
		
		move $a2, $t0
		move $a3, $t1 
		
		jal BuscaNoVetor #Se retornar -1, nao comera ninguem, caso contrario sim
		bne $a2, -1, Come_Esq_Sup
	Volta_Esq_Sup:
		pop($a3)
		pop($a2)	
		pop($t1)
		pop($t0)
		
		beq %Xfinal, 32, DamaKing_Esq_Sup #COLUNA A
	
	Volta_DamaKing_Esq_Sup:
		addi %Xini, %Xini, -1 #Incrementa X
		addi %Yini, %Yini, -1 #Incrementa Y
		
		push(%Xini)
		push(%Yini)
		push(%Xfinal)
						
		sw %Xini, Dama(%VetX) #Salva X 		
		sw %Yini, Dama(%VetY) #Salva Y

		jal Tabuleiro
  		jal PrintVetor
		
		pop(%Xfinal)
		pop(%Yini)
		pop(%Xini)
		pop(%VetY)
		pop(%VetX)
		
		beq %Xfinal, %Xini, End_Esq_Sup
		j Esq_Sup_Loop

	DamaKing_Esq_Sup:

		push(%VetX)
		push($t0)
	
		addi %VetX, %VetX, 12
		li $t0, 1
		sw $t0, Dama(%VetX)

		pop($t0)
		pop(%VetX)

		j Volta_DamaKing_Esq_Sup
	
	Come_Esq_Sup:
		addi $a2, $a2, 8
		sw $zero, Dama($a2) # Apaga Dama
		
		beq $s7, 1, Come_P1_True
		addi $s7, $s7, -1
		
		j Volta_Esq_Sup	
	
	Come_P1_True:
		addi $s7, $s7, 1
		j Volta_Esq_Sup	
		
	End_Esq_Sup:

.end_macro

.macro ConverteX (%valor, %destino)
	la    $t0, Alfabeto
	
	lb    $t1, 0($t0)
	beq %valor, $t1, converteA
		
	lb    $t1, 1($t0)
	beq %valor, $t1, converteB
	
	lb    $t1, 2($t0)
	beq %valor, $t1, converteC
	
	lb    $t1, 3($t0)
	beq %valor, $t1, converteD
	
	lb    $t1, 4($t0)
	beq %valor, $t1, converteE
	
	lb    $t1, 5($t0)
	beq %valor, $t1, converteF
	
	lb    $t1, 6($t0)
	beq %valor, $t1, converteG
	
	lb    $t1, 7($t0)
	beq %valor, $t1, converteH
	
	#lb    $t1, 8($t0)
	#beq %valor, $t1, converteFinal
	
	lb    $t1, 8($t0)
	beq %valor, $t1, convertePassaVez
	
	li %destino, 0
	j end_converteX
	
	
	converteA:
		li %destino, 32
		j end_converteX
	converteB:
		li %destino, 40
		j end_converteX
	converteC:
		li %destino, 48
		j end_converteX
	converteD:
		li %destino, 56
		j end_converteX
	converteE:
		li %destino, 64
		j end_converteX
	converteF:
		li %destino, 72
		j end_converteX
	converteG:
		li %destino, 80
		j end_converteX
	converteH:
		li %destino, 88
		j end_converteX
	convertePassaVez:
		li $s6, 1
		beq $s7, 1, igualAUm
		j igualADois
		igualAUm:
			addi $s7, $s7, 1
			j end_converteXDef
		igualADois:
			addi $s7, $s7, -1
			j end_converteXDef
		
	#converteFinal:
	#	li $v0, 10
	#	syscall
	#	j end_converteX
		
	end_converteX:
		li $s6, 0
		j end_converteXDef
		
end_converteXDef:
	
		
.end_macro

.macro ConverteY (%valor, %destino)
	beq %valor, 1, converte1
	beq %valor, 2, converte2
	beq %valor, 3, converte3
	beq %valor, 4, converte4
	
	beq %valor, 5, converte5 
	beq %valor, 6, converte6
	beq %valor, 7, converte7
	beq %valor, 8, converte8
	li %destino, 0
	j end_converteY
	
	converte1:
		li %destino, 60
		j end_converteY
	converte2:
		li %destino, 68
		j end_converteY
	converte3:
		li %destino, 76
		j end_converteY
	converte4:
		li %destino, 84
		j end_converteY
	
	converte5:
		li %destino, 92
		j end_converteY
	converte6:
		li %destino, 100
		j end_converteY
	converte7:
		li %destino, 108
		j end_converteY
	converte8:
		li %destino, 116
		j end_converteY
		
	end_converteY:
.end_macro

.macro DecideMacro(%Xini, %Yini, %VetX, %VetY, %Xfinal, %Yfinal)
	bgt %Xfinal, %Xini, Direitas #Xfinal eh maior que Xinicial
	blt %Yfinal, %Yini, EsquerdaSuperior #Else...Yfinal eh menor que Yini 
	
	EsquerdaInferior:	Esq_Inf(%Xini, %Yini, %VetX, %VetY, %Xfinal)
				j Fim_Decide 
	EsquerdaSuperior:	Esq_Sup(%Xini, %Yini, %VetX, %VetY, %Xfinal)		
				j Fim_Decide
	
	Direitas:
		blt %Yfinal, %Yini, DireitaSuperior #Else...Yfinal eh menor que Yini
	DireitaInferior: Dir_Inf(%Xini, %Yini, %VetX, %VetY, %Xfinal)
			j Fim_Decide
	DireitaSuperior: Dir_Sup(%Xini, %Yini, %VetX, %VetY, %Xfinal)
			j Fim_Decide
Fim_Decide:
.end_macro

.macro PrintVezP1()

	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
	lw $a2, preto
	li $a0, 105
	li $a1, 53
	li $a3, 118
	jal Horizontal
	
	lw $a2, branco

	li $a0, 10
	li $a1, 53
	li $a3, 23
	jal Horizontal
	
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
	
.end_macro

.macro PrintVezP2()

	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
	lw $a2, branco
	li $a0, 105
	li $a1, 53
	li $a3, 118
	jal Horizontal
	
	lw $a2, preto

	li $a0, 10
	li $a1, 53
	li $a3, 23
	jal Horizontal
	
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
  	
.end_macro

.macro Jogo()
	
ComparaVez:
	beq $s7, 1, VezPlayerUm # confere de qual jogador eh a vez
	
	j VezPlayerDois
	
	VezPlayerUm: #if($s7==1), vez do jogador 1
		PrintVezP1
		j InicioJogo
	
	VezPlayerDois: #if($s7==2), vez do jogador 2
		PrintVezP2
		j InicioJogo	

InicioJogo:

	scanChar($t6) #LENDO A COORDENADA INICIAL
	ConverteX($t6, $t6) # X0
	beq $s6, 1, ComparaVez
	
	scanInt($t7)
	ConverteY($t7, $t7) # Y0
	
	move $a2, $t6
	move $a3, $t7
	
	jal VerificaCoordenadas
	beq $a2, -1, AuxiliarJogoPosInvalida
	
	scanChar($t4) #LENDO A COORDENADA FINAL
	scanInt($t5)
	
	ConverteX($t4, $t4) # XFINAL
	ConverteY($t5, $t5) # YFINAL
	
	move $a2, $t4
	move $a3, $t5
	
	jal VerificaCoordenadas
	beq $a2, -1, AuxiliarJogoPosInvalida
	 
	jal BuscaNoVetor
	bne $a2, -1, AuxiliarJogoPosInvalida #CASO A POSICAO SEJA INVALIDA, ENTRA COM OUTRA POSICAO
	# ESSE BRANCH PRECISA SER 'NOT EQUAL', SENAO NENHUMA POSICAO QUE ESTIVER LIVRE PRA SER USADA VAI SER LIDA COMO VALIDA
	
	move $a0, $t4
	move $a1, $t5			
	move $a2, $t6
	move $a3, $t7
	
	jal VerificaValidade
	beq $a2, -1, AuxiliarJogoMovInvalido
	
	jal BuscaNoVetor
	
	beq $a2, -1, AuxiliarJogoPosInvalida #CASO A POSICAO SEJA INVALIDA, ENTRA COM OUTRA POSICAO
	
	
	blt $a2, 192, VerificaP1
	bge $a2, 192, VerificaP2
	
VerificaP1:

	bne $s7, 1, AuxiliarJogoPecaInvalida
	j PraOndeVoltar
VerificaP2:

	bne $s7, 2, AuxiliarJogoPecaInvalida
	j PraOndeVoltar
	
	
PraOndeVoltar:
	push($a2)
	addi $a2, $a2, 12 # Acessando a posicao para verificar se a peca eh dama
	lw $t8, Dama($a2)
	beq $t8, 1, Continuacao # Caso seja dama, qualquer movimento em quantidade de casa eh valido
	
	move $t8, $t6 # $t8 contem o valor X0
	move $t9, $t4 # $t4 contem o valor XFINAL
	sub $t8, $t9, $t8

	beq $t8, 16, Continuacao # Para o movimento ser valida, a diferenca entre XFINAL e X0 deve ser 8, -8, 16 ou -16
	beq $t8, 8, Continuacao
	beq $t8, -16, Continuacao
	beq $t8, -8, Continuacao

	j AuxiliarJogoMovInvalido
			
Continuacao:
	
	pop($a2)
	
 	#(%Xini, %Yini, %VetX, %VetY, %Xfinal, %Yfinal)
	DecideMacro($t6, $t7, $a2, $a3, $t4, $t5)
	j FimJogo
	
	AuxiliarJogoPosInvalida:
	
		printString(PosicaoInvalida)
		j InicioJogo
		
	AuxiliarJogoMovInvalido:
	
		printString(MovimentoInvalida)
		j InicioJogo
		
	AuxiliarJogoPecaInvalida:
	
		printString(JogadorInvalido)
		j InicioJogo
	
	FimJogo:

		beq $s7, 1, AuxPlayerUm #CASO ESSA VEZ TENHA SIDO DO JOGADOR 1, A PROXIMA EH DO JOGADOR 2
		beq $s7, 2, AuxPlayerDois #CASO ESSA VEZ TENHA SIDO DO JOGADOR 2, A PROXIMA EH DO JOGADOR 1
	
	AuxPlayerUm:

		addi $s7, $s7, 1
		j FimDefinitivo
	AuxPlayerDois:

		addi $s7, $s7, -1
		j FimDefinitivo
		
	FimDefinitivo:
	
.end_macro


main:	
	li $a0, 0 #ZERANDO
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $s7, 0 
	
	jal ClearBoard
	jal Tabuleiro
  	jal PrintLayout
  	jal PrintVetor
	
	add $s7, $s7, 1 #A PRIMEIRA JOGADA PERTENCE AO PLAYER UM

Main_Inicio:

	Jogo
	push($a2)
	push($a3)
	jal VetorVazio 
	beq $a2, 12, P2_Win
	beq $a3, 12, P1_Win
	pop($a3)
	pop($a2)
	j Main_Inicio
	j end

Tabuleiro:
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
	############### Parte Branco ###############
	lw $a2, branco
	
	li $a0, 32
	li $a1, 60
	li $a3, 67
	jal PrintQuadrado

	li $a0, 32
	li $a1, 76
	li $a3, 83
	jal PrintQuadrado

	li $a0, 32
	li $a1, 92
	li $a3, 99
	jal PrintQuadrado

	li $a0, 32
	li $a1, 108
	li $a3, 115
	jal PrintQuadrado

	li $a0, 40
	li $a1, 68
	li $a3, 75
	jal PrintQuadrado
	
	li $a0, 40
	li $a1, 84
	li $a3, 91
	jal PrintQuadrado
	
	li $a0, 40
	li $a1, 100
	li $a3, 107
	jal PrintQuadrado

	li $a0, 40
	li $a1, 116
	li $a3, 123
	jal PrintQuadrado
		
	############### Parte Preto ###############
	lw $a2, preto
	
	li $a0, 32
	li $a1, 68
	li $a3, 75
	jal PrintQuadrado

	li $a0, 32
	li $a1, 84
	li $a3, 91
	jal PrintQuadrado

	li $a0, 32
	li $a1, 100
	li $a3, 107
	jal PrintQuadrado

	li $a0, 32
	li $a1, 116
	li $a3, 123
	jal PrintQuadrado

	li $a0, 40
	li $a1, 60
	li $a3, 67
	jal PrintQuadrado
	
	li $a0, 40
	li $a1, 76
	li $a3, 83
	jal PrintQuadrado
	
	li $a0, 40
	li $a1, 92
	li $a3, 99
	jal PrintQuadrado

	li $a0, 40
	li $a1, 108
	li $a3, 115
	jal PrintQuadrado
	
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
	
  	jr $ra
  	

PrintQuadrado: 
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical	
	
	addi $a0, $a0, 1	
	addi $a0, $a0, 8
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical	

	addi $a0, $a0, 1	
	addi $a0, $a0, 8
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical
	
	addi $a0, $a0, 1
	addi $a0, $a0, 8
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical	

	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
	jr  $ra


PrintLayout:
	
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
	
	################# COORDENADAS ##################
	lw $a2, cinza
	
	###### 1 ######
	li $a0, 24
	li $a1, 63
	jal Pixel
	
	li $a0, 25
	li $a1, 62
	jal Pixel
	
	li $a0, 26
	li $a1, 61
	li $a3, 66
	jal Vertical
	
	li $a0, 24
	li $a1, 66
	li $a3, 27
	jal Horizontal
	
	###### 2 ######
	li $a0, 24
	li $a1, 70
	jal Pixel
	
	li $a0, 25
	li $a1, 69
	li $a3, 26
	jal Horizontal
	
	li $a0, 27
	li $a1, 70
	jal Pixel
	
	li $a0, 26
	li $a1, 71
	jal Pixel
	
	li $a0, 25
	li $a1, 72
	jal Pixel
	
	li $a0, 24
	li $a1, 73
	jal Pixel
	
	li $a0, 24
	li $a1, 74
	li $a3, 27
	jal Horizontal
	
	###### 3 ######
	li $a0, 24
	li $a1, 77
	li $a3, 27
	jal Horizontal
	
	li $a0, 27
	li $a1, 78
	jal Pixel
	
	li $a0, 26
	li $a1, 79
	jal Pixel
	
	li $a0, 27
	li $a1, 80
	li $a3, 81
	jal Vertical
	
	li $a0, 25
	li $a1, 82
	li $a3, 26
	jal Horizontal
	
	li $a0, 24
	li $a1, 81
	jal Pixel
	
	###### 4 ######
	li $a0, 24
	li $a1, 85
	li $a3, 87
	jal Vertical
	
	li $a0, 27
	li $a1, 85
	li $a3, 90
	jal Vertical
	
	li $a0, 24
	li $a1, 87
	li $a3, 27
	jal Horizontal
	
	###### 5 ######
	li $a0, 24
	li $a1, 93
	li $a3, 27
	jal Horizontal
	
	li $a0, 24
	li $a1, 93
	li $a3, 94
	jal Vertical
	
	li $a0, 24
	li $a1, 95
	li $a3, 26
	jal Horizontal
	
	li $a0, 27
	li $a1, 96
	li $a3, 97
	jal Vertical
	
	li $a0, 25
	li $a1, 98
	li $a3, 26
	jal Horizontal
	
	li $a0, 24
	li $a1, 97
	jal Pixel
	
	###### 6 ######
	li $a0, 25
	li $a1, 101
	li $a3, 26
	jal Horizontal
	
	li $a0, 24
	li $a1, 102
	li $a3, 105
	jal Vertical
	
	li $a0, 24
	li $a1, 104
	li $a3, 26
	jal Horizontal
	
	li $a0, 25
	li $a1, 106
	li $a3, 26
	jal Horizontal
	
	li $a0, 27
	li $a1, 105
	jal Pixel
	
	li $a0, 27
	li $a1, 102
	jal Pixel
	
	###### 7 ######
	li $a0, 27
	li $a1, 109
	li $a3, 114
	jal Vertical
	
	li $a0, 24
	li $a1, 109
	li $a3, 27
	jal Horizontal
	
	###### 8 ######
	li $a0, 25
	li $a1, 117
	li $a3, 26
	jal Horizontal
	
	li $a0, 25
	li $a1, 119
	li $a3, 26
	jal Horizontal
	
	li $a0, 25
	li $a1, 122
	li $a3, 26
	jal Horizontal
	
	li $a0, 24
	li $a1, 118
	jal Pixel
	
	li $a0, 27
	li $a1, 118
	jal Pixel
	
	li $a0, 24
	li $a1, 120
	li $a3, 121
	jal Vertical
	
	li $a0, 27
	li $a1, 120
	li $a3, 121
	jal Vertical
	
	###### A ######
	li $a0, 34
	li $a1, 51
	li $a3, 55
	jal Vertical
	
	li $a0, 37
	li $a1, 51
	li $a3, 55
	jal Vertical
	
	li $a0, 35
	li $a1, 50
	li $a3, 36
	jal Horizontal
	
	li $a0, 35
	li $a1, 52
	li $a3, 36
	jal Horizontal
	
	###### B ######
	li $a0, 42
	li $a1, 50
	li $a3, 55
	jal Vertical
	
	li $a0, 43
	li $a1, 50
	li $a3, 44
	jal Horizontal
	
	li $a0, 43
	li $a1, 52
	li $a3, 44
	jal Horizontal
	
	li $a0, 43
	li $a1, 55
	li $a3, 44
	jal Horizontal
	
	li $a0, 45
	li $a1, 53
	li $a3, 54
	jal Vertical
	
	li $a0, 45
	li $a1, 51
	jal Pixel
	
	###### C ######
	li $a0, 51
	li $a1, 50
	li $a3, 52
	jal Horizontal
	
	li $a0, 50
	li $a1, 51
	li $a3, 54
	jal Vertical
	
	li $a0, 51
	li $a1, 55
	li $a3, 52
	jal Horizontal
	
	li $a0, 45
	li $a1, 51
	jal Pixel
	
	li $a0, 53
	li $a1, 51
	jal Pixel

	li $a0, 53
	li $a1, 54
	jal Pixel
	
	###### D ######
	li $a0, 58
	li $a1, 50
	li $a3, 60
	jal Horizontal
	
	li $a0, 58
	li $a1, 55
	li $a3, 60
	jal Horizontal
	
	li $a0, 58
	li $a1, 50
	li $a3, 55
	jal Vertical
	
	li $a0, 61
	li $a1, 51
	li $a3, 54
	jal Vertical
	
	###### E ######
	li $a0, 66
	li $a1, 50
	li $a3, 55
	jal Vertical
	
	li $a0, 66
	li $a1, 50
	li $a3, 69
	jal Horizontal
	
	li $a0, 66
	li $a1, 52
	li $a3, 68
	jal Horizontal
	
	li $a0, 66
	li $a1, 55
	li $a3, 69
	jal Horizontal
	
	###### F ######
	li $a0, 74
	li $a1, 50
	li $a3, 77
	jal Horizontal
	
	li $a0, 74
	li $a1, 52
	li $a3, 76
	jal Horizontal
	
	li $a0, 74
	li $a1, 50
	li $a3, 55
	jal Vertical
	
	###### G ######
	li $a0, 83
	li $a1, 50
	li $a3, 84
	jal Horizontal
	
	li $a0, 84
	li $a1, 53
	li $a3, 85
	jal Horizontal
	
	li $a0, 83
	li $a1, 55
	li $a3, 84
	jal Horizontal
	
	li $a0, 82
	li $a1, 51
	li $a3, 54
	jal Vertical
	
	li $a0, 85
	li $a1, 54
	jal Pixel
	
	li $a0, 85
	li $a1, 51
	jal Pixel
	
	###### H ######
	li $a0, 90
	li $a1, 52
	li $a3, 93
	jal Horizontal
	
	li $a0, 90
	li $a1, 50
	li $a3, 55
	jal Vertical
	
	li $a0, 93
	li $a1, 50
	li $a3, 55
	jal Vertical
	
	
	################# BORDA ##################
	
	lw $a2, cinza
	
	li $a0, 31
	li $a1, 59
	li $a3, 123
	jal Vertical
	
	li $a0, 32
	li $a1, 59
	li $a3, 95
	jal Horizontal
	
	li $a0, 96
	li $a1, 59
	li $a3, 123
	jal Vertical

	li $a0, 31
	li $a1, 124
	li $a3, 96
	jal Horizontal
		
	
	li $a0, 29
	li $a1, 58
	li $a3, 126
	jal Vertical
	
	li $a0, 29
	li $a1, 57
	li $a3, 98
	jal Horizontal
	
	li $a0, 98
	li $a1, 58
	li $a3, 126
	jal Vertical
	
	li $a0, 29
	li $a1, 126
	li $a3, 98
	jal Horizontal		
				
	lw $a2, branco
	################# D ##################

	li $a0, 32
	li $a1, 8
	li $a3, 29
	jal Vertical

	li $a0, 33
	li $a1, 8
	li $a3, 29
	jal Vertical
	
	li $a0, 34
	li $a1, 8
	li $a3, 39
	jal Horizontal

	li $a0, 34
	li $a1, 9
	li $a3, 41
	jal Horizontal
	
	li $a0, 40
	li $a1, 10
	li $a3, 42
	jal Horizontal

	li $a0, 41
	li $a1, 11
	li $a3, 43
	jal Horizontal
	
	li $a0, 42
	li $a1, 12
	li $a3, 25
	jal Vertical

	li $a0, 43
	li $a1, 12
	li $a3, 25
	jal Vertical
	
	li $a0, 41
	li $a1, 26
	li $a3, 43
	jal Horizontal
	
	li $a0, 40
	li $a1, 27
	li $a3, 42
	jal Horizontal

	li $a0, 32
	li $a1, 28
	li $a3, 41
	jal Horizontal
	
	li $a0, 32
	li $a1, 29
	li $a3, 39
	jal Horizontal

	################# A ##################

	li $a0, 46
	li $a1, 12
	li $a3, 29
	jal Vertical

	li $a0, 47
	li $a1, 12
	li $a3, 29
	jal Vertical
	
	li $a0, 56
	li $a1, 12
	li $a3, 29
	jal Vertical

	li $a0, 57
	li $a1, 12
	li $a3, 29
	jal Vertical

	li $a0, 48
	li $a1, 19
	li $a3, 55
	jal Horizontal
	
	li $a0, 48
	li $a1, 20
	li $a3, 55
	jal Horizontal

	li $a0, 47
	li $a1, 11
	li $a3, 13
	jal Vertical
	
	li $a0, 56
	li $a1, 11
	li $a3, 13
	jal Vertical
	
	li $a0, 48
	li $a1, 10
	li $a3, 12
	jal Vertical
	
	li $a0, 55
	li $a1, 10
	li $a3, 12
	jal Vertical
	
	li $a0, 49
	li $a1, 9
	li $a3, 11
	jal Vertical
	
	li $a0, 54
	li $a1, 9
	li $a3, 11
	jal Vertical
	
	li $a0, 50
	li $a1, 8
	li $a3, 53
	jal Horizontal
	
	li $a0, 50
	li $a1, 9
	li $a3, 53
	jal Horizontal

	li $a0, 50
	li $a1, 10
	li $a3, 53
	jal Horizontal
	
	################# M ##################
	li $a0, 60
	li $a1, 8
	li $a3, 29
	jal Vertical

	li $a0, 61
	li $a1, 9
	li $a3, 29
	jal Vertical

	li $a0, 71
	li $a1, 8
	li $a3, 29
	jal Vertical

	li $a0, 70
	li $a1, 9
	li $a3, 29
	jal Vertical
	
	li $a0, 62
	li $a1, 10
	li $a3, 12
	jal Vertical

	li $a0, 69
	li $a1, 10
	li $a3, 12
	jal Vertical

	li $a0, 63
	li $a1, 11
	li $a3, 13
	jal Vertical

	li $a0, 68
	li $a1, 11
	li $a3, 13
	jal Vertical

	li $a0, 64
	li $a1, 12
	li $a3, 14
	jal Vertical

	li $a0, 67
	li $a1, 12
	li $a3, 14
	jal Vertical

	li $a0, 65
	li $a1, 13
	li $a3, 15
	jal Vertical

	li $a0, 66
	li $a1, 13
	li $a3, 15
	jal Vertical
	
	################# A ##################
	
	li $a0, 74
	li $a1, 12
	li $a3, 29
	jal Vertical

	li $a0, 75
	li $a1, 12
	li $a3, 29
	jal Vertical
	
	li $a0, 84
	li $a1, 12
	li $a3, 29
	jal Vertical

	li $a0, 85
	li $a1, 12
	li $a3, 29
	jal Vertical

	li $a0, 76
	li $a1, 19
	li $a3, 83
	jal Horizontal
	
	li $a0, 76
	li $a1, 20
	li $a3, 83
	jal Horizontal

	li $a0, 75
	li $a1, 11
	li $a3, 13
	jal Vertical
	
	li $a0, 84
	li $a1, 11
	li $a3, 13
	jal Vertical
	
	li $a0, 76
	li $a1, 10
	li $a3, 12
	jal Vertical
	
	li $a0, 83
	li $a1, 10
	li $a3, 12
	jal Vertical
	
	li $a0, 77
	li $a1, 9
	li $a3, 11
	jal Vertical
	
	li $a0, 82
	li $a1, 9
	li $a3, 11
	jal Vertical
	
	li $a0, 78
	li $a1, 8
	li $a3, 81
	jal Horizontal
	
	li $a0, 78
	li $a1, 9
	li $a3, 81
	jal Horizontal

	li $a0, 78
	li $a1, 10
	li $a3, 81
	jal Horizontal

	################# S ##################
	
	li $a0, 92
	li $a1, 8
	li $a3, 97
	jal Horizontal

	li $a0, 90
	li $a1, 9
	li $a3, 98
	jal Horizontal
	
	li $a0, 89
	li $a1, 10
	li $a3, 91
	jal Horizontal

	li $a0, 97
	li $a1, 10
	li $a3, 99
	jal Horizontal
	
	li $a0, 98
	li $a1, 11
	li $a3, 99
	jal Horizontal

	li $a0, 88
	li $a1, 11
	li $a3, 14
	jal Vertical
	
	li $a0, 89
	li $a1, 11
	li $a3, 14
	jal Vertical
	
	li $a0, 90
	li $a1, 11
	li $a3, 14
	jal Vertical
	
	li $a0, 99
	li $a1, 12
	jal Pixel

	li $a0, 89
	li $a1, 15
	li $a3, 91
	jal Horizontal
	
	li $a0, 90
	li $a1, 27
	li $a3, 29
	jal Vertical

	li $a0, 90
	li $a1, 16
	li $a3, 92
	jal Horizontal
	
	li $a0, 91
	li $a1, 17
	li $a3, 94
	jal Horizontal

	li $a0, 92
	li $a1, 18
	li $a3, 96
	jal Horizontal
	
	li $a0, 93
	li $a1, 19
	li $a3, 97
	jal Horizontal
	
	li $a0, 95
	li $a1, 20
	li $a3, 97
	jal Horizontal
	
	li $a0, 97
	li $a1, 20
	li $a3, 21
	jal Vertical
	
	li $a0, 97
	li $a1, 26
	li $a3, 29
	jal Vertical		

	li $a0, 98
	li $a1, 20
	li $a3, 28
	jal Vertical
	
	li $a0, 99
	li $a1, 21
	li $a3, 26
	jal Vertical

	li $a0, 88
	li $a1, 25
	jal Pixel
	
	li $a0, 96
	li $a1, 27
	jal Pixel

	li $a0, 88
	li $a1, 26
	li $a3, 89
	jal Horizontal
	
	li $a0, 88
	li $a1, 27
	li $a3, 90
	jal Horizontal

	li $a0, 89
	li $a1, 28
	li $a3, 97
	jal Horizontal
	
	li $a0, 90
	li $a1, 29
	li $a3, 96
	jal Horizontal

	################# PLAYERS ##################
	
	
	lw $a2, vermelho
	################# P ##################

	li $a0, 10
	li $a1, 41
	li $a3, 50
	jal Vertical

	li $a0, 11
	li $a1, 41
	li $a3, 14
	jal Horizontal

	li $a0, 15
	li $a1, 42
	li $a3, 45
	jal Vertical

	li $a0, 11
	li $a1, 46
	li $a3, 14
	jal Horizontal

	################# 1 ##################

	li $a0, 21
	li $a1, 43
	li $a3, 49
	jal Vertical

	li $a0, 20
	li $a1, 44
	jal Pixel

	li $a0, 19
	li $a1, 45
	jal Pixel

	li $a0, 19
	li $a1, 50
	li $a3, 23
	jal Horizontal

	################# P ##################

	lw $a2, azul
	
	li $a0, 105
	li $a1, 41
	li $a3, 50
	jal Vertical

	li $a0, 105
	li $a1, 41
	li $a3, 109
	jal Horizontal

	li $a0, 110
	li $a1, 42
	li $a3, 45
	jal Vertical

	li $a0, 106
	li $a1, 46
	li $a3, 109
	jal Horizontal

	################# 2 ##################

	li $a0, 114
	li $a1, 44
	jal Pixel

	li $a0, 115
	li $a1, 43
	li $a3, 117
	jal Horizontal

	li $a0, 118
	li $a1, 44
	li $a3, 45
	jal Vertical

	li $a0, 117
	li $a1, 46
	jal Pixel

	li $a0, 116
	li $a1, 47
	jal Pixel

	li $a0, 115
	li $a1, 48
	jal Pixel

	li $a0, 114
	li $a1, 49
	li $a3, 50
	jal Vertical

	li $a0, 115
	li $a1, 50
	li $a3, 117
	jal Horizontal

	li $a0, 118
	li $a1, 49
	li $a3, 50
	jal Vertical

	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
	
	jr $ra
	

P1_Win: 

	#push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
	
	jal ClearBoard

#################### P
	lw $a2, vermelho
	
	li $a0, 48
	li $a1, 33
	li $a3, 54
	jal Vertical
	
	li $a0, 49
	li $a1, 33
	li $a3, 54
	jal Vertical

	li $a0, 50
	li $a1, 33
	li $a3, 57
	jal Horizontal
	
	li $a0, 50
	li $a1, 34
	li $a3, 58
	jal Horizontal
	
	li $a0, 57
	li $a1, 35
	li $a3, 59
	jal Horizontal
	
	li $a0, 57
	li $a1, 42
	li $a3, 59
	jal Horizontal

	li $a0, 58
	li $a1, 36
	li $a3, 60
	jal Horizontal
	
	li $a0, 58
	li $a1, 41
	li $a3, 60
	jal Horizontal

	li $a0, 59
	li $a1, 37
	li $a3, 61
	jal Horizontal
	
	li $a0, 59
	li $a1, 40
	li $a3, 61
	jal Horizontal

	li $a0, 60
	li $a1, 38
	li $a3, 61
	jal Horizontal
	
	li $a0, 60
	li $a1, 39
	li $a3, 61
	jal Horizontal

	li $a0, 50
	li $a1, 43
	li $a3, 58
	jal Horizontal	
	
	li $a0, 50
	li $a1, 44
	li $a3, 57
	jal Horizontal	

#################### 1
	li $a0, 72
	li $a1, 33
	li $a3, 54
	jal Vertical
	
	li $a0, 73
	li $a1, 33
	li $a3, 54
	jal Vertical
	
	li $a0, 65
	li $a1, 53
	li $a3, 78
	jal Horizontal
	
	li $a0, 65
	li $a1, 54
	li $a3, 78
	jal Horizontal
	
	li $a0, 71
	li $a1, 34
	li $a3, 36
	jal Vertical		
				
	li $a0, 70
	li $a1, 35
	li $a3, 37
	jal Vertical			
	
	li $a0, 69
	li $a1, 36
	li $a3, 38
	jal Vertical
	
	li $a0, 68
	li $a1, 37
	li $a3, 39
	jal Vertical
	
	li $a0, 67
	li $a1, 38
	li $a3, 39
	jal Vertical
	
#################### W
	li $a0, 39
	li $a1, 65
	li $a3, 86
	jal Vertical

	li $a0, 40
	li $a1, 65
	li $a3, 86
	jal Vertical

	li $a0, 41
	li $a1, 84
	li $a3, 86
	jal Vertical

	li $a0, 42
	li $a1, 83
	li $a3, 85
	jal Vertical
	
	li $a0, 43
	li $a1, 82
	li $a3, 84
	jal Vertical

	li $a0, 44
	li $a1, 81
	li $a3, 83
	jal Vertical

	li $a0, 45
	li $a1, 80
	li $a3, 82
	jal Vertical

	li $a0, 46
	li $a1, 79
	li $a3, 81
	jal Vertical

	li $a0, 47
	li $a1, 80
	li $a3, 82
	jal Vertical

	li $a0, 48
	li $a1, 81
	li $a3, 83
	jal Vertical

	li $a0, 49
	li $a1, 82
	li $a3, 84
	jal Vertical

	li $a0, 50
	li $a1, 83
	li $a3, 85
	jal Vertical
	
	li $a0, 51
	li $a1, 84
	li $a3, 86
	jal Vertical
	
	li $a0, 52
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	li $a0, 53
	li $a1, 65 
	li $a3, 86
	jal Vertical
#################### I
	li $a0, 57
	li $a1, 65
	li $a3, 68
	jal Horizontal
	
	li $a0, 57
	li $a1, 66
	li $a3, 68
	jal Horizontal
	
	li $a0, 62
	li $a1, 67
	li $a3, 84
	jal Vertical
	
	li $a0, 63
	li $a1, 67
	li $a3, 84
	jal Vertical
	
	li $a0, 57
	li $a1, 85
	li $a3, 68
	jal Horizontal
	
	li $a0, 57
	li $a1, 86
	li $a3, 68
	jal Horizontal

#################### N
	li $a0, 73
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	li $a0, 74
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	li $a0, 75
	li $a1, 65
	li $a3, 67
	jal Vertical

	li $a0, 76
	li $a1, 66
	li $a3, 69
	jal Vertical

	li $a0, 77
	li $a1, 68
	li $a3, 71
	jal Vertical

	li $a0, 78
	li $a1, 70
	li $a3, 73
	jal Vertical

	li $a0, 79
	li $a1, 72
	li $a3, 75
	jal Vertical

	li $a0, 80
	li $a1, 74
	li $a3, 77
	jal Vertical

	li $a0, 81
	li $a1, 76
	li $a3, 79
	jal Vertical

	li $a0, 82
	li $a1, 78
	li $a3, 81
	jal Vertical
	
	li $a0, 83
	li $a1, 80
	li $a3, 83
	jal Vertical
	
	li $a0, 84
	li $a1, 82
	li $a3, 85
	jal Vertical
	
	li $a0, 85
	li $a1, 84
	li $a3, 86
	jal Vertical
	
	li $a0, 86
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	li $a0, 87
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	#pop($ra)
	
	#jr $ra
	j end

	
	
P2_Win: 

	#push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
	
	jal ClearBoard

#################### P
	lw $a2, azul
	
	li $a0, 48
	li $a1, 33
	li $a3, 54
	jal Vertical
	
	li $a0, 49
	li $a1, 33
	li $a3, 54
	jal Vertical

	li $a0, 50
	li $a1, 33
	li $a3, 57
	jal Horizontal
	
	li $a0, 50
	li $a1, 34
	li $a3, 58
	jal Horizontal
	
	li $a0, 57
	li $a1, 35
	li $a3, 59
	jal Horizontal
	
	li $a0, 57
	li $a1, 42
	li $a3, 59
	jal Horizontal

	li $a0, 58
	li $a1, 36
	li $a3, 60
	jal Horizontal
	
	li $a0, 58
	li $a1, 41
	li $a3, 60
	jal Horizontal

	li $a0, 59
	li $a1, 37
	li $a3, 61
	jal Horizontal
	
	li $a0, 59
	li $a1, 40
	li $a3, 61
	jal Horizontal

	li $a0, 60
	li $a1, 38
	li $a3, 61
	jal Horizontal
	
	li $a0, 60
	li $a1, 39
	li $a3, 61
	jal Horizontal

	li $a0, 50
	li $a1, 43
	li $a3, 58
	jal Horizontal	
	
	li $a0, 50
	li $a1, 44
	li $a3, 57
	jal Horizontal	

#################### 2
	li $a0, 68
	li $a1, 33
	li $a3, 75
	jal Horizontal
	
	li $a0, 67
	li $a1, 34
	li $a3, 76
	jal Horizontal
	
	li $a0, 66
	li $a1, 35
	li $a3, 68
	jal Horizontal
	
	li $a0, 65
	li $a1, 36
	li $a3, 67
	jal Horizontal
	
	li $a0, 65
	li $a1, 37
	li $a3, 66
	jal Horizontal
	
	li $a0, 75
	li $a1, 35
	li $a3, 77
	jal Horizontal
	
	li $a0, 76
	li $a1, 36
	li $a3, 78
	jal Horizontal
	
	li $a0, 77
	li $a1, 37
	li $a3, 78
	jal Horizontal
	
	li $a0, 77
	li $a1, 38
	li $a3, 78
	jal Horizontal
	
	li $a0, 76
	li $a1, 39
	li $a3, 78
	jal Horizontal
	
	li $a0, 75
	li $a1, 40
	li $a3, 77
	jal Horizontal
	
	li $a0, 74
	li $a1, 41
	li $a3, 76
	jal Horizontal
	
	li $a0, 73
	li $a1, 42
	li $a3, 75
	jal Horizontal
	
	li $a0, 72
	li $a1, 43
	li $a3, 74
	jal Horizontal
	
	li $a0, 71
	li $a1, 44
	li $a3, 73
	jal Horizontal
	
	li $a0, 70
	li $a1, 45
	li $a3, 72
	jal Horizontal
	
	li $a0, 69
	li $a1, 46
	li $a3, 71
	jal Horizontal
	
	li $a0, 68
	li $a1, 47
	li $a3, 70
	jal Horizontal
	
	li $a0, 67
	li $a1, 48
	li $a3, 69
	jal Horizontal
	
	li $a0, 66
	li $a1, 49
	li $a3, 68
	jal Horizontal
	
	li $a0, 65
	li $a1, 50
	li $a3, 67
	jal Horizontal
	
	li $a0, 65
	li $a1, 51
	li $a3, 66
	jal Horizontal
	
	li $a0, 65
	li $a1, 52
	li $a3, 66
	jal Horizontal
	
	li $a0, 65
	li $a1, 53
	li $a3, 78
	jal Horizontal
	
	li $a0, 65
	li $a1, 54
	li $a3, 78
	jal Horizontal
	
#################### W
	li $a0, 39
	li $a1, 65
	li $a3, 86
	jal Vertical

	li $a0, 40
	li $a1, 65
	li $a3, 86
	jal Vertical

	li $a0, 41
	li $a1, 84
	li $a3, 86
	jal Vertical

	li $a0, 42
	li $a1, 83
	li $a3, 85
	jal Vertical
	
	li $a0, 43
	li $a1, 82
	li $a3, 84
	jal Vertical

	li $a0, 44
	li $a1, 81
	li $a3, 83
	jal Vertical

	li $a0, 45
	li $a1, 80
	li $a3, 82
	jal Vertical

	li $a0, 46
	li $a1, 79
	li $a3, 81
	jal Vertical

	li $a0, 47
	li $a1, 80
	li $a3, 82
	jal Vertical

	li $a0, 48
	li $a1, 81
	li $a3, 83
	jal Vertical

	li $a0, 49
	li $a1, 82
	li $a3, 84
	jal Vertical

	li $a0, 50
	li $a1, 83
	li $a3, 85
	jal Vertical
	
	li $a0, 51
	li $a1, 84
	li $a3, 86
	jal Vertical
	
	li $a0, 52
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	li $a0, 53
	li $a1, 65 
	li $a3, 86
	jal Vertical
#################### I
	li $a0, 57
	li $a1, 65
	li $a3, 68
	jal Horizontal
	
	li $a0, 57
	li $a1, 66
	li $a3, 68
	jal Horizontal
	
	li $a0, 62
	li $a1, 67
	li $a3, 84
	jal Vertical
	
	li $a0, 63
	li $a1, 67
	li $a3, 84
	jal Vertical
	
	li $a0, 57
	li $a1, 85
	li $a3, 68
	jal Horizontal
	
	li $a0, 57
	li $a1, 86
	li $a3, 68
	jal Horizontal

#################### N
	li $a0, 73
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	li $a0, 74
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	li $a0, 75
	li $a1, 65
	li $a3, 67
	jal Vertical

	li $a0, 76
	li $a1, 66
	li $a3, 69
	jal Vertical

	li $a0, 77
	li $a1, 68
	li $a3, 71
	jal Vertical

	li $a0, 78
	li $a1, 70
	li $a3, 73
	jal Vertical

	li $a0, 79
	li $a1, 72
	li $a3, 75
	jal Vertical

	li $a0, 80
	li $a1, 74
	li $a3, 77
	jal Vertical

	li $a0, 81
	li $a1, 76
	li $a3, 79
	jal Vertical

	li $a0, 82
	li $a1, 78
	li $a3, 81
	jal Vertical
	
	li $a0, 83
	li $a1, 80
	li $a3, 83
	jal Vertical
	
	li $a0, 84
	li $a1, 82
	li $a3, 85
	jal Vertical
	
	li $a0, 85
	li $a1, 84
	li $a3, 86
	jal Vertical
	
	li $a0, 86
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	li $a0, 87
	li $a1, 65
	li $a3, 86
	jal Vertical
	
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	#pop($ra)
	
	#jr $ra
	j end

	
	
####################################
VetorVazio:
	push($ra)
	li $a2, 0
	li $a3, 0
	li $s0, 8
	Inicio_Vetor_Vazio_P1:
		
		lw $t0, Dama($s0)
		beq $t0, $zero, Conta_Mortos_P1
		Retorno_Mortos_P1:
			addi $s0, $s0, 16
			blt $s0, 200, Inicio_Vetor_Vazio_P1 

	li $s0, 200
	Inicio_Vetor_Vazio_P2:
		
		lw $t0, Dama($s0)
		beq $t0, $zero, Conta_Mortos_P2
		Retorno_Mortos_P2:
			addi $s0, $s0, 16
			blt $s0, 384, Inicio_Vetor_Vazio_P2
			j Fim_Vetor_Vazio
			
		Conta_Mortos_P1:
			addi $a2, $a2, 1
			j Retorno_Mortos_P1
		Conta_Mortos_P2:
			addi $a3, $a3, 1
			j Retorno_Mortos_P2
Fim_Vetor_Vazio:
	
	pop($ra)		
	jr $ra
	
####################################
VerificaValidade:
#$a0 � Xinicial
#$a1 � Yinicial
#$a2 � Xfinal
#$a3 � Yfinal
push($ra)
	beq $a0, $a2, FimVerificaCoordenadasInvalida
	beq $a1, $a3, FimVerificaCoordenadasInvalida
pop($ra)
jr $ra


VerificaCoordenadas:
	push($ra)
	
	blt $a2, 32, FimVerificaCoordenadasInvalida
	bgt $a2, 88, FimVerificaCoordenadasInvalida
	
	blt $a3, 60, FimVerificaCoordenadasInvalida
	bgt $a3, 116, FimVerificaCoordenadasInvalida
	
	li $t0, 32
	li $t1, 60

InicioColunaIniBranca:
	beq $a2, $t0, InicioLinhaBranca
	addi $t0, $t0, 16
	ble $t0, 80, InicioColunaIniBranca
RetornoColunaIniBranca:
	li $t0, 40
	li $t1, 68	
InicioColunaIniPreta:
	beq $a2, $t0, InicioLinhaPreta
	addi $t0, $t0, 16
	ble $t0, 88, InicioColunaIniPreta
RetornoColunaIniPreta:	
	pop($ra)
	jr $ra

FimVerificaCoordenadasInvalida:
	li $a2, -1 # Ja que nao encontrou		
	li $a3, -1
	j RetornoColunaIniPreta
			
InicioLinhaBranca:
	beq $a3, $t1, FimVerificaCoordenadasInvalida	
	
	addi $t1, $t1, 16
	ble $t1, 108, InicioLinhaBranca
	j RetornoColunaIniBranca

InicioLinhaPreta:	 
	beq $a3, $t1, FimVerificaCoordenadasInvalida
	
	addi $t1, $t1, 16
	ble $t1, 116, InicioLinhaPreta
	j RetornoColunaIniPreta

####################################
BuscaNoVetor:
	push($ra)
	push($a0) 
	push($a1) 
	#($a2) X de referencia para buscar
	#($a3) Y de referencia para buscar
	li $s1, 0 #Primeira Posi��o do Vetor
	li $s0, 8 #Terceira Posi�a� do Vetor

	Busca_Vetor_Loop:	
		lw $t1, Dama($s0) #Carrega a Cor
		beqz $t1, Busca_Proxima_Peca # Morta (se for igual a zero)
		
		addi $s0, $s0, 16 # Terceira Posicao do Vetor da ProximaPeca
		
		lw $a0, Dama($s1) # Carregando Coordenada X do Vetor
		move $s3, $s1
		beq $a0, $a2, ComparaComY
	RetornoDaComparaY:
	
		addi $s1, $s1, 16 # Pulando Vetor para a Coordenada X da Proxima Peca
		blt  $s1, 384, Busca_Vetor_Loop #Acabou o Vetor?
		
		j FimBuscaLoop
		
	Busca_Proxima_Peca: # Caso Morta, existe a proxima peca?
		addi $s1, $s1, 16 # Pula a Peca Inteira
		addi $s0, $s0, 16 # Pula a Peca Inteira	
		j Busca_Vetor_Loop
		
	ComparaComY:
		#printInt($a0)
		#printInt($a2)
		addi $s3, $s3, 4 # Pulando Vetor para a Coordenada Y
		lw $a1, Dama($s3) # Carregando Coordenada Y do Vetor
		
		bne $a1, $a3, RetornoDaComparaY
		
		move $a3, $s3 #Indice do Vetor da posi��o Y
		addi $s3, $s3, -4 #Retornando ao Indice X
		move $a2, $s3 #Indice do Vetor da posi��o X
		
		pop($a1)
		pop($a0)
		pop($ra)
		
		jr $ra
	
	FimBuscaLoop:
		
		li $a2, -1 # Ja que nao encontrou
		li $a3, -1
		
		pop($a1)
		pop($a0)
		pop($ra)
		
		jr $ra
	
######################################	

PrintVetor:
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
	li $s1, 0 #Primeira Posi��o do Vetor
	li $s0, 8 #Terceira Posi�a� do Vetor
	li $s2, -4 #Ultima Posicao, se eh damaKing 
	
	li $t6, 0 #Contador de Pontos P1
	li $t7, 0 #Contador de Pontos P2
	
	Vetor_Loop:
		
		addi $s2, $s2, 16 #Incrementando o indice da ultima posicao
		lw $s3, Dama($s2)
			
			
		lw $t1, Dama($s0) #Carrega a Cor
		beq $t1, $zero, Proxima_Peca # Morta?
		
		beq $t1, -1, Cor_P1 # Pertence ao P1
		beq $t1, 1, Cor_P2 # Pertence ao P2
		
	Retorno_Vetor:
		
		addi $s0, $s0, 16 # Terceira Posicao do Vetor da ProximaPeca
		
		lw $a0, Dama($s1) # Carregando Coordenada X do Vetor
		addi $s1, $s1, 4 # Pulando Vetor para a Coordenada Y
		
		lw $a1, Dama($s1) # Carregando Coordenada Y do Vetor
		addi $s1, $s1, 12 # Pulando Vetor para a Coordenada X da Proxima Peca
		
		push($s0)
		push($s1)
		
		push($t6)
		push($t7)
		
		push($s3)# flag para saber se eh dama
		
		jal PrintCirculo # Vai Imprimir a Peca

		pop($s3)
		
		pop($t7)
		pop($t6)
		pop($s1)
		pop($s0)
				
		blt  $s1, 384, Vetor_Loop #Acabou o Vetor?
		
		j FimLoop
		
	Proxima_Peca: # Caso Morta, existe a proxima peca?
		
		blt  $s1, 192, Score_P2 # Se ela eh menor que a primeira metade do vetor, e tah morta
				       # logo, eh a Pontuacao de P2
	
	Retorno_do_Score_P2:
		bge  $s1, 192, Score_P1
	
	Retorno_do_Score_P1:
			
		addi $s1, $s1, 16 # Pula a Peca Inteira
		addi $s0, $s0, 16 # Pula a Peca Inteira	
		
		blt  $s1, 384, Vetor_Loop # Se nao atingiu o tamanho, volta ao inicio
		j FimLoop 
		
	FimLoop:
	
		move $s0, $t6
		jal PrintScoreP1 
		
		move $s0, $t7
		jal PrintScoreP2 
		
		pop($a3)
		pop($a2)
		pop($a1)
		pop($a0)
		pop($ra)
		
		jr $ra
				
	Cor_P1:
		lw $a2, vermelho
		j Retorno_Vetor
				
	Cor_P2:	
		lw $a2, azul			
		j Retorno_Vetor
		
	Score_P1:
		addi $t6, $t6, 1
		j Retorno_do_Score_P1
	Score_P2:											
		addi $t7, $t7, 1
		j Retorno_do_Score_P2	
		
PrintCirculo:
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	push($s3)
	
	addi $a0, $a0, 1
	addi $a1, $a1, 3
	addi $a3, $a1, 1
	jal Vertical

	addi $a0, $a0, 5
	jal Vertical

	subi $a0, $a0, 6
	subi $a1, $a1, 3
	
	addi $a0, $a0, 2
	addi $a1, $a1, 2
	addi $a3, $a1, 3
	jal Vertical
	
	addi $a0, $a0, 3
	jal Vertical

	subi $a0, $a0, 5
	subi $a1, $a1, 2
	
	addi $a0, $a0, 3
	addi $a1, $a1, 1
	addi $a3, $a1, 5
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical
	
	subi $a0, $a0, 4
	subi $a1, $a1, 1

	pop($s3)	
	beq $s3, 1, PrintKing
	
RetornoPrintKing:
	
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
	
	jr $ra
	
PrintKing:
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	push($s3)
	lw $a2, preto

	addi $a0, $a0, 2
	addi $a1, $a1, 3
	addi $a3, $a1, 1
	jal Vertical
	
	addi $a0, $a0, 3
	jal Vertical

	subi $a0, $a0, 5
	subi $a1, $a1, 3
	
	addi $a0, $a0, 3
	addi $a1, $a1, 2
	addi $a3, $a1, 3
	jal Vertical

	addi $a0, $a0, 1
	jal Vertical
	
	subi $a0, $a0, 4
	subi $a1, $a1, 3

	pop($s3)
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)

	j RetornoPrintKing

PrintScoreP1:
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
		
	lw $a2, azul
	beq $s0, $zero, endScoreP1
	
	################# 1 pt ##################
	li $a0, 5
	li $a1, 57
	li $a3, 59
	jal Vertical
			
	li $a0, 6
	li $a1, 57
	li $a3, 59
	jal Vertical

	li $a0, 7
	li $a1, 57
	li $a3, 59
	jal Vertical
					
	beq $s0, 1, endScoreP1
	
	################# 2 pt ##################	
	
	li $a0, 10
	li $a1, 57
	li $a3, 59
	jal Vertical
			
	li $a0, 11
	li $a1, 57
	li $a3, 59
	jal Vertical

	li $a0, 12
	li $a1, 57
	li $a3, 59
	jal Vertical
					
	beq $s0, 2, endScoreP1
	
	################# 3 pt ##################
	
	li $a0, 15
	li $a1, 57
	li $a3, 59
	jal Vertical
			
	li $a0, 16
	li $a1, 57
	li $a3, 59
	jal Vertical

	li $a0, 17
	li $a1, 57
	li $a3, 59
	jal Vertical
					
	beq $s0, 3, endScoreP1
			
	################# 4 pt ##################
	
	li $a0, 20
	li $a1, 57
	li $a3, 59
	jal Vertical
			
	li $a0, 21
	li $a1, 57
	li $a3, 59
	jal Vertical

	li $a0, 22
	li $a1, 57
	li $a3, 59
	jal Vertical
					
	beq $s0, 4, endScoreP1
	
	################# 5 pt ##################
	
	li $a0, 5
	li $a1, 62
	li $a3, 64
	jal Vertical
			
	li $a0, 6
	li $a1, 62
	li $a3, 64
	jal Vertical

	li $a0, 7
	li $a1, 62
	li $a3, 64
	jal Vertical
					
	beq $s0, 5, endScoreP1
	
	################# 6 pt ##################
	
	li $a0, 10
	li $a1, 62
	li $a3, 64
	jal Vertical
			
	li $a0, 11
	li $a1, 62
	li $a3, 64
	jal Vertical

	li $a0, 12
	li $a1, 62
	li $a3, 64
	jal Vertical
					
	beq $s0, 6, endScoreP1
	
	################# 7 pt ##################
	
	li $a0, 15
	li $a1, 62
	li $a3, 64
	jal Vertical
			
	li $a0, 16
	li $a1, 62
	li $a3, 64
	jal Vertical

	li $a0, 17
	li $a1, 62
	li $a3, 64
	jal Vertical
					
	beq $s0, 7, endScoreP1
	
	################# 8 pt ##################
	
	li $a0, 20
	li $a1, 62
	li $a3, 64
	jal Vertical
			
	li $a0, 21
	li $a1, 62
	li $a3, 64
	jal Vertical

	li $a0, 22
	li $a1, 62
	li $a3, 64
	jal Vertical
					
	beq $s0, 8, endScoreP1
	
	################# 9 pt ##################
	
	li $a0, 5
	li $a1, 67
	li $a3, 69
	jal Vertical
			
	li $a0, 6
	li $a1, 67
	li $a3, 69
	jal Vertical

	li $a0, 7
	li $a1, 67
	li $a3, 69
	jal Vertical
					
	beq $s0, 9, endScoreP1
	
	################# 10 pt ##################
	
	li $a0, 10
	li $a1, 67
	li $a3, 69
	jal Vertical
			
	li $a0, 11
	li $a1, 67
	li $a3, 69
	jal Vertical

	li $a0, 12
	li $a1, 67
	li $a3, 69
	jal Vertical
					
	beq $s0, 10, endScoreP1
	
	################# 11 pt ##################
	
	li $a0, 15
	li $a1, 67
	li $a3, 69
	jal Vertical
			
	li $a0, 16
	li $a1, 67
	li $a3, 69
	jal Vertical

	li $a0, 17
	li $a1, 67
	li $a3, 69
	jal Vertical
					
	beq $s0, 11, endScoreP1
	
	################# 12 pt ##################
	
	li $a0, 20
	li $a1, 67
	li $a3, 69
	jal Vertical
			
	li $a0, 21
	li $a1, 67
	li $a3, 69
	jal Vertical

	li $a0, 22
	li $a1, 67
	li $a3, 69
	jal Vertical
					
	beq $s0, 12, endScoreP1

endScoreP1:
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
	
	jr $ra


PrintScoreP2:
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
	lw $a2, vermelho
	beq $s0, $zero, endScoreP2
	
	################# 1 pt ##################
	li $a0, 105
	li $a1, 57
	li $a3, 59
	jal Vertical
			
	li $a0, 106
	li $a1, 57
	li $a3, 59
	jal Vertical

	li $a0, 107
	li $a1, 57
	li $a3, 59
	jal Vertical
					
	beq $s0, 1, endScoreP2
	
	################# 2 pt ##################
	li $a0, 110
	li $a1, 57
	li $a3, 59
	jal Vertical
			
	li $a0, 111
	li $a1, 57
	li $a3, 59
	jal Vertical

	li $a0, 112
	li $a1, 57
	li $a3, 59
	jal Vertical
					
	beq $s0, 2, endScoreP2
	
	################# 3 pt ##################
	
	li $a0, 115
	li $a1, 57
	li $a3, 59
	jal Vertical
			
	li $a0, 116
	li $a1, 57
	li $a3, 59
	jal Vertical

	li $a0, 117
	li $a1, 57
	li $a3, 59
	jal Vertical
					
	beq $s0, 3, endScoreP2
			
	################# 4 pt ##################
	
	li $a0, 120
	li $a1, 57
	li $a3, 59
	jal Vertical
			
	li $a0, 121
	li $a1, 57
	li $a3, 59
	jal Vertical

	li $a0, 122
	li $a1, 57
	li $a3, 59
	jal Vertical
					
	beq $s0, 4, endScoreP2
	
	################# 5 pt ##################
	
	li $a0, 105
	li $a1, 62
	li $a3, 64
	jal Vertical
			
	li $a0, 106
	li $a1, 62
	li $a3, 64
	jal Vertical

	li $a0, 107
	li $a1, 62
	li $a3, 64
	jal Vertical
					
	beq $s0, 5, endScoreP2
	
	################# 6 pt ##################
	
	li $a0, 110
	li $a1, 62
	li $a3, 64
	jal Vertical
			
	li $a0, 111
	li $a1, 62
	li $a3, 64
	jal Vertical

	li $a0, 112
	li $a1, 62
	li $a3, 64
	jal Vertical
					
	beq $s0, 6, endScoreP2
	
	################# 7 pt ##################
	
	li $a0, 115
	li $a1, 62
	li $a3, 64
	jal Vertical
			
	li $a0, 116
	li $a1, 62
	li $a3, 64
	jal Vertical

	li $a0, 117
	li $a1, 62
	li $a3, 64
	jal Vertical
					
	beq $s0, 7, endScoreP2
	
	################# 8 pt ##################
	
	li $a0, 120
	li $a1, 62
	li $a3, 64
	jal Vertical
			
	li $a0, 121
	li $a1, 62
	li $a3, 64
	jal Vertical

	li $a0, 122
	li $a1, 62
	li $a3, 64
	jal Vertical
					
	beq $s0, 8, endScoreP2
	
	################# 9 pt ##################
	
	li $a0, 105
	li $a1, 67
	li $a3, 69
	jal Vertical
			
	li $a0, 106
	li $a1, 67
	li $a3, 69
	jal Vertical

	li $a0, 107
	li $a1, 67
	li $a3, 69
	jal Vertical
					
	beq $s0, 9, endScoreP2
	
	################# 10 pt ##################
	
	li $a0, 110
	li $a1, 67
	li $a3, 69
	jal Vertical
			
	li $a0, 111
	li $a1, 67
	li $a3, 69
	jal Vertical

	li $a0, 112
	li $a1, 67
	li $a3, 69
	jal Vertical
					
	beq $s0, 10, endScoreP2
	
	################# 11 pt ##################
	
	li $a0, 115
	li $a1, 67
	li $a3, 69
	jal Vertical
			
	li $a0, 116
	li $a1, 67
	li $a3, 69
	jal Vertical

	li $a0, 117
	li $a1, 67
	li $a3, 69
	jal Vertical
					
	beq $s0, 11, endScoreP2
	
	################# 12 pt ##################
	
	li $a0, 120
	li $a1, 67
	li $a3, 69
	jal Vertical
			
	li $a0, 121
	li $a1, 67
	li $a3, 69
	jal Vertical

	li $a0, 122
	li $a1, 67
	li $a3, 69
	jal Vertical
					
	beq $s0, 12, endScoreP2
		
endScoreP2:
	
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
	
	jr $ra

# $a0 X inicial 
# $a1 Y inicial 
# $a2 cor
Pixel:		
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)

	sll $t0, $a1, 7   #Multiplicando Y por 64 (tamanho da tela)
	addu $v0, $a0, $t0
	sll $v0, $v0, 2
	addi $v0, $v0, _bmpAddress
	sw $a2, ($v0) # Desenha a cor no local correto
			
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
	jr $ra

# $a0 X inicial
# $a1 Y inicial
# $a2 cor
# $a3 X final
Horizontal:
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
		
		sub $t9, $a3, $a0
		move $t1, $a0

	LoopHorizontal:

		add $a0, $t1, $t9
		jal Pixel
		addi $t9, $t9, -1
		bge $t9, 0, LoopHorizontal
	
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)	
		
		jr $ra

# $a0 X inicial
# $a1 Y inicial
# $a2 cor
# $a3 Y final


Vertical:
	
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
		sub $t9, $a3, $a1
		move $t1, $a1

	VerticalLoop:

		add $a1, $t1, $t9
		jal Pixel
		addi $t9, $t9, -1
		bge $t9, 0, VerticalLoop
	pop($a3)
	pop($a2)
	pop($a1)
	pop($a0)
	pop($ra)
	jr $ra

ClearBoard:
	push($ra)
	push($a0)
	push($a1)
	push($a2)
	push($a3)
	
		lw $t0, preto		#Carrega a Cor
		li $t1, 65536		#65536 Pixels do Display 16384

	StartCLoop:

		subi $t1, $t1, 4
		addi $t2, $t1, _bmpAddress
		sw $t0, 0($t2)
		beqz $t1, EndCLoop
		j StartCLoop

	EndCLoop:
	
		pop($a3)
		pop($a2)
		pop($a1)
		pop($a0)
		pop($ra)
		jr $ra
end:
