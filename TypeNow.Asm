;SAVE"TypeNow.Asm"
*--------------------------------
; TypeNow version 1.0  (12/12/85)
*--------------------------------
         LIST    OFF
*--------------------------------
         INCLUDE "Library.Asm"
*--------------------------------
resPurgeable     EQU  32
;
evtNum           EQU  0
evtMessage       EQU  2
evtMouse         EQU  $A
evtMeta          EQU  $E
;
dCtlStorage      EQU  $14
dCtlRefNum       EQU  $18
dCtlWindow       EQU  $1E
;
JIODone          EQU  $8FC
;
csCode           EQU  $1A
csParam          EQU  $1C
;
rDocProc         EQU  16
;
GrafGlobals      EQU  0
thePort          EQU  $0
gray             EQU  $FFFFFFE8
ltGray           EQU  $FFFFFFE0
;
v                EQU  0
h                EQU  2
;
pnLoc            EQU  $30
pnMode           EQU  $38
pnPat            EQU  $3A
txFont           EQU  $44
txFace           EQU  $46
txMode           EQU  $48
txSize           EQU  $4A
windowKind       EQU  $6C
;
sysFont          EQU  0
geneva           EQU  3
monaco           EQU  4
;
srcCopy          EQU  0
srcOr            EQU  1
srcXor           EQU  2
patOr            EQU  9
patBic           EQU  11
;
iPrIOCtl         EQU  5
iPrDevCtl        EQU  7
lPrReset         EQU  $00010000
lPrPageEnd       EQU  $00020000
lPrLineFeed      EQU  $00030000
lPrLFSixth       EQU  $0003FFFF
lPrLFEighth      EQU  $0003FFFE
;
fsRdPerm         EQU  1
fsWrPerm         EQU  2
;
Good             EQU  0
Copy             EQU  1
fType            EQU  2
vRefNum          EQU  6
version          EQU  8
fName            EQU  10
RefNum           EQU  74         ; Not Standard
;
SFPutFile        EQU  1
SFGetFile        EQU  2
*--------------------------------
* RAM driver's private storage
*--------------------------------
         ORG     0
;
Ruler    DEFS    336
OldLine  DEFS    336
NewLine  DEFS    336
Keys     DEFS    382
ParaBlk  DEFS    80
SFR      DEFS    74+2
Where    DEFS    L
ProgHdl  DEFS    L
ProgPtr  DEFS    L
Curs     DEFS    W
CRLF     DEFS    B    ;
Feed     DEFS    B    ;
LtMrg    DEFS    W    ;Keep this order
RtMrg    DEFS    W    ;
Font     DEFS    W    ;
Header   DEFS    B    ;
Size     DEFS    B    ;
RecdFl   DEFS    B
PlayFl   DEFS    B
;
PrivSize EQU     *
         DEFS    *&1
*--------------------------------
         TFILE   "Buffer.Bin"
*--------------------------------
         RFILE   "TypeNow",DFIL,DMOV
*================================
         RSRC    DRVR,28,resPurgeable,"@TypeNow"
*--------------------------------
Desk     DATA    /$1400          ;drvrFlags
         DATA    /0              ;drvrDelay
         DATA    /$006A          ;drvrEMask
         DATA    /0              ;drvrMenu
         DATA    /DskOpen-Desk   ;drvrOpen
         DATA    /DskDone-Desk   ;drvrPrime
         DATA    /DskCntl-Desk   ;drvrCtl
         DATA    /DskDone-Desk   ;drvrStatus
         DATA    /DskClos-Desk   ;drvrClose
DskTitle STR     "TypeNow"
         ADJST
*--------------------------------
DskOpen  MOVEM.L A2-A4,-(SP)
         MOVE.L  A1,A4
         TST.L   DCtlWindow(A4)
         BNE.S   GotAWind
         MOVE.L  GrafGlobals(A5),A0
         MOVE.L  thePort(A0),-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     wBounds(PC)
         PEA     DskTitle(PC)
         CLR.B   -(SP)
         MOVE    #rDocProc,-(SP)
         MOVE.L  #-1,-(SP)
         MOVE.B  #1,-(SP)
         CLR.L   -(SP)
         TBX     NewWindow
         MOVE.L  (SP)+,A0
         MOVE.L  A0,DCtlWindow(A4)
         MOVE.W  dCtlRefNum(A4),WindowKind(A0)
         MOVE.L  #PrivSize,D0
         OST     NewHandle
         MOVE.L  A0,dCtlStorage(A4)
         BSET    #7,(A0)
         MOVE.L  (A0),A3
         CLR.L   D0
         OST     NewHandle
         MOVE.L  A0,ProgHdl(A3)
         BSR     InitPrt
         BSR     InitText
         MOVE.L  dCtlStorage(A4),A0
         BCLR    #7,(A0)
StdRet   MOVE.L  GrafGlobals(A5),A0
         MOVE.L  (SP)+,thePort(A0)
GotAWind MOVE.L  A4,A1
         MOVEM.L (SP)+,A2-A4
DskDone  MOVEQ   #0,D0
         RTS
DskClos  MOVEM.L A2-A4,-(SP)
         MOVE.L  A1,A4
         MOVE.L  GrafGlobals(A5),A0
         MOVE.L  thePort(A0),-(SP)
         BSR     RstPrt
         MOVE.L  dCtlStorage(A4),A3
         MOVE.L  (A3),A3
         MOVE.L  ProgHdl(A3),A0
         OST     DisposHandle
         MOVE.L  dCtlStorage(A4),A0
         CLR.L   dCtlStorage(A4)
         OST     DisposHandle
         MOVE.L  dCtlWindow(A4),-(SP)
         CLR.L   dCtlWindow(A4)
         TBX     DisposWindow
         BRA.S   StdRet
*--------------------------------
DskCntl  MOVEM.L A2-A4,-(SP)
         MOVE.L  A1,A4
         MOVE.L  dCtlStorage(A4),A3
         BSET    #7,(A3)
         MOVE.L  (A3),A3
         MOVE    csCode(A0),D0
         CMP     #64,D0
         BEQ.S   CtlEvent
         CMP     #-1,D0
         BNE.S   CtlDone
         BSR     RstPrt
CtlDone  MOVE.L  dCtlStorage(A4),A0
         BCLR    #7,(A0)
         MOVE.L  A4,A1
         MOVEM.L (SP)+,A2-A4
         MOVEQ   #0,D0
         MOVE.L  JIODone,-(SP)
         RTS
*--------------------------------
CtlEvent MOVE.L  csParam(A0),A0
         MOVE    evtNum(A0),D0
         CMP     #1,D0
         BEQ.S   MseDwn
         CMP     #3,D0
         BEQ.S   KeyDwn
         CMP     #5,D0
         BEQ.S   KeyDwn
         CMP     #6,D0
         BNE.S   CtlDone
Update   MOVE.L  dCtlWindow(A4),-(SP)
         TBX     BeginUpdate
         MOVE.L  GrafGlobals(A5),A0
         MOVE.L  dCtlWindow(A4),thePort(A0)
         BSR     DLine
         BSR     DispText
         BSR     DrawKeys
         MOVE.L  dCtlWindow(A4),-(SP)
         TBX     EndUpdate
         BRA.S   CtlDone
KeyDwn   MOVE    evtMeta(A0),D0
         BTST    #8,D0
         BNE.S   CtlDone
         MOVE.L  GrafGlobals(A5),A1
         MOVE.L  dCtlWindow(A4),thePort(A1)
         MOVE.L  evtMessage(A0),D0
         BSR     Input
         BSR     DispText
         BRA.S   CtlDone
MseDwn   MOVE.L  evtMouse(A0),Where(A3)
         MOVE.L  GrafGlobals(A5),A0
         MOVE.L  dCtlWindow(A4),thePort(A0)
         PEA     Where(A3)
         TBX     GlobalToLocal
         CLR.B   -(SP)
         MOVE.L  Where(A3),-(SP)
         PEA     Brect(PC)
         TBX     PtInRect
         TST.B   (SP)+
         BEQ     CtlDone
         LEA     Keys(A3),A2
         MOVEQ   #0,D3
.0       CMP.B   #2,(A2)
         BEQ.S   .1
         CLR.B   -(SP)
         MOVE.L  Where(A3),-(SP)
         PEA     2(A2)
         TBX     PtInRect
         TST.B   (SP)+
         BNE.S   .2
.1       CLR     D0
         MOVE.B  10(A2),D0
         OR      #1,D0
         LEA     11(A2,D0),A2
         ADDQ    #1,D3
         CMP     #19,D3
         BLO.S   .0
         BRA     CtlDone
.2       CMP     #8,D3
         BLO     StFont
         BEQ     StHead
         CMP     #11,D3
         BLO     StLine
         BEQ     FormFd
         CMP     #13,D3
         BLO     LineFd
         BEQ     LeftMr
         CMP     #15,D3
         BLO     RigtMr
         BEQ     Load
         CMP     #17,D3
         BLO     Save
         BEQ     PlayBk
         BRA     Record
*--------------------------------
FindRec  LEA     Keys(A3),A2
         CLR     D0
.0       TST     D1
         BEQ.S   .1
         MOVE.B  10(A2),D0
         OR      #1,D0
         LEA     11(A2,D0),A2
         SUBQ    #1,D1
         BRA.S   .0
.1       RTS
*--------------------------------
StFont   MOVE    Font(A3),D1
         MOVE    D3,Font(A3)
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
         MOVE    Font(A3),D1
         BSR     FindRec
         MOVE.B  #1,(A2)
         BSR     DrawKey
         BRA     CtlDone
StHead   EOR.B   #1,Header(A3)
         MOVE.B  Header(A3),(A2)
         BSR     DrawKey
         BRA     CtlDone
StLine   SUBQ    #9,D3
         MOVE.B  D3,Feed(A3)
         MOVEQ   #9,D1
         BSR     FindRec
         MOVE.B  Feed(A3),(A2)
         EOR.B   #1,(A2)
         BSR     DrawKey
         MOVEQ   #10,D1
         BSR     FindRec
         MOVE.B  Feed(A3),(A2)
         BSR     DrawKey
         BRA     CtlDone
FormFd   MOVE.B  #1,(A2)
         BSR     DrawKey
         BSR     DoFF
         TST.B   RecdFl(A3)
         BEQ.S   .0
         LEA     .1(PC),A0
         MOVE.L  ProgHdl(A3),A1
         MOVEQ   #2,D0
         OST     PtrAndHand
.0       MOVE.L  #4,A0
         OST     Delay
         MOVE.B  #0,(A2)
         BSR     DrawKey
         BRA     CtlDone
.1       HEX     8000
LineFd   MOVE.B  #1,(A2)
         BSR     DrawKey
         BSR     DoLF
         TST.B   RecdFl(A3)
         BEQ.S   .0
         LEA     .1(PC),A0
         MOVE.L  ProgHdl(A3),A1
         MOVEQ   #2,D0
         OST     PtrAndHand
.0       MOVE.L  #4,A0
         OST     Delay
         MOVE.B  #0,(A2)
         BSR     DrawKey
         BRA     CtlDone
.1       HEX     8100
LeftMr   MOVE.B  #1,(A2)
         BSR     DrawKey
         MOVE    Curs(A3),D1
         CMP     RtMrg(A3),D1
         BHS.S   MrCom
         MOVE    D1,LtMrg(A3)
         BRA.S   MrCom
RigtMr   MOVE.B  #1,(A2)
         BSR     DrawKey
         MOVE    Curs(A3),D1
         CMP     LtMrg(A3),D1
         BLS.S   MrCom
         MOVE    D1,RtMrg(A3)
MrCom    MOVE.L  A2,-(SP)
         BSR     GenRuler
         BSR     DispText
         MOVE.L  (SP)+,A2
         MOVE.B  #0,(A2)
         BSR     DrawKey
         BRA     CtlDone
PlayBk   TST.B   PlayFl(A3)
         BNE.S   .1
         MOVE.B  #1,PlayFl(A3)
         CLR.L   ProgPtr(A3)
         MOVE.B  #1,(A2)
         BSR     DrawKey
         LEA     NewLine(A3),A0
         MOVE.L  #$20202020,D0
         MOVEQ   #256/4-1,D1
.0       MOVE.L  D0,(A0)+
         DBRA    D1,.0
         BSR     GetRec
         LEA     NewLine(A3),A0
         MOVE    Curs(A3),D1
         MOVE.B  #'_,40(A0,D1)
         BSR     DispText
         BRA     CtlDone
.1       MOVE.B  #0,PlayFl(A3)
         MOVE.B  #0,(A2)
         BSR     DrawKey
         BRA     CtlDone
Record   TST.B   RecdFl(A3)
         BNE.S   .0
         MOVE.B  #1,RecdFl(A3)
         MOVE.B  #0,PlayFl(A3)
         MOVE.B  #1,(A2)
         BSR     DrawKey
         MOVEQ   #16,D1
         BSR     FindRec
         MOVE.B  #2,(A2)
         BSR     DrawKey
         MOVEQ   #17,D1
         BSR     FindRec
         MOVE.B  #2,(A2)
         BSR     DrawKey
         MOVE.L  ProgHdl(A3),A0
         CLR.L   D0
         OST     SetHandleSize
         BRA     CtlDone
.0       MOVE.B  #0,RecdFl(A3)
         MOVE.B  #0,(A2)
         BSR     DrawKey
         MOVE.L  ProgHdl(A3),A0
         TBX     GetHandleSize
         TST.L   D0
         BEQ.S   .1
         MOVEQ   #16,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
         MOVEQ   #17,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
.1       BRA     CtlDone
Load     MOVE.B  #0,RecdFl(A3)
         MOVE.B  #0,PlayFl(A3)
         MOVE.B  #1,(A2)
         BSR     DrawKey
         MOVEQ   #16,D1
         BSR     FindRec
         MOVE.B  #2,(A2)
         BSR     DrawKey
         MOVEQ   #17,D1
         BSR     FindRec
         MOVE.B  #2,(A2)
         BSR     DrawKey
         MOVEQ   #18,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
         MOVE.L  ProgHdl(A3),A0
         CLR.L   D0
         OST     SetHandleSize
         MOVE    #70,-(SP)
         MOVE    #70,-(SP)
         PEA     NullStr(PC)
         CLR.L   -(SP)
         MOVE    #1,-(SP)
         PEA     TypeList(PC)
         CLR.L   -(SP)
         PEA     SFR(A3)
         MOVE    #SFGetFile,-(SP)
         TBX     Pack3
         TST.B   SFR+Good(A3)
         BEQ     .0
         BSR     GetInfo
         BNE     Err
         MOVE.L  54(A0),D0
         MOVE.L  ProgHdl(A3),A0
         OST     SetHandleSize
         MOVEQ   #fsRdPerm,D0
         BSR     OpenData
         BNE     LErr0
         MOVE.L  ProgHdl(A3),A0
         BSET    #7,(A0)
         MOVE.L  (A0),-(SP)
         OST     GetHandleSize
         LEA     ParaBlk(A3),A0
         CLR.L   12(A0)
         MOVE    SFR+RefNum(A3),24(A0)
         MOVE.L  (SP)+,32(A0)
         MOVE.L  D0,36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         OST     Read
         MOVE    16(A0),D7
         MOVE.L  ProgHdl(A3),A0
         BCLR    #7,(A0)
         TST     D7
         BNE     LErr0
         BSR     CloseF
         BNE     LErr0
         MOVEQ   #16,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
         MOVEQ   #17,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
.0       MOVEQ   #15,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
         BRA     CtlDone
Save     MOVE.B  #1,(A2)
         BSR     DrawKey
         MOVE    #100,-(SP)
         MOVE    #70,-(SP)
         PEA     Prompt(PC)
         PEA     NullStr(PC)
         CLR.L   -(SP)
         PEA     SFR(A3)
         MOVE    #SFPutFile,-(SP)
         TBX     Pack3
         TST.B   SFR+Good(A3)
         BEQ     .0
         BSR     DeleteF
         BNE     Err
         BSR     CreateF
         BNE     SErr0
         BSR     GetInfo
         BNE     SErr0
         MOVE.L  #$464F524D,32(A0)       ;"FORM"
         MOVE.L  #$3F3F3F3F,36(A0)       ;"????"
         OST     SetFileInfo
         MOVE    16(A0),D7
         BNE     SErr0
         MOVEQ   #fsWrPerm,D0
         BSR     OpenData
         BNE     SErr1
         MOVE.L  ProgHdl(A3),A0
         BSET    #7,(A0)
         MOVE.L  (A0),-(SP)
         OST     GetHandleSize
         LEA     ParaBlk(A3),A0
         CLR.L   12(A0)
         MOVE    SFR+RefNum(A3),24(A0)
         MOVE.L  (SP)+,32(A0)
         MOVE.L  D0,36(A0)
         CLR     44(A0)
         CLR.L   46(A0)
         OST     Write
         MOVE    16(A0),D7
         MOVE.L  ProgHdl(A3),A0
         BCLR    #7,(A0)
         TST     D7
         BNE     SErr1
         BSR     CloseF
         BNE     SErr1
.0       MOVEQ   #16,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
         BRA     CtlDone
TypeList ASC     "FORM"
NullStr  STR     ""
Prompt   STR     "Save document as:"
         ADJST
*--------------------------------
Input    CMP.B   #128,D0
         BHS.S   .1
         CMP.B   #32,D0
         BLO.S   .2
         MOVE    Curs(A3),D1
         CMP     #256,D1
         BHS.S   .1
         LEA     NewLine(A3),A0
         MOVE.B  D0,40(A0,D1)
         CMP     RtMrg(A3),D1
         BNE.S   .0
         MOVE    #4,-(SP)
         OST     SysBeep
.0       ADDQ    #1,Curs(A3)
.1       LEA     NewLine(A3),A0
         MOVE    Curs(A3),D1
         MOVE.B  #'_,40(A0,D1)
         RTS
.2       CMP.B   #$08,D0         ;Backspace
         BNE.S   .3
         MOVE    Curs(A3),D1
         BEQ.S   .1
         LEA     NewLine(A3),A0
         MOVE.B  #' ,40(A0,D1)
         CMP     LtMrg(A3),D1
         BNE.S   .21
         MOVE    #4,-(SP)
         OST     SysBeep
.21      SUBQ    #1,Curs(A3)
         BRA.S   .1
.3       CMP.B   #$09,D0         ;Tab
         BNE.S   .6
.4       MOVE    Curs(A3),D1
         CMP     #256,D1
         BHS.S   .1
         LEA     NewLine(A3),A0
         MOVE.B  #' ,40(A0,D1)
         CMP     RtMrg(A3),D1
         BNE.S   .5
         MOVE    #4,-(SP)
         OST     SysBeep
.5       ADDQ    #1,Curs(A3)
         MOVE    Curs(A3),D1
         AND     #$0007,D1
         BNE.S   .4
         BRA.S   .1
.6       CMP.B   #$03,D0         ;Enter
         BNE.S   .7
         TST.B   PlayFl(A3)
         BNE.S   .8
         MOVE.B  #0,CRLF(A3)
         BRA.S   .8
.7       CMP.B   #$0D,D0         ;Return
         BNE     .1
         TST.B   PlayFl(A3)
         BNE.S   .8
         MOVE.B  #1,CRLF(A3)
.8       LEA     NewLine(A3),A0
         MOVE    Curs(A3),D1
         MOVE.B  #' ,40(A0,D1)
         BSR     Print
         TST.B   RecdFl(A3)
         BEQ.S   .14
.9       MOVE    LtMrg(A3),D6
         MOVE    Curs(A3),D7
         CMP     D7,D6
         BLS.S   .10
         MOVE    D7,D6
.10      SUB     D6,D7
         TST.B   D7
         BEQ.S   .13
         LEA     NewLine(A3),A0
         LEA     40(A0,D6),A0
         MOVE.B  D7,D0
.11      TST.B   D0
         BEQ.S   .12
         CMP.B   #' ,(A0)+
         BNE.S   .13
         SUBQ.B  #1,D0
         BRA.S   .11
.12      CLR.B   D7
.13      MOVE.B  D7,Size(A3)
         LEA     CRLF(A3),A0
         MOVE.L  ProgHdl(A3),A1
         MOVE.L  #10,D0
         OST     PtrAndHand
         TST.B   D7
         BEQ.S   .14
         LEA     NewLine(A3),A0
         LEA     40(A0,D6),A0
         MOVE.L  ProgHdl(A3),A1
         CLR.L   D0
         MOVE.B  D7,D0
         ADDQ    #1,D0
         AND     #$FFFE,D0
         OST     PtrAndHand
.14      LEA     OldLine+40(A3),A0
         LEA     NewLine+40(A3),A1
         MOVE.L  #$20202020,D0
         MOVEQ   #256/4-1,D1
.15      MOVE.L  (A1),(A0)+
         MOVE.L  D0,(A1)+
         DBRA    D1,.15
         MOVE    LtMrg(A3),Curs(A3)
         BSR     GetRec
         BRA     .1
*--------------------------------
GetRec   TST.B   PlayFl(A3)
         BEQ.S   .1
.0       MOVE.L  ProgHdl(A3),A0
         OST     GetHandleSize
         CMP.L   ProgPtr(A3),D0
         BHI.S   .2
         CLR.B   PlayFl(A3)
         MOVEQ   #17,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
.1       RTS
.2       MOVE.L  ProgHdl(A3),A0
         MOVE.L  (A0),A0
         ADD.L   ProgPtr(A3),A0
         MOVE.B  0(A0),D0
         CMP.B   #$80,D0
         BNE.S   .3
         BSR     DoFF
         ADDQ.L  #2,ProgPtr(A3)
         BRA.S   .0
.3       CMP.B   #$81,D0
         BNE.S   .4
         BSR     DoLF
         ADDQ.L  #2,ProgPtr(A3)
         BRA.S   .0
.4       MOVE    Font(A3),-(SP)
         MOVE.L  0(A0),CRLF(A3)
         MOVE.L  4(A0),RtMrg(A3)
         MOVE    8(A0),Header(A3)
         CLR     D0
         LEA     10(A0),A1
         LEA     NewLine(A3),A2
         MOVE    LtMrg(A3),D1
         MOVE.B  Size(A3),D0
         BEQ.S   .6
.5       MOVE.B  (A1)+,40(A2,D1)
         ADDQ    #1,D1
         CMP     #256,D1
         BEQ.S   .6
         SUBQ    #1,D0
         BNE.S   .5
.6       MOVE    D1,Curs(A3)
         CLR.L   D0
         MOVE.B  Size(A3),D0
         ADD     #11,D0
         AND     #$FFFE,D0
         ADD.L   D0,ProgPtr(A3)
         BSR     GenRuler
         MOVE    (SP)+,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
         MOVE    Font(A3),D1
         BSR     FindRec
         MOVE.B  #1,(A2)
         BSR     DrawKey
         MOVEQ   #8,D1
         BSR     FindRec
         MOVE.B  Header(A3),(A2)
         BSR     DrawKey
         MOVEQ   #9,D1
         BSR     FindRec
         MOVE.B  Feed(A3),(A2)
         EOR.B   #1,(A2)
         BSR     DrawKey
         MOVEQ   #10,D1
         BSR     FindRec
         MOVE.B  Feed(A3),(A2)
         BSR     DrawKey
         RTS
DoFF     MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrPageEnd,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         RTS
DoLF     MOVE    #iPrDevCtl,-(SP)
         TST.B   Feed(A3)
         BNE.S   .0
         MOVE.L  #lPrLFSixth,-(SP)
         BRA.S   .1
.0       MOVE.L  #lPrLFEighth,-(SP)
.1       CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         RTS
*--------------------------------
Print    MOVE    #iPrIOCtl,-(SP)
         PEA     .8(PC)
         MOVE.L  #7,-(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         MOVE    LtMrg(A3),D6
         MOVE    Curs(A3),D7
         CMP     D7,D6
         BLS.S   .0
         MOVE    D7,D6
.0       SUB     D6,D7
         TST     D6
         BEQ.S   .1
         MOVE    #iPrIOCtl,-(SP)
         PEA     NewLine+40(A3)
         MOVE    D6,-(SP)
         CLR     -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
.1       TST     D7
         BEQ.S   .3
         CLR.L   -(SP)
         MOVE.L  A7,A0
         MOVE.B  #$1B,(A0)
         MOVE    Font(A3),D0
         MOVE.B  .7(PC,D0),1(A0)
         MOVEQ   #2,D0
         TST.B   Header(A3)
         BEQ.S   .2
         MOVE.B  #$0E,2(A0)
         ADDQ.L  #1,D0
.2       MOVE    #iPrIOCtl,-(SP)
         MOVE.L  A0,-(SP)
         MOVE.L  D0,-(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         TST.L   (SP)+
         MOVE    #iPrIOCtl,-(SP)
         LEA     NewLine(A3),A0
         PEA     40(A0,D6)
         MOVE    D7,-(SP)
         CLR     -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
.3       MOVE    #iPrDevCtl,-(SP)
         TST.B   CRLF(A3)
         BNE.S   .4
         MOVE.L  #lPrLineFeed,-(SP)
         BRA.S   .6
.4       TST.B   Feed(A3)
         BNE.S   .5
         MOVE.L  #lPrLFSixth,-(SP)
         BRA.S   .6
.5       MOVE.L  #lPrLFEighth,-(SP)
.6       CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         RTS
.7       HEX     6E4E457050657151
.8       HEX     1B4400011B650F00
*--------------------------------
InitText CLR.B   RecdFl(A3)
         CLR.B   PlayFl(A3)
         MOVE    #8,LtMrg(A3)
         MOVE    #72,RtMrg(A3)
         MOVE.B  #0,Feed(A3)
         MOVE    #5,Font(A3)
         MOVE.B  #0,Header(A3)
         MOVE    LtMrg(A3),Curs(A3)
         LEA     Ruler(A3),A0
         LEA     OldLine(A3),A1
         LEA     NewLine(A3),A2
         MOVE.L  #$20202020,D0
         MOVEQ   #336/4-1,D1
.0       MOVE.L  D0,(A0)+
         MOVE.L  D0,(A1)+
         MOVE.L  D0,(A2)+
         DBRA    D1,.0
         BSR     GenRuler
         LEA     NewLine(A3),A0
         MOVE    Curs(A3),D0
         MOVE.B  #'_,40(A0,D0)
         LEA     MKeys(PC),A0
         LEA     Keys(A3),A1
         MOVE    #MKLen/2-1,D0
.1       MOVE    (A0)+,(A1)+
         DBRA    D0,.1
         RTS
*--------------------------------
GenRuler LEA     Ruler+40(A3),A0
         MOVE.L  #$2B2D2D2D,D0
         MOVE.L  #$2D2D2D2D,D1
         MOVEQ   #256/(2*4)-1,D2
.0       MOVE.L  D0,(A0)+
         MOVE.L  D1,(A0)+
         DBRA    D2,.0
         MOVE.B  #' ,(A0)
         LEA     Ruler+40(A3),A0
         MOVEQ   #'0,D0
         MOVE    #26-1,D1
.1       MOVE.B  D0,(A0)
         CMP.B   #'9,D0
         BNE.S   .2
         SUB.B   #10,D0
.2       ADDQ.B  #1,D0
         LEA     10(A0),A0
         DBRA    D1,.1
         LEA     Ruler(A3),A0
         MOVE    LtMrg(A3),D0
         MOVE.B  #'•,40(A0,D0)
         MOVE    RtMrg(A3),D0
         MOVE.B  #'•,40(A0,D0)
         RTS
*--------------------------------
DispText MOVE.L  dCtlWindow(A4),A2
         MOVE    #monaco,txFont(A2)
         MOVE    #9,txSize(A2)
         MOVE    #srcCopy,txMode(A2)
         MOVE.L  GrafGlobals(A5),A0
         MOVE.L  A2,thePort(A0)
         MOVE    #1,PnLoc+h(A2)
         MOVE    #10,PnLoc+v(A2)
         PEA     Ruler(A3)
         MOVE    Curs(A3),-(SP)
         MOVE    #80,-(SP)
         TBX     DrawText
         MOVE    #1,PnLoc+h(A2)
         MOVE    #21,PnLoc+v(A2)
         PEA     OldLine(A3)
         MOVE    Curs(A3),-(SP)
         MOVE    #80,-(SP)
         TBX     DrawText
         MOVE    #1,PnLoc+h(A2)
         MOVE    #32,PnLoc+v(A2)
         PEA     NewLine(A3)
         MOVE    Curs(A3),-(SP)
         MOVE    #80,-(SP)
         TBX     DrawText
         RTS
DLine    TBX     PenNormal
         PEA     .0(PC)
         TBX     PaintRect
         PEA     .1(PC)
         TBX     PaintRect
         MOVE.L  dCtlWindow(A4),A2
         MOVE    #sysFont,txFont(A2)
         MOVE    #12,txSize(A2)
         MOVE    #srcXor,txMode(A2)
         CLR     -(SP)
         PEA     .2(PC)
         TBX     StringWidth
         MOVE    .1+6(PC),D0
         SUB     .1+2(PC),D0
         SUB     (SP)+,D0
         ASR     #1,D0
         ADD     .1+2(PC),D0
         MOVE    D0,PnLoc+h(A2)
         MOVE    #164,PnLoc+v(A2)
         PEA     .2(PC)
         TBX     DrawString
         RTS
.0       DATA    /35,/0,/37,/481
.1       DATA    /150,/0,/169,/481
.2       STR     "Copyright, 1985 Mainstay"
         ADJST
DrawKeys LEA     Keys(A3),A2
         MOVEQ   #19-1,D3
.0       BSR.S   DrawKey
         CLR     D0
         MOVE.B  10(A2),D0
         OR      #1,D0
         LEA     11(A2,D0),A2
         DBRA    D3,.0
         RTS
DrawKey  LINK    A6,#-8
         MOVE.L  2(A2),-8(A6)
         MOVE.L  6(A2),-4(A6)
         TBX     PenNormal
         PEA     -8(A6)
         TBX     FrameRect
         ADDQ    #1,-8(A6)
         ADDQ    #1,-6(A6)
         SUBQ    #1,-4(A6)
         SUBQ    #1,-2(A6)
         PEA     -8(A6)
         TBX     EraseRect
         CLR     D1
         MOVE.B  10(A2),D1
         MULU    #6,D1
         SUBQ    #1,D1
         MOVE    -2(A6),D0
         SUB     -6(A6),D0
         SUB     D1,D0
         ASR     #1,D0
         ADD     -6(A6),D0
         MOVE    -8(A6),D1
         ADD     #9,D1
         MOVE.L  dCtlWindow(A4),A0
         MOVE    D0,PnLoc+h(A0)
         MOVE    D1,PnLoc+v(A0)
         MOVE    #monaco,txFont(A0)
         MOVE    #9,txSize(A0)
         MOVE    #srcOr,txMode(A0)
         PEA     10(A2)
         TBX     DrawString
         MOVE.B  (A2),D0
         BEQ.S   .1
         CMP.B   #1,D0
         BNE.S   .0
         PEA     -8(A6)
         TBX     InverRect
         BRA.S   .1
.0       MOVE.L  dCtlWindow(A4),A0
         MOVE.L  GrafGlobals(A5),A1
         MOVE.L  ltGray(A1),pnPat(A0)
         MOVE.L  ltGray+4(A1),pnPat+4(A0)
         MOVE    #patOr,pnMode(A0)
         PEA     -8(A6)
         TBX     PaintRect
.1       UNLK    A6
         RTS
*--------------------------------
InitPrt  BSR     PrDrvrOpen
RstPrt   MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrReset,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         MOVE    #30,A0
         OST     Delay
         RTS
*--------------------------------
SetPar   LEA     ParaBlk(A3),A0
         CLR.L   12(A0)
         PEA     SFR+fName(A3)
         MOVE.L  (SP)+,18(A0)
         MOVE    SFR+vRefNum(A3),22(A0)
         MOVE.B  SFR+version+1(A3),26(A0)
         RTS
*--------------------------------
OpenData BSR     SetPar
         MOVE.B  D0,27(A0)
         CLR.L   28(A0)
         OST     Open
         MOVE    24(A0),SFR+RefNum(A3)
         MOVE    16(A0),D7
         RTS
*--------------------------------
CloseF   LEA     ParaBlk(A3),A0
         CLR.L   12(A0)
         MOVE    SFR+RefNum(A3),24(A0)
         OST     Close
         MOVE    16(A0),D7
         BNE.S   .0
         CLR.L   18(A0)
         MOVE    SFR+vRefNum(A3),22(A0)
         OST     FlushVol
         MOVE    16(A0),D7
.0       RTS
*--------------------------------
CreateF  BSR     SetPar
         OST     Create
         MOVE    16(A0),D7
         RTS
*--------------------------------
DeleteF  BSR     GetInfo
         BEQ.S   .0
         CMP     #-43,D7
         BRA.S   .1
.0       MOVE    #-45,D7
         BTST    #7,40(A0)
         BNE.S   .1
         OST     Delete
         MOVE    16(A0),D7
.1       RTS
*--------------------------------
GetInfo  BSR     SetPar
         CLR     28(A0)
         OST     GetFileInfo
         MOVE    16(A0),D7
         RTS
*--------------------------------
LErr0    MOVE    D7,-(SP)
         MOVE.L  ProgHdl(A3),A0
         CLR.L   D0
         OST     SetHandleSize
         BSR     CloseF
         MOVE    (SP)+,D7
         BRA.S   Err
SErr1    MOVE    D7,-(SP)
         BSR     CloseF
         MOVE    (SP)+,D7
SErr0    MOVE    D7,-(SP)
         BSR     DeleteF
         MOVE    (SP)+,D7
Err      BSR     DLine
         BSR     DispText
         BSR     DrawKeys
         PEA     .10(PC)
         TBX     EraseRect
         MOVE.L  dCtlWindow(A4),A0
         MOVE    #143,PnLoc+h(A0)
         MOVE    #066,PnLoc+v(A0)
         MOVE    #monaco,txFont(A0)
         MOVE    #9,txSize(A0)
         MOVE    #srcOr,txMode(A0)
         LEA     TErr(PC),A0
.0       MOVE.B  (A0)+,D0
         BEQ.S   .1
         EXT     D0
         CMP     D0,D7
         BEQ.S   .1
         CLR     D0
         MOVE.B  (A0)+,D0
         ADD     D0,A0
         BRA.S   .0
.1       MOVE.L  A0,-(SP)
         TBX     DrawString
         PEA     .12(PC)
         TBX     DrawString
         PEA     .10(PC)
         TBX     InverRect
         MOVE    #4,-(SP)
         OST     SysBeep
         MOVE.L  #300,A0
         OST     Delay
         PEA     .10(PC)
         TBX     EraseRect
         BSR     DrawKeys
         MOVEQ   #15,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
         MOVEQ   #16,D1
         BSR     FindRec
         MOVE.B  #0,(A2)
         BSR     DrawKey
         BRA     CtlDone
.10      DATA    /045,/133,/082,/347
.12      STR     " error."
         ADJST
*--------------------------------
ESTR     MACRO
         DATA    #]1
         STR     "]2"
         ENDM
*--------------------------------
TErr     ESTR    -33,"Directory full"
         ESTR    -34,"Disk full"
         ESTR    -36,"Disk I/O"
         ESTR    -39,"End of file"
         ESTR    -44,"Write protected diskette"
         ESTR    -45,"File locked"
         ESTR    -46,"Volume locked"
         ESTR    -47,"File busy"
         ESTR      0,"File system"
         ADJST
*--------------------------------
PrintErr EQU     $0944
*--------------------------------
PrDrvrOpen
         MOVEQ   #24,D0
Pr_7     CLR     -(SP)
         DBRA    D0,Pr_7
         LEA     Pr_9(PC),A0
         MOVE.L  A0,18(A7)
         MOVE.L  A7,A0
         OST     Open
Pr_8     ADD     #50,A7
         MOVE    D0,PrintErr
         RTS
Pr_9     STR     ".Print"
         ASC     " "
*--------------------------------
PrDrvrClose
         SUB     #50,A7
         MOVE.L  A7,A0
         MOVE    #$FFFD,24(A0)
         OST     Close
         BRA.S   Pr_8
*--------------------------------
PrCtlCall
         MOVE.L  (SP)+,A0
         MOVE.L  (SP)+,A1
         MOVE.L  (SP)+,D0
         MOVE.L  (SP)+,D1
         MOVE    (SP)+,D2
         MOVE.L  A0,-(SP)
         SUB     #50,A7
         MOVE    D2,26(A7)
         MOVE.L  D1,28(A7)
         MOVE.L  D0,32(A7)
         MOVE.L  A1,36(A7)
         MOVE    #$FFFD,24(A7)
         MOVE.L  A7,A0
         OST     Control
         BRA.S   Pr_8
*--------------------------------
KREC     MACRO
         DATA    #]1,#0,/]2,/]3,/]4,/]5
         STR     "]6"
         ADJST
         ENDM
*--------------------------------
wBounds  DATA    /50,/10,/219,/491
Brect    DATA    /45,/26,/142,/454
MKeys    KREC    0,045,026,058,125,"Extended"
         KREC    0,057,026,070,125,"Pica"
         KREC    0,069,026,082,125,"Elite"
         KREC    0,081,026,094,125,"Pica P."
         KREC    0,093,026,106,125,"Elite P."
         KREC    1,105,026,118,125,"Semicondensed"
         KREC    0,117,026,130,125,"Condensed"
         KREC    0,129,026,142,125,"Ultracondensed"
         KREC    0,045,133,058,232,"Header"
         KREC    1,069,133,082,232,"6 lines/inch"
         KREC    0,081,133,094,232,"8 lines/inch"
         KREC    0,045,248,058,347,"Form Feed"
         KREC    0,069,248,082,347,"Line Feed"
         KREC    0,105,248,118,347,"Left Margin"
         KREC    0,129,248,142,347,"Right Margin"
         KREC    0,045,355,058,454,"Load"
         KREC    2,069,355,082,454,"Save"
         KREC    2,105,355,118,454,"Playback"
         KREC    0,129,355,142,454,"Record"
MKLen    EQU     *-MKeys
*--------------------------------
         ENDR
*================================
         END
