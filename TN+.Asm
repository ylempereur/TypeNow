;SAVE"TN+.Asm"
*--------------------------------
; TypeNow+ v1.0 ß2     (09/08/86)
*--------------------------------
         LIST    OFF
*--------------------------------
         INCLUDE ":Sources:Library.Asm"
*--------------------------------
KeyMap           EQU  $174
;
dCtlStorage      EQU  $14
dCtlRefNum       EQU  $18
dCtlWindow       EQU  $1E
;
csCode           EQU  $1A
csParam          EQU  $1C
;
goodBye          EQU  -1
accEvent         EQU  64
accRun           EQU  65
accCursor        EQU  66
accMenu          EQU  67
accUndo          EQU  68
accCut           EQU  70
accCopy          EQU  71
accPaste         EQU  72
accClear         EQU  73
;
evtNum           EQU  0
evtMessage       EQU  2
evtMouse         EQU  $A
evtMeta          EQU  $E
;
mButDwnEvt       EQU  1
;
rDocProc         EQU  16
;
portBits         EQU  $2
portRect         EQU  $10
pnLoc            EQU  $30
txFont           EQU  $44
txMode           EQU  $48
txSize           EQU  $4A
windowKind       EQU  $6C
;
sysFont          EQU  0
monaco           EQU  4
;
gray             EQU  $FFFFFFE8
;
srcCopy          EQU  0
srcOr            EQU  1
srcBic           EQU  3
notPatXor        EQU  14
;
crossCursor      EQU  2
;
v                EQU  0
h                EQU  2
;
top              EQU  0
left             EQU  2
bottom           EQU  4
right            EQU  6
;
ioResult         EQU  16
ioNamePtr        EQU  18
ioVRefNum        EQU  22
ioRefNum         EQU  24
ioVersNum        EQU  26
ioPermssn        EQU  27
ioMisc           EQU  28
ioFDirIndex      EQU  28
ioFlAttrib       EQU  30
ioFlFndrInfo     EQU  32
ioBuffer         EQU  32
ioReqCount       EQU  36
ioActCount       EQU  40
ioPosMode        EQU  44
ioFlLgLen        EQU  54
ioFlRLgLen       EQU  64
ioFlCrDat        EQU  72
ioFlMdDat        EQU  76
;
fdType           EQU  0
fdCreator        EQU  4
fdFlags          EQU  8
fdLocation       EQU  10
fdFldr           EQU  14
;
fsRdPerm         EQU  1
fsWrPerm         EQU  2
;
rGood            EQU  0
rType            EQU  2
rVolume          EQU  6
rVersion         EQU  8
rName            EQU  10
;
sfPutFile        EQU  1
sfGetFile        EQU  2
;
iPrDrvrRef       EQU  -3
iPrBitsCtl       EQU  4
iPrIOCtl         EQU  5
iPrDevCtl        EQU  7
lScreenBits      EQU  0
lPaintBits       EQU  1
lPrDocOpen       EQU  $00010000
lPrPageClose     EQU  $00020000
lPrLineFeed      EQU  $00030000
lPrLFSixth       EQU  $0003FFFF
lPrLFEighth      EQU  $0003FFFE
lPrPageOpen      EQU  $00040000
lPrDocClose      EQU  $00050000
*================================
* RAM driver's private storage
*--------------------------------
         ORG     0
;
Ruler    DEFS    256
OldLine  DEFS    256
NewLine  DEFS    256
ProgHdl  DEFS    L
ProgPtr  DEFS    L
Where    DEFS    L
LinePtr  DEFS    W
LtMrg    DEFS    W
RtMrg    DEFS    W
CPI      DEFS    W
LPI      DEFS    W
Scroll   DEFS    W
CarPos   DEFS    W
CarOn    DEFS    B
CRLF     DEFS    B
Script   DEFS    B
;
PS       EQU     *
         ORG     0
*================================
         TFILE   "TypeNow+.Bin"
*--------------------------------
         RFILE   "TypeNow+",DFIL,DMOV
*================================
         RSRC    DRVR,12,0,"@TypeNow+"
*--------------------------------
Desk     DATA    /$1400          ; drvrFlags
         DATA    /0              ; drvrDelay
         DATA    /$006A          ; drvrEMask
         DATA    /0              ; drvrMenu
         DATA    /DskOpen-Desk   ; drvrOpen
         DATA    /DskDone-Desk   ; drvrPrime
         DATA    /DskCntl-Desk   ; drvrCtl
         DATA    /DskDone-Desk   ; drvrStatus
         DATA    /DskClos-Desk   ; drvrClose
DskTitle STR     "TypeNow+"
         ADJST
*--------------------------------
DskOpen  MOVEM.L A2-A4,-(SP)
         MOVE.L  A1,A4
         TST.L   dCtlWindow(A4)
         BNE.S   GotAWind
         MOVE.L  (A5),A0
         MOVE.L  (A0),-(SP)
         BTST    #2,KeyMap+7
         BEQ.S   .0
         BSR     HotPrint
         BRA.S   StdRet
.0       BSR     PrintOpen
         CLR.L   -(SP)
         CLR.L   -(SP)
         PEA     wBounds(PC)
         PEA     DskTitle(PC)
         SF      -(SP)
         MOVE    #rDocProc,-(SP)
         MOVE.L  MinusOne,-(SP)
         ST      -(SP)
         CLR.L   -(SP)
         TBX     NewWindow
         MOVE.L  (SP)+,A0
         MOVE.L  A0,dCtlWindow(A4)
         MOVE    dCtlRefNum(A4),windowKind(A0)
         MOVE.L  #PS,D0
         OST     NewHandle
         MOVE.L  A0,dCtlStorage(A4)
         OST     HLock
         MOVE.L  dCtlStorage(A4),A0
         MOVE.L  (A0),A3
         MOVEQ   #0,D0
         OST     NewHandle
         MOVE.L  A0,ProgHdl(A3)
         BSR     VarInit
         MOVE.L  dCtlStorage(A4),A0
         OST     HUnlock
StdRet   MOVE.L  (A5),A0
         MOVE.L  (SP)+,(A0)
GotAWind MOVE.L  A4,A1
         MOVEM.L (SP)+,A2-A4
DskDone  MOVEQ   #0,D0
         RTS
DskClos  MOVEM.L A2-A4,-(SP)
         MOVE.L  A1,A4
         MOVE.L  (A5),A0
         MOVE.L  (A0),-(SP)
         MOVE.L  dCtlStorage(A4),A0
         MOVE.L  (A0),A0
         MOVE.L  ProgHdl(A0),A0
         OST     DisposHandle
         MOVE.L  dCtlStorage(A4),A0
         CLR.L   dCtlStorage(A4)
         OST     DisposHandle
         MOVE.L  dCtlWindow(A4),-(SP)
         CLR.L   dCtlWindow(A4)
         TBX     DisposWindow
         BSR     PrintClose
         BRA.S   StdRet
*--------------------------------
DskCntl  MOVEM.L A2-A4,-(SP)
         MOVE.L  A1,A4
         MOVE    csCode(A0),D0
         CMP     #accEvent,D0
         BEQ.S   CtlEvent
         CMP     #goodBye,D0
         BNE.S   CtlDone
         BSR     PrintClose
CtlDone  MOVE.L  A4,A1
         MOVEM.L (SP)+,A2-A4
         MOVEQ   #0,D0
         MOVE.L  JIODone,-(SP)
         RTS
*--------------------------------
CtlEvent MOVE.L  csParam(A0),A1
         MOVE.L  dCtlStorage(A4),A0
         OST     HLock
         MOVE.L  dCtlStorage(A4),A0
         MOVE.L  (A0),A3
         MOVE    evtNum(A1),D0
         CMP     #1,D0
         BEQ.S   MseDwn
         CMP     #3,D0
         BEQ.S   KeyDwn
         CMP     #5,D0
         BEQ.S   KeyDwn
         CMP     #6,D0
         BNE.S   EvtDone
         BSR.S   Update
EvtDone  MOVE.L  dCtlStorage(A4),A0
         OST     HUnlock
         BRA.S   CtlDone
Update   MOVE.L  dCtlWindow(A4),-(SP)
         TBX     BeginUpdate
         BSR     DspLine
         BSR     DspText
         TST.B   CarOn(A3)
         BEQ.S   .0
         BSR     InverCar
.0       BSR     DrawKeys
         MOVE.L  dCtlWindow(A4),-(SP)
         TBX     EndUpdate
         RTS
KeyDwn   MOVE.L  evtMessage(A1),D0
         MOVE    evtMeta(A1),D1
         BTST    #8,D1
         BEQ.S   .3
         CMP.B   #'<',D0
         BEQ.S   .0
         CMP.B   #',',D0
         BNE.S   .1
.0       MOVEQ   #$1C,D0
         BRA.S   .3
.1       CMP.B   #'>',D0
         BEQ.S   .2
         CMP.B   #'.',D0
         BNE.S   .4
.2       MOVEQ   #$1D,D0
.3       BSR     DoKey
.4       BRA.S   EvtDone
MseDwn   MOVE.L  evtMouse(A1),Where(A3)
         MOVE.L  (A5),A0
         MOVE.L  dCtlWindow(A4),(A0)
         PEA     Where(A3)
         TBX     GlobalToLocal
         LEA     CPIminus(PC),A2
         BSR     TracKey
         BEQ.S   .0
         TST     CPI(A3)
         BEQ.S   EvtDone
         SUBQ    #1,CPI(A3)
         BSR     AdjCPI
         LEA     CPIdial(PC),A2
         BSR     DrawKey
         BRA     EvtDone
.0       LEA     CPIplus(PC),A2
         BSR     TracKey
         BEQ.S   .1
         CMP     #14,CPI(A3)
         BHS     EvtDone
         ADDQ    #1,CPI(A3)
         BSR     AdjCPI
         LEA     CPIdial(PC),A2
         BSR     DrawKey
         BRA     EvtDone
.1       LEA     LPIminus(PC),A2
         BSR     TracKey
         BEQ.S   .2
         TST     LPI(A3)
         BEQ     EvtDone
         SUBQ    #1,LPI(A3)
         BSR     AdjLPI
         LEA     LPIdial(PC),A2
         BSR     DrawKey
         BRA     EvtDone
.2       LEA     LPIplus(PC),A2
         BSR     TracKey
         BEQ.S   .3
         TST     LPI(A3)
         BNE     EvtDone
         ADDQ    #1,LPI(A3)
         BSR     AdjLPI
         LEA     LPIdial(PC),A2
         BSR     DrawKey
         BRA     EvtDone
.3       LEA     LMrec(PC),A2
         BSR     TracKey
         BEQ.S   .4
         MOVE    CarPos(A3),D0
         CMP     RtMrg(A3),D0
         BHI     EvtDone
         MOVE    D0,LtMrg(A3)
         BSR     MakRuler
         BSR     OffCar
         BSR     DspText
         BSR     OnCar
         BRA     EvtDone
.4       LEA     RMrec(PC),A2
         BSR     TracKey
         BEQ.S   .5
         MOVE    CarPos(A3),D0
         CMP     LtMrg(A3),D0
         BLS     EvtDone
         SUBQ    #1,D0
         MOVE    D0,RtMrg(A3)
         BSR     MakRuler
         BSR     OffCar
         BSR     DspText
         BSR     OnCar
         BRA     EvtDone
.5       LEA     FFrec(PC),A2
         BSR     TracKey
         BEQ.S   .6
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrPageClose,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrPageOpen,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         BRA     EvtDone
.6       LEA     LFrec(PC),A2
         BSR     TracKey
         BEQ.S   .9
         MOVE    #iPrDevCtl,-(SP)
         TST     LPI(A3)
         BNE.S   .7
         MOVE.L  #lPrLFSixth,-(SP)
         BRA.S   .8
.7       MOVE.L  #lPrLFEighth,-(SP)
.8       CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         BRA     EvtDone
.9       LEA     SCRrec(PC),A2
         BSR     TracKey
         BEQ     .15
         MOVE.L  ProgHdl(A3),A0
         MOVEQ   #0,D0
         OST     SetHandleSize
         SF      Script(A3)
         LINK    A6,#-154
         MOVE    #82,-(SP)
         MOVE    #81,-(SP)
         PEA     .21(PC)
         CLR.L   -(SP)
         MOVE    #1,-(SP)
         PEA     .20(PC)
         CLR.L   -(SP)
         PEA     -154(A6)
         MOVE    #sfGetFile,-(SP)
         TBX     Pack3
         TST.B   -154+rGood(A6)
         BEQ     .14
         BSR     Update
         LEA     -80(A6),A0
         LEA     -154+rName(A6),A1
         MOVE.L  A1,ioNamePtr(A0)
         MOVE    -154+rVolume(A6),ioVRefNum(A0)
         MOVE.B  -154+rVersion(A6),ioVersNum(A0)
         CLR     ioFDirIndex(A0)
         OST     GetFileInfo
         MOVE    ioResult(A0),D0
         BNE     .13
         MOVE.L  ioFlLgLen(A0),D0
         MOVE.L  ProgHdl(A3),A0
         OST     SetHandleSize
         BNE     .12
         LEA     -80(A6),A0
         MOVE.B  #fsRdPerm,ioPermssn(A0)
         CLR.L   ioMisc(A0)
         OST     Open
         MOVE    ioResult(A0),D0
         BNE     .12
         MOVE.L  ProgHdl(A3),A0
         OST     HLock
         MOVE.L  ProgHdl(A3),A0
         OST     GetHandleSize
         LEA     -80(A6),A0
         MOVE.L  ProgHdl(A3),A1
         MOVE.L  (A1),ioBuffer(A0)
         MOVE.L  D0,ioReqCount(A0)
         CLR     ioPosMode(A0)
         OST     Read
         MOVE    ioResult(A0),D0
         BNE.S   .10
         MOVE.L  ProgHdl(A3),A0
         OST     HUnlock
         LEA     -80(A6),A0
         OST     Close
         MOVE    ioResult(A0),D0
         BNE.S   .12
         CLR.L   ProgPtr(A3)
         ST      Script(A3)
         BSR     OffCar
         LEA     NewLine(A3),A0
         MOVE.L  #$20202020,D0
         MOVEQ   #256/4-1,D1
.16      MOVE.L  D0,(A0)+
         DBRA    D1,.16
         BSR     GetLine
         BSR     PrintLine
         MOVE    LtMrg(A3),CarPos(A3)
         BSR     AdjCar
         BSR     DspText
         BSR     OnCar
         BRA.S   .14
.10      MOVE    D0,-(SP)
         OST     Close
         MOVE    (SP)+,D0
.11      MOVE.L  ProgHdl(A3),A0
         OST     HUnlock
.12      MOVE.L  ProgHdl(A3),A0
         MOVEQ   #0,D0
         OST     SetHandleSize
.13      MOVE    #4,-(SP)
         OST     SysBeep
.14      UNLK    A6
.15      BRA     EvtDone
.20      ASC     "TEXT"
.21      STR     ""
         ADJST
*--------------------------------
TracKey  LINK    A6,#-8
         MOVE.L  (A2)+,-8(A6)
         MOVE.L  (A2)+,-4(A6)
         CLR.B   -(SP)
         MOVE.L  Where(A3),-(SP)
         PEA     -8(A6)
         TBX     PtInRect
         TST.B   (SP)+
         BEQ.S   .1
         ADDQ    #1,-8(A6)
         ADDQ    #1,-6(A6)
         SUBQ    #1,-4(A6)
         SUBQ    #1,-2(A6)
         PEA     -8(A6)
         TBX     InverRect
.0       CLR.B   -(SP)
         TBX     WaitMouseUp
         TST.B   (SP)+
         BNE.S   .0
         PEA     -8(A6)
         TBX     InverRect
         MOVEQ   #-1,D0
.1       UNLK    A6
         RTS
*--------------------------------
DoKey    BSR     OffCar
         CMP.B   #128,D0
         BHS     .71
         CMP.B   #32,D0
         BLO.S   .10
         MOVE    LtMrg(A3),D1
         CMP     CarPos(A3),D1
         BHI     .71
         MOVE    RtMrg(A3),D1
         CMP     CarPos(A3),D1
         BLO     .71
         LEA     NewLine(A3),A0
         ADD     D1,A0
         SUB     CarPos(A3),D1
         BRA.S   .1
.0       MOVE.B  -(A0),1(A0)
.1       DBRA    D1,.0
         MOVE.B  D0,(A0)
         ADDQ    #1,CarPos(A3)
         BRA     .70
.10      CMP.B   #$08,D0         ;Backspace
         BNE.S   .20
         MOVE    LtMrg(A3),D1
         CMP     CarPos(A3),D1
         BHS     .71
         MOVE    RtMrg(A3),D1
         ADDQ    #1,D1
         CMP     CarPos(A3),D1
         BLO     .71
         SUBQ    #1,CarPos(A3)
         LEA     NewLine(A3),A0
         ADD     CarPos(A3),A0
         MOVE    RtMrg(A3),D1
         SUB     CarPos(A3),D1
         BRA.S   .12
.11      MOVE.B  1(A0),(A0)+
.12      DBRA    D1,.11
         MOVE.B  #' ',(A0)
         BRA     .70
.20      CMP.B   #$09,D0         ;Tab
         BNE.S   .30
         MOVE    LtMrg(A3),D1
         CMP     CarPos(A3),D1
         BHI     .71
.21      MOVE    RtMrg(A3),D1
         CMP     CarPos(A3),D1
         BLO     .70
         ADDQ    #1,CarPos(A3)
         MOVE    CarPos(A3),D1
         AND     #$0007,D1
         BNE.S   .21
         BRA.S   .70
.30      CMP.B   #$1C,D0         ;<-
         BNE.S   .40
         TST     CarPos(A3)
         BEQ.S   .71
         SUBQ    #1,CarPos(A3)
         BRA.S   .70
.40      CMP.B   #$1D,D0         ;->
         BNE.S   .50
         CMP     #256,CarPos(A3)
         BHS.S   .71
         ADDQ    #1,CarPos(A3)
         BRA.S   .70
.50      CMP.B   #$03,D0         ;Enter
         BNE.S   .60
         SF      CRLF(A3)
         BRA.S   .61
.60      CMP.B   #$0D,D0         ;Return
         BNE.S   .71
         ST      CRLF(A3)
.61      BSR     PrintLine
         MOVE    LtMrg(A3),CarPos(A3)
.70      BSR     AdjCar
         BSR     DspText
.71      BSR     OnCar
         RTS
*--------------------------------
PrintLine
         TST.B   Script(A3)
         BEQ     .7
.0       LEA     NewLine(A3),A0
         MOVE    LinePtr(A3),D1
.1       CMP     #256,D1
         BHS.S   .5
         CMP.B   #'_,0(A0,D1)
         BEQ.S   .2
         ADDQ    #1,D1
         BRA.S   .1
.2       MOVE    D1,LtMrg(A3)
.3       MOVE.B  #' ,0(A0,D1)
         CMP     #255,D1
         BHS.S   .4
         CMP.B   #'_,1(A0,D1)
         BNE.S   .4
         ADDQ    #1,D1
         BRA.S   .3
.4       MOVE    D1,RtMrg(A3)
         ADDQ    #1,D1
         MOVE    D1,LinePtr(A3)
         BSR     MakRuler
         RTS
.5       MOVE    #000,LtMrg(A3)
         MOVE    #255,RtMrg(A3)
         ST      CRLF(A3)
         BSR.S   .7
         MOVE.L  ProgHdl(A3),A0
         OST     GetHandleSize
         CMP.L   ProgPtr(A3),D0
         BLS.S   .6
         BSR     GetLine
         BRA.S   .0
.6       MOVE.L  ProgHdl(A3),A0
         MOVEQ   #0,D0
         OST     SetHandleSize
         SF      Script(A3)
         MOVE    #08,LtMrg(A3)
         MOVE    #71,RtMrg(A3)
         BSR     MakRuler
         RTS
.7       BSR     PrintText
         LEA     OldLine(A3),A0
         LEA     NewLine(A3),A1
         MOVE.L  #$20202020,D0
         MOVEQ   #256/4-1,D1
.8       MOVE.L  (A1),(A0)+
         MOVE.L  D0,(A1)+
         DBRA    D1,.8
         RTS
*--------------------------------
GetLine  MOVE.L  ProgHdl(A3),A0
         OST     GetHandleSize
         MOVE.L  D0,D3
         MOVE.L  ProgPtr(A3),D2
         MOVE    #256-1,D1
         LEA     NewLine(A3),A1
         MOVE.L  ProgHdl(A3),A0
         MOVE.L  (A0),A0
.0       CMP.L   D3,D2
         BHS.S   .1
         MOVE.B  0(A0,D2.L),D0
         ADDQ.L  #1,D2
         CMP.B   #$0D,D0
         BEQ.S   .1
         MOVE.B  D0,(A1)+
         DBRA    D1,.0
.1       MOVE.L  D2,ProgPtr(A3)
         CLR     LinePtr(A3)
         RTS
*--------------------------------
AdjCar   MOVE    CarPos(A3),D0
         SUB     Scroll(A3),D0
         CMP     #008,D0
         BGT.S   .3
         CMP     #000,D0
         BLT.S   .2
         CMP     #008,CarPos(A3)
         BGT.S   .1
.0       MOVE    #000,Scroll(A3)
         RTS
.1       MOVE    CarPos(A3),Scroll(A3)
         SUB     #008,Scroll(A3)
         RTS
.2       CMP     #024,CarPos(A3)
         BLE.S   .0
         MOVE    CarPos(A3),Scroll(A3)
         SUB     #024,Scroll(A3)
         RTS
.3       CMP     #056,D0
         BLT.S   .7
         CMP     #064,D0
         BGT.S   .6
         CMP     #248,CarPos(A3)
         BLT.S   .5
.4       MOVE    #192,Scroll(A3)
         RTS
.5       MOVE    CarPos(A3),Scroll(A3)
         SUB     #056,Scroll(A3)
         RTS
.6       CMP     #216,CarPos(A3)
         BGE.S   .4
         MOVE    CarPos(A3),Scroll(A3)
         SUB     #040,Scroll(A3)
.7       RTS
*--------------------------------
DspText  MOVE.L  dCtlWindow(A4),A2
         MOVE.L  (A5),A0
         MOVE.L  A2,(A0)
         MOVE    #monaco,txFont(A2)
         MOVE    #9,txSize(A2)
         MOVE    #srcCopy,txMode(A2)
         MOVE    #04,pnLoc+h(A2)
         MOVE    #11,pnLoc+v(A2)
         PEA     Ruler(A3)
         MOVE    Scroll(A3),-(SP)
         MOVE    #64,-(SP)
         TBX     DrawText
         MOVE    #04,pnLoc+h(A2)
         MOVE    #22,pnLoc+v(A2)
         PEA     OldLine(A3)
         MOVE    Scroll(A3),-(SP)
         MOVE    #64,-(SP)
         TBX     DrawText
         MOVE    #04,pnLoc+h(A2)
         MOVE    #33,pnLoc+v(A2)
         PEA     NewLine(A3)
         MOVE    Scroll(A3),-(SP)
         MOVE    #64,-(SP)
         TBX     DrawText
         RTS
*--------------------------------
TempRect EQU     -8
*--------------------------------
OnCar    TST.B   CarOn(A3)
         BNE.S   .0
         BSR     InverCar
         ST      CarOn(A3)
.0       RTS
OffCar   TST.B   CarOn(A3)
         BEQ.S   .0
         BSR     InverCar
         SF      CarOn(A3)
.0       RTS
InverCar LINK    A6,#-8
         MOVEM.L D0/A0,-(SP)
         MOVE.L  (A5),A0
         MOVE.L  dCtlWindow(A4),(A0)
         LEA     TempRect(A6),A0
         MOVE    #024,top(A0)
         MOVE    #035,bottom(A0)
         MOVE    CarPos(A3),D0
         SUB     Scroll(A3),D0
         MULU    #06,D0
         ADD     #04,D0
         MOVE    D0,right(A0)
         SUBQ    #1,D0
         MOVE    D0,left(A0)
         MOVE.L  A0,-(SP)
         TBX     InverRect
         MOVEM.L (SP)+,D0/A0
         UNLK    A6
         RTS
*--------------------------------
DspLine  MOVE.L  dCtlWindow(A4),A2
         MOVE.L  (A5),A0
         MOVE.L  A2,(A0)
         TBX     PenNormal
         PEA     .10(PC)
         TBX     PaintRect
         PEA     .11(PC)
         TBX     PaintRect
         MOVE    #sysFont,txFont(A2)
         MOVE    #12,txSize(A2)
         MOVE    #srcBic,txMode(A2)
         CLR     -(SP)
         PEA     .13(PC)
         TBX     StringWidth
         MOVE    .11+right(PC),D0
         SUB     .11+left(PC),D0
         SUB     (SP)+,D0
         ASR     #1,D0
         ADD     .11+left(PC),D0
         MOVE    D0,pnLoc+h(A2)
         MOVE    #089,pnLoc+v(A2)
         PEA     .13(PC)
         TBX     DrawString
         RTS
.10      DATA    /037,/000,/039,/391
.11      DATA    /075,/000,/093,/391
.13      STR     "Copyright 1986, Mainstay"
         ADJST
*--------------------------------
DrawKeys LEA     CPIstr(PC),A2
         BSR     DrawStr
         LEA     LPIstr(PC),A2
         BSR     DrawStr
         LEA     LMrec(PC),A2
         BSR     DrawKey
         LEA     FFrec(PC),A2
         BSR     DrawKey
         LEA     SCRrec(PC),A2
         BSR     DrawKey
         LEA     CPIminus(PC),A2
         BSR     DrawKey
         LEA     CPIdial(PC),A2
         BSR     DrawKey
         LEA     CPIplus(PC),A2
         BSR     DrawKey
         LEA     LPIminus(PC),A2
         BSR     DrawKey
         LEA     LPIdial(PC),A2
         BSR     DrawKey
         LEA     LPIplus(PC),A2
         BSR     DrawKey
         LEA     RMrec(PC),A2
         BSR     DrawKey
         LEA     LFrec(PC),A2
         BSR     DrawKey
         RTS
DrawKey  TBX     PenNormal
         MOVE.L  A2,-(SP)
         TBX     FrameRect
DrawStr  LINK    A6,#-8
         MOVE.L  (A2)+,-8(A6)
         MOVE.L  (A2)+,-4(A6)
         ADDQ    #1,-8(A6)
         ADDQ    #1,-6(A6)
         SUBQ    #1,-4(A6)
         SUBQ    #1,-2(A6)
         PEA     -8(A6)
         TBX     EraseRect
         CLR     D1
         MOVE.B  (A2),D1
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
         MOVE    D0,pnLoc+h(A0)
         MOVE    D1,pnLoc+v(A0)
         MOVE    #monaco,txFont(A0)
         MOVE    #9,txSize(A0)
         MOVE    #srcOr,txMode(A0)
         MOVE.L  A2,-(SP)
         TBX     DrawString
         UNLK    A6
         RTS
*--------------------------------
VarInit  SF      Script(A3)
         MOVE    #08,LtMrg(A3)
         MOVE    #71,RtMrg(A3)
         MOVE    #0,CPI(A3)
         BSR     AdjCPI
         MOVE    #0,LPI(A3)
         BSR     AdjLPI
         MOVE    LtMrg(A3),CarPos(A3)
         CLR     Scroll(A3)
         BSR     AdjCar
         ST      CarOn(A3)
         LEA     Ruler(A3),A0
         LEA     OldLine(A3),A1
         LEA     NewLine(A3),A2
         MOVE.L  #$20202020,D0
         MOVEQ   #256/4-1,D1
.0       MOVE.L  D0,(A0)+
         MOVE.L  D0,(A1)+
         MOVE.L  D0,(A2)+
         DBRA    D1,.0
         BSR.S   MakRuler
         RTS
*--------------------------------
MakRuler LEA     Ruler(A3),A0
         MOVE.L  #$2B2D2D2D,D0
         MOVE.L  #$2D2D2D2D,D1
         MOVEQ   #256/(2*4)-1,D2
.0       MOVE.L  D0,(A0)+
         MOVE.L  D1,(A0)+
         DBRA    D2,.0
         LEA     Ruler(A3),A0
         MOVEQ   #'0',D0
         MOVE    #26-1,D1
.1       MOVE.B  D0,(A0)
         CMP.B   #'9',D0
         BNE.S   .2
         SUB.B   #10,D0
.2       ADDQ.B  #1,D0
         ADD     #10,A0
         DBRA    D1,.1
         LEA     Ruler(A3),A0
         MOVE    LtMrg(A3),D0
         MOVE.B  #'•',0(A0,D0)
         MOVE    RtMrg(A3),D0
         MOVE.B  #'•',0(A0,D0)
         RTS
*--------------------------------
AdjCPI   LEA     .10(PC),A0
         CLR     D1
         MOVE    CPI(A3),D0
.0       BEQ.S   .1
         MOVE.B  (A0)+,D1
         ADD     D1,A0
         SUBQ    #1,D0
         BRA.S   .0
.1       LEA     CPIdial+8(PC),A1
         MOVE.B  (A0),D1
.2       MOVE.B  (A0)+,(A1)+
         DBRA    D1,.2
         RTS
.10      STR     "?"
         STR     "4.5"
         STR     "5"
         STR     "6"
         STR     "6.7"
         STR     "7.5"
         STR     "8.5"
         STR     "9"
         STR     "10"
         STR     "12"
         STR     "13.4"
         STR     "15"
         STR     "17"
         STR     "Pica"
         STR     "Elite"
         ADJST
AdjLPI   LEA     .10(PC),A0
         CLR     D1
         MOVE    LPI(A3),D0
.0       BEQ.S   .1
         MOVE.B  (A0)+,D1
         ADD     D1,A0
         SUBQ    #1,D0
         BRA.S   .0
.1       LEA     LPIdial+8(PC),A1
         MOVE.B  (A0),D1
.2       MOVE.B  (A0)+,(A1)+
         DBRA    D1,.2
         RTS
.10      STR     "6"
         STR     "8"
         ADJST
*--------------------------------
PrintOpen
         BSR     PrDrvrOpen
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrDocOpen,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         MOVE    #20,A0
         OST     Delay
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrPageOpen,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         RTS
PrintText
         LEA     NewLine+256(A3),A0
         MOVE    #256-1,D7
         MOVEQ   #$20,D0
.0       CMP.B   -(A0),D0
         DBNE    D7,.0
         ADDQ    #1,D7
         BEQ.S   .5
         MOVE    LtMrg(A3),D6
         CMP     D7,D6
         BLS.S   .1
         MOVE    D7,D6
.1       TST     CPI(A3)
         BEQ.S   .2
         LEA     .11(PC),A0
         CLR.L   D0
         MOVE.B  (A0)+,D0
         MOVE    #iPrIOCtl,-(SP)
         MOVE.L  A0,-(SP)
         MOVE.L  D0,-(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
.2       TST     D6
         BEQ.S   .3
         MOVE    #iPrIOCtl,-(SP)
         PEA     NewLine(A3)
         MOVE    D6,-(SP)
         CLR     -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         SUB     D6,D7
.3       MOVE    CPI(A3),D0
         BEQ.S   .4
         LSL     #2,D0
         LEA     .10-4(PC,D0),A0
         CLR.L   D0
         MOVE.B  (A0)+,D0
         MOVE    #iPrIOCtl,-(SP)
         MOVE.L  A0,-(SP)
         MOVE.L  D0,-(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
.4       TST     D7
         BEQ.S   .5
         MOVE    #iPrIOCtl,-(SP)
         LEA     NewLine(A3),A0
         PEA     0(A0,D6)
         MOVE    D7,-(SP)
         CLR     -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
.5       MOVE    #iPrDevCtl,-(SP)
         TST.B   CRLF(A3)
         BNE.S   .6
         MOVE.L  #lPrLineFeed,-(SP)
         BRA.S   .8
.6       TST     LPI(A3)
         BNE.S   .7
         MOVE.L  #lPrLFSixth,-(SP)
         BRA.S   .8
.7       MOVE.L  #lPrLFEighth,-(SP)
.8       CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         RTS
.10      HEX     031B6E0E.031B4E0E.031B450E.031B650E
         HEX     031B710E.031B510E.031B6E0F.031B4E0F
         HEX     031B450F.031B650F.031B710F.031B510F
         HEX     031B700F.031B500F
.11      HEX     071B4400011B650F
PrintClose
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrPageClose,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrDocClose,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         BSR     PrDrvrClose
         RTS
*--------------------------------
wBounds  DATA    /060,/020,/153,/411
*--------------------------------
KREC     MACRO
         DATA    /]1,/]2,/]3,/]4
         STR     "]5"
         ADJST
         ENDM
*--------------------------------
CPIstr   KREC    043,020,056,075,"CPI"
CPIminus KREC    058,020,071,029,"<"
CPIdial  KREC    058,028,071,067,"      "
CPIplus  KREC    058,066,071,075,">"
LPIstr   KREC    043,094,056,149,"LPI"
LPIminus KREC    058,094,071,103,"<"
LPIdial  KREC    058,102,071,141,"      "
LPIplus  KREC    058,140,071,149,">"
LMrec    KREC    043,168,056,223,"L Margin"
RMrec    KREC    058,168,071,223,"R Margin"
FFrec    KREC    043,242,056,297,"Page"
LFrec    KREC    058,242,071,297,"Line"
SCRrec   KREC    043,316,056,371,"Script"
*++++++++++++++++++++++++++++++++
* HotPrint;
*--------------------------------
EventRecord      EQU  -16
DestRect         EQU  -8
*--------------------------------
HotPrint LINK    A6,#-16
         MOVE.L  WMgrPort,-(SP)
         TBX     SetPort
         MOVE.L  WMgrPort,A0
         PEA     portRect(A0)
         TBX     ClipRect
         CLR.L   -(SP)
         MOVE    #crossCursor,-(SP)
         TBX     GetCursor
         MOVE.L  (SP)+,A0
         MOVE.L  (A0),-(SP)
         TBX     SetCursor
.0       CLR.B   -(SP)
         MOVE    #$0002,-(SP)
         PEA     EventRecord(A6)
         TBX     GetNextEvent
         TST.B   (SP)+
         BEQ.S   .0
         MOVE    EventRecord+evtNum(A6),D0
         CMP     #mButDwnEvt,D0
         BNE.S   .0
         MOVE.L  EventRecord+evtMouse(A6),-(SP)
         PEA     DestRect(A6)
         BSR     GrowRect
         MOVE    DestRect+right(A6),D0
         SUB     DestRect+left(A6),D0
         MOVE    DestRect+bottom(A6),D1
         SUB     DestRect+top(A6),D1
         MULS    D1,D0
         CMP.L   #64,D0
         BLT.S   .1
         PEA     DestRect(A6)
         BSR     PrintRect
.1       TBX     InitCursor
         UNLK    A6
         RTS
*--------------------------------
* PrintRect (r: Rect);
*--------------------------------
PrintRect
         LINK    A6,#0
         MOVEM.L D3-D7/A2-A4,-(SP)
         TBX     HideCursor
         BSR     PrDrvrOpen
         TST     PrintErr
         BNE     .2
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrDocOpen,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         TST     PrintErr
         BNE.S   .1
         MOVE    #20,A0
         OST     Delay
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrPageOpen,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         TST     PrintErr
         BNE.S   .0
         MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrLFSixth,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
         TST     PrintErr
         BNE.S   .0
         MOVE.L  WMgrPort,A0
         MOVE    #iPrBitsCtl,-(SP)
         PEA     portBits(A0)
         MOVE.L  8(A6),-(SP)
         MOVE.L  #lPaintBits,-(SP)
         BSR     PrCtlCall
.0       MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrPageClose,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
.1       MOVE    #iPrDevCtl,-(SP)
         MOVE.L  #lPrDocClose,-(SP)
         CLR.L   -(SP)
         CLR.L   -(SP)
         BSR     PrCtlCall
.2       BSR     PrDrvrClose
         TBX     ShowCursor
         MOVEM.L (SP)+,D3-D7/A2-A4
         UNLK    A6
         MOVE.L  (SP)+,A0
         ADDQ    #4,A7
         JMP     (A0)
*--------------------------------
* GrowRect (startPt: point; VAR r: Rect);
*--------------------------------
GrowRect LINK    A6,#0
         MOVEM.L D3-D7/A2-A4,-(SP)
         MOVE.L  (A5),A0
         PEA     gray(A0)
         TBX     PenPat
         MOVE    #notPatXor,-(SP)
         TBX     PenMode
         MOVE.L  08(A6),A2
         MOVE.L  12(A6),D4
         MOVE.L  D4,(A2)
         MOVE.L  D4,4(A2)
         CLR.L   D3
.0       MOVE.L  Ticks,D7
.1       SUBQ    #2,A7
         TBX     WaitMouseUp
         TST.B   (SP)+
         BEQ.S   .2
         MOVE.L  Ticks,D0
         SUB.L   D7,D0
         SUBQ    #2,D0
         BLT.S   .1
         SUBQ    #4,A7
         MOVE.L  A7,-(SP)
         TBX     GetMouse
         MOVE.L  (SP)+,D0
         ADD.L   #$00010001,D0
         CMP.L   D3,D0
         BEQ.S   .0
         MOVE.L  D0,D3
         MOVE.L  A2,-(SP)
         TBX     FrameRect
         MOVE.L  D4,-(SP)
         MOVE.L  D3,-(SP)
         MOVE.L  A2,-(SP)
         TBX     Pt2Rect
         MOVE.L  A2,-(SP)
         TBX     FrameRect
         BRA.S   .0
.2       MOVE.L  A2,-(SP)
         TBX     FrameRect
         TBX     PenNormal
         MOVEM.L (SP)+,D3-D7/A2-A4
         UNLK    A6
         MOVE.L  (SP)+,A0
         ADDQ    #8,A7
         JMP     (A0)
*--------------------------------
         INCLUDE ":Sources:PrintCalls.Asm"
*--------------------------------
         ENDR
*================================
         END
