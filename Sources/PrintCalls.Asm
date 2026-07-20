;SAVE"PrintCalls.Asm"
*===============================*
* Version 2.0        (07/15/86) *
*===============================*
ChooserBits      EQU  $946
*--------------------------------
PrOpenDoc
         MOVE.L  (SP),-(SP)
         MOVE.L  #$00040C00,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrCloseDoc
         MOVE.L  (SP),-(SP)
         MOVE.L  #$08000484,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrOpenPage
         MOVE.L  (SP),-(SP)
         MOVE.L  #$10000808,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrClosePage
         MOVE.L  (SP),-(SP)
         MOVE.L  #$1800040C,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrintDefault
         MOVE.L  (SP),-(SP)
         MOVE.L  #$24000480,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrStlDialog
         MOVE.L  (SP),-(SP)
         MOVE.L  #$2C020484,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrJobDialog
         MOVE.L  (SP),-(SP)
         MOVE.L  #$34020488,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrStlInit
         MOVE.L  (SP),-(SP)
         MOVE.L  #$3C04040C,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrJobInit
         MOVE.L  (SP),-(SP)
         MOVE.L  #$44040410,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrDlgMain
         MOVE.L  (SP),-(SP)
         MOVE.L  #$4C020894,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrValidate
         MOVE.L  (SP),-(SP)
         MOVE.L  #$54020498,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrJobMerge
         MOVE.L  (SP),-(SP)
         MOVE.L  #$5C00089C,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrPicFile
         MOVE.L  (SP),-(SP)
         MOVE.L  #$65001480,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrHack
         MOVE.L  (SP),-(SP)
         MOVE.L  #$6F040C80,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrDrvrOpen
         MOVE.L  (SP),-(SP)
         MOVE.L  #$80000000,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrDrvrClose
         MOVE.L  (SP),-(SP)
         MOVE.L  #$88000000,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrDrvrDCE
         MOVE.L  (SP),-(SP)
         MOVE.L  #$90040000,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrDrvrVers
         MOVE.L  (SP),-(SP)
         MOVE.L  #$98020000,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrCtlCall
         MOVE.L  (SP),-(SP)
         MOVE.L  #$A0000E00,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrPurge
         MOVE.L  (SP),-(SP)
         MOVE.L  #$A8000000,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrNoPurge
         MOVE.L  (SP),-(SP)
         MOVE.L  #$B0000000,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrError
         MOVE.L  (SP),-(SP)
         MOVE.L  #$B8020000,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrSetError
         MOVE.L  (SP),-(SP)
         MOVE.L  #$C0000200,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrOpen
         MOVE.L  (SP),-(SP)
         MOVE.L  #$C8000000,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrClose
         MOVE.L  (SP),-(SP)
         MOVE.L  #$D0000000,4(A7)
         JMP     PrGlue(PC)
*--------------------------------
PrGlue   LINK    A6,#0
         MOVEM.L A3-A4,-(SP)
         MOVEQ   #0,D1
         MOVE.B  8(A6),D1
         LSR.B   #3,D1
         BEQ.S   .0
         TST.B   8(A6)
         BMI.S   .4
         MOVEQ   #7,D2
         AND.B   8(A6),D2
         BNE.S   .1
         MOVEQ   #3,D2
         AND.B   ChooserBits,D2
         BRA.S   .1
.0       MOVE.L  20(A6),A0
         MOVE.L  (A0),A0
         MOVEQ   #3,D2
         AND.B   68(A0),D2
         AND.B   #$FC,ChooserBits
         OR.B    D2,ChooserBits
.1       CLR.L   -(SP)
         MOVE.L  #$50444546,-(SP)        ;"PDEF"
         MOVE    D2,-(SP)
         _GetResource
         MOVE.L  (SP)+,D0
         BNE.S   .2
         MOVE    #-192,PrintErr
         JMP     .7(PC)
.2       MOVE.L  D0,A4
         MOVE.L  A4,A0
         _HLock
         LEA     12(A6),A0
         MOVEQ   #0,D0
         MOVE.B  9(A6),D0
         ADD.B   10(A6),D0
         SUB     D0,A7
         MOVE.L  A7,A1
         _BlockMove
         MOVE.B  11(A6),D0
         AND.B   #$7F,D0
         MOVE.L  (A4),A0
         JSR     0(A0,D0)
         MOVE.B  11(A6),D0
         BPL.S   .3
         MOVE.L  A4,A0
         _HUnLock
.3       JMP     .25(PC)
.4       SUB     #50,A7
         LEA     .29(PC),A0
         MOVE.L  A0,18(A7)
         MOVE    #-3,24(A7)
         CLR.B   27(A7)
         MOVE.L  A7,A0
         MOVEQ   #0,D0
         BCLR    #4,D1
         ADD     D1,D1
         MOVE    .5(PC,D1),D1
         JMP     .5(PC,D1)
.5       DATA    /.14-.5
         DATA    /.15-.5
         DATA    /.16-.5
         DATA    /.17-.5
         DATA    /.18-.5
         DATA    /.19-.5
         DATA    /.20-.5
         DATA    /.22-.5
         DATA    /.23-.5
         DATA    /.8-.5
         DATA    /.9-.5
         DATA    /.6-.5
         DATA    /.6-.5
         DATA    /.6-.5
         DATA    /.6-.5
         DATA    /.6-.5
.6       MOVE    #-50,PrintErr
.7       MOVEQ   #0,D1
         MOVE.B  10(A6),D1
         JMP     .26(PC)
.8       MOVE.L  #$80000000,-(SP)
         JSR     PrGlue(PC)
         BNE.S   .13
         MOVEQ   #0,D1
         BRA.S   .10
.9       MOVE.L  #$88000000,-(SP)
         JSR     PrGlue(PC)
         MOVEQ   #1,D1
.10      SUBQ    #4,A7
         MOVE    #$E000,-(SP)
         _GetString
         MOVE.L  (SP)+,D0
         BNE.S   .11
         MOVE    #-192,D0
         BRA.S   .13
.11      MOVE.L  D0,A1
         JSR     .27(PC)
         SWAP    D1
         MOVE    D0,D1
         SUBQ    #2,A7
         MOVE.L  A1,A0
         _HLock
         MOVE.L  (A1),-(SP)
         _OpenResFile
         MOVE.L  A1,A0
         _HUnLock
         MOVE    D1,D0
         SWAP    D1
         JSR     .28(PC)
         MOVE    (SP)+,D0
         TST     ResErr
         BNE.S   .12
         TST     D1
         BEQ.S   .12
         MOVE    D0,-(SP)
         _CloseResFile
.12      MOVE    ResErr,D0
.13      JMP     .24(PC)
.14      _Open
         BRA.S   .24
.15      _Close
         BRA.S   .24
.16      BSR.S   .21
         MOVE.L  A0,12(A6)
         BRA.S   .24
.17      BSR.S   .21
         MOVE.L  (A0),A0
         MOVE.B  7(A0),D0
         EXT     D0
         MOVE    D0,12(A6)
         BRA.S   .24
.18      MOVE.L  12(A6),36(A0)
         MOVE.L  16(A6),32(A0)
         MOVE.L  20(A6),28(A0)
         MOVE    24(A6),26(A0)
         _Control
         BRA.S   .24
.19      BSR.S   .21
         MOVE.L  (A0),A0
         BTST    #6,4(A0)
         BEQ.S   .24
         MOVE.L  0(A0),A0
         _HPurge
         BRA.S   .24
.20      BSR.S   .21
         MOVE.L  (A0),A0
         BTST    #6,4(A0)
         BEQ.S   .24
         MOVE.L  0(A0),A0
         _HNoPurge
         BRA.S   .24
.21      MOVE    #1,26(A0)
         _Status
         MOVE.L  28(A0),A0
         RTS
.22      ADD     #48,A7
         MOVE    PrintErr,(SP)
         BRA.S   .25
.23      MOVE    12(A6),PrintErr
.24      ADD     #50,A7
         MOVE    D0,PrintErr
.25      MOVEQ   #0,D1
         MOVE.B  10(A6),D1
         MOVEQ   #0,D0
         MOVE.B  9(A6),D0
         BEQ.S   .26
         MOVE    D0,D2
         MOVE.L  A7,A0
         LEA     12(A6,D1),A1
         _BlockMove
         ADD     D2,A7
.26      MOVEM.L (SP)+,A3-A4
         UNLK    A6
         MOVE.L  (SP)+,A0
         ADD.L   D1,A7
         ADDQ    #4,A7
         JMP     (A0)
.27      MOVEQ   #0,D0
.28      SUB     #64,A7
         MOVE.L  A7,A0
         MOVE    D0,22(A0)
         CLR.L   18(A0)
         _SetVol
         _GetVol
         MOVE    22(A0),D0
         ADD     #64,A7
         RTS
.29      STR     ".Print"
         ASC     " "
*--------------------------------
         END
