UCGMCU(file)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCGMCU ****
	;
	; 09/10/2007 17:31 - chenardp
	;
	; I18N=QUIT
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.                             *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other than during an        *
	; * upgrade an mrtns version of this routine should not exist.      *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	;
	D info("^UCGMCU()","PSL Compiler Upgrade verfication","start")
	;
	N units S units=$$getList("Compiler")
	S units=$$cascade(file,units)
	I (units="") D info("^UCGMCU()","No differences found","end") Q 
	;
	N src S src="These PSL Compiler units "
	I file S src=src_"have been"
	E  S src=src_"need to be"
	WRITE !!
	D info("^UCGMCU()",units,src_" re-generated")
	WRITE !!
	;
	Q 
	;
	; ---------------------------------------------------------------------
afterConst()	; To be called after PSL constant has been modified
	;
	D info("afterConst^UCGMCU()","PSL Compiler After Constant Changed Processing","start")
	;
	N cascade S cascade=$$cascade(1,$$getList("Compiler"))
	WRITE !!
	I (cascade="") D info("afterConst^UCGMCU()","No differences found","end") Q 
	;
	D info("afterConst^UCGMCU()",cascade,"New versions of these PSL Compiler units have been generated")
	;
	Q 
	;
	; ---------------------------------------------------------------------
boot(vDataDir,%VN)	;
	;
	; Update the current image by ZLINKing the routines that may have been
	; called before
	D linkList($$getList("Insensitive"))
	D linkList($$getList("Dictionary"))
	D linkList($$getList("Object"))
	D linkList($$getList("Upgrade"))
	;
	; Generate routine UCOPTS
	D bootUCOPTS()
	;
	; Boot the remainder of the PSL compiler, SQL engine, and DBS kernel
	N sysList
	N elm
	N unt
	;
	S sysList=$$getList("Data")
	F elm=1:1:$S((sysList=""):0,1:$L(sysList,",")) D
	.	S unt=$piece(sysList,",",elm)
	.	;
	.	I unt="UCOPTS" Q  ; UCOPTS already compiled separately
	.	;
	.	N co ; compiler options (clean set per call)
	.	;
	.	I '($get(vDataDir)="") S co("boot","datadirectory")=vDataDir
	.	;
	.	D getBootOptions(.co)
	.	;
	.	S co("boot","restrictionlevel")=2 ; force restriction level
	.	;
	.	D bootCmp(unt,.co)
	.	;
	.	; ZLINK new, environment specific, version (to deal with polluted image)
	.	D linkList(unt)
	.	Q 
	;
	N comList S comList=$$getList("Compiler")
	F elm=1:1:$S((comList=""):0,1:$L(comList,",")) D
	.	S unt=$piece(comList,",",elm)
	.	I ((","_sysList_",")[(","_unt_",")) Q  ; Data group already done
	.	I '$$isProc^UCXDT25(unt) Q  ; not a DQ procedure
	.	D bootProc(unt)
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
bootCmp(proc,cco)	;
	N src N cfe
	;type String rtn = $$getSrc^UCXDT25( proc, .src(), 2)
	N rtn S rtn=$$getSrc^UCXDT25(proc,.src,0)
	;
	Q:rtn="" 
	Q:$D(src)<10 
	;
	D cmpA2F^UCGM(.src,rtn,,,.cco,,.cfe,rtn_"~Procedure")
	;
	I +$get(cfe)>0 Q 
	D DEL^%ZRTNDEL(rtn,$$SCAU^%TRNLNM("MRTNS"))
	Q 
	;
	; ---------------------------------------------------------------------
bootFiler(table)	; table for which to compile filer
	N co ; compiler options
	;
	D getBootOptions(.co)
	D COMPILE^DBSFILB(table,,.co)
	;
	Q 
	;
	; ---------------------------------------------------------------------
bootProc(proc)	; procedure to compile using bootstap settings
	N co ; compiler options
	;
	D getBootOptions(.co)
	D bootCmp(proc,.co)
	;
	Q 
	;
	; ---------------------------------------------------------------------
bootUCOPTS()	; procedure to generate routine UCOPTS
	N siteOpts ; values from UCOPTS.ini
	N uc ; UCOPTS source code
	N ln S ln=0 ; source line pointer
	;
	D decodeFile^UCGMC($$SCAU^%TRNLNM("DIR"),"UCOPTS.ini",.siteOpts)
	;
	D ca(.uc,"private UCOPTS( String Options()) // PSL Compiler Environment Options")
	;
	D ca(.uc," // *******************************************************************")
	D ca(.uc," // * IMPORTANT NOTE:                                                 *")
	D ca(.uc," // * According to the rules that apply to PSL compiler upgrades,     *")
	D ca(.uc," // * this routine is generated by the compiler from the PSL Compiler *")
	D ca(.uc," // * Environemnt Options file $SCAU_DIR/UCOPTS.ini                   *")
	D ca(.uc," // *                                                                 *")
	D ca(.uc," // * To modify environment settings on a permanent basis:            *")
	D ca(.uc," // * 1) change $SCAU_DIR/UCOPT.ini                                   *")
	D ca(.uc," // * 2) call bootUCOPTS^UCGMCU() to rebuild UCOPTS.m                 *")
	D ca(.uc," // *                                                                 *")
	D ca(.uc," // * To modify WARN, OPTIMIZE and Options settings on an incidental  *")
	D ca(.uc," // * basis, ensure that the environment variable $SCAU_UCOPTS names  *")
	D ca(.uc," // * the file that specifies these overwrites.                       *")
	D ca(.uc," // *                                                                 *")
	D ca(.uc," // * Note that you cannot specify incidental overwrites for values   *")
	D ca(.uc," // * to be returned by $$getPslValue().                              *")
	D ca(.uc," // *******************************************************************")
	;
	N def
	N opt
	N on
	N val
	;
	S def("WARN")=""
	S def("INFO")=""
	S def("OPTIMIZE")=$$allOPTIMIZE^UCGMC()
	S def("Options")=$$allOptions^UCGMC()
	S def("Options")=$$vStrRep(def("Options"),",ResultClass","",0,0,"")
	;
	; insert lines that specify settings
	F opt="WARN","INFO","OPTIMIZE","Options" D
	.	D ca(.uc," //")
	.	D ca(.uc," // ---- "_(opt_" settings ")_$translate($J("",64-$L((opt_" settings ")))," ","-"))
	.	I $D(siteOpts(opt)) D
	..		S (on,val)=""
	..		F  S val=$order(siteOpts(opt,val)) Q:(val="")  D
	...			I 'siteOpts(opt,val) Q 
	...			I (on="") S on=val Q 
	...			S on=on_","_val
	...			Q 
	..		Q 
	.	E  D
	..		D ca(.uc," // None specified, using PSL defaults")
	..		S on=def(opt)
	..		Q 
	.	;
	.	D ca(.uc," set Options("_$S(opt'["""":""""_opt_"""",1:$$QADD^%ZS(opt,""""))_") = "_$S(on'["""":""""_on_"""",1:$$QADD^%ZS(on,"""")))
	.	Q 
	D ca(.uc," quit")
	;
	; add $$charsetName()
	D ca(.uc,"")
	D ca(.uc," // *******************************************************************")
	D ca(.uc,"private charsetName() // return current character set as runtime value")
	D ca(.uc," quit Runtime.charsetName")
	;
	; add $$getPslValue()
	N objdef
	N prop S prop=""
	N propDes S propDes=$C(-1)
	N pslProp
	N rtn
	;
	D opAll^UCXOBJ(.pslProp,"PSL")
	;
	D ca(.uc,"")
	D ca(.uc," // *******************************************************************")
	D ca(.uc,"private getPslValue( String property) // return value of PSL.xxxYyyZzz property")
	;
	D ca(.uc," // ---- PSL.maxCharValue ----")
	D ca(.uc," // This value indicates the maximum value that is allowed in $CHAR().")
	D ca(.uc," // The value depends on the GT.M version and if the GT.M version")
	D ca(.uc," // supports Unicode it also depends on the setting of $ZCHSET.")
	D ca(.uc," // Note that GT.M treats 0x10FFFF and 0x10FFFE as unmapped characters.")
	D ca(.uc," //")
	;do ca(.uc(), " #IF $$gtmLevel^UCGM(5.2)")
	;do ca(.uc(), " #IF $ZCHSET=""UTF-8"" if property = ""maxCharValue"" quit 1114109")
	;do ca(.uc(), " #IF $ZCHSET=""M"" if property = ""maxCharValue"" quit 255")
	;do ca(.uc(), " #ELSE")
	;do ca(.uc(), " if property = ""maxCharValue"" quit 255")
	;do ca(.uc(), " #END")
	D ca(.uc," #IF $$rtChset^UCBYTSTR()=""UTF-8""")
	D ca(.uc," if property = ""maxCharValue"" quit 1114109")
	D ca(.uc," #ELSE")
	D ca(.uc," if property = ""maxCharValue"" quit 255")
	D ca(.uc," #END")
	;
	D ca(.uc," //")
	D ca(.uc," // ---- PSL.maxLineLength ----")
	D ca(.uc," // This value indicates the split value that will be used to determine")
	D ca(.uc," // if a line of M code must be split over multiple lines.")
	D ca(.uc," // For example, assigning a constant with a length close to")
	D ca(.uc," // PSL.maxStringLength to a variable requires multiple lines:")
	D ca(.uc," //     set var = ""FIRST PIECE""")
	D ca(.uc," //     set var = var_""SECOND PIECE""")
	D ca(.uc," // The value leaves room for additional characters such as the")
	D ca(.uc," //     'set var = var_'")
	D ca(.uc," // in the example above.")
	D ca(.uc," //")
	D ca(.uc," #IF $$gtmLevel^UCGM(4)")
	D ca(.uc," if property = ""maxLineLength"" quit 1980")
	D ca(.uc," #ELSE")
	D ca(.uc," if property = ""maxLineLength"" quit 450")
	D ca(.uc," #END")
	;
	D ca(.uc," //")
	D ca(.uc," // ---- PSL.maxLitLength ----")
	D ca(.uc," // The PSL compiler will try to generate code that uses literal values")
	D ca(.uc," // whenever possible. To prevent the construction of lines that exceed")
	D ca(.uc," // PSL.maxLineLength when multiple long literals occur, the maximum")
	D ca(.uc," // length of such a literal will be limited to PSL.maxLineLength / 4")
	D ca(.uc," //")
	D ca(.uc," #IF $$gtmLevel^UCGM(4)")
	D ca(.uc," if property = ""maxLitLength"" quit 511")
	D ca(.uc," #ELSE")
	D ca(.uc," if property = ""maxLitLength"" quit 255")
	D ca(.uc," #END")
	;
	D ca(.uc," //")
	D ca(.uc," // ---- PSL.maxNameLength ----")
	D ca(.uc," // This value indicates how many characters are allowed in names.")
	D ca(.uc," // The value applies to names of")
	D ca(.uc," // - local variables (error)")
	D ca(.uc," // - labels (info)")
	D ca(.uc," // - routines (info)")
	D ca(.uc," // The compiler will issue a LENGTH error or information message")
	D ca(.uc," //  when the length of a name exceeds this value")
	D ca(.uc," //")
	D ca(.uc," #IF $$gtmLevel^UCGM(5)")
	D ca(.uc," if property = ""maxNameLength"" quit 31")
	D ca(.uc," #ELSE")
	D ca(.uc," if property = ""maxNameLength"" quit 8")
	D ca(.uc," #END")
	;
	D ca(.uc," //")
	D ca(.uc," // ---- PSL.maxStringLength ----")
	D ca(.uc," // This value indicates the maximum length that is assumed for local")
	D ca(.uc," // variables. You can use this constant in constructs like")
	D ca(.uc," // String.extract(first,PSL.maxStringLength)")
	D ca(.uc," //")
	D ca(.uc," #IF $$gtmLevel^UCGM(""4.4-004"")")
	D ca(.uc," if property = ""maxStringLength"" quit 1048575")
	D ca(.uc," #ELSE")
	D ca(.uc," if property = ""maxStringLength"" quit 32767")
	D ca(.uc," #END")
	;
	D ca(.uc," //")
	D ca(.uc," // ---- supplied by UCOPTS.ini ----")
	;
	F  S prop=$order(pslProp("PSL",prop)) Q:(prop="")  D
	.	I (",maxCharValue,maxLineLength,maxNameLength,maxStringLength,"[(","_prop_",")) Q  ; not for change
	.	;
	.	S propDes=pslProp("PSL",prop)
	.	S rtn=$P(propDes,$C(124),6)
	.	I rtn'["getPslValue^UCMETHOD(" Q  ; not a PSL value
	.	;
	.	S objdef=$E(rtn,22,$L(rtn)-1)
	.	S val=$get(siteOpts("DEFINE",prop),objdef)
	.	I '(val=+val) S val=$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))
	.	D ca(.uc," //")
	.	D ca(.uc," if property = "_$S(prop'["""":""""_prop_"""",1:$$QADD^%ZS(prop,""""))_" quit "_val)
	.	Q 
	D ca(.uc," quit """"")
	;
	; generate M routine, using boot restrictionlevel = 3
	N bo N cfe
	;
	D getBootOptions(.bo)
	;
	S bo("boot","restrictionlevel")=3
	;
	D cmpA2F^UCGM(.uc,"UCOPTS",,,.bo,,.cfe,"UCOPTS.ini~file")
	;
	Q 
	;
	; ---------------------------------------------------------------------
ca(src,cod)	; Append cod to src()
	S src($order(src(""),-1)+1)=cod
	Q 
	;
	; ---------------------------------------------------------------------
cascade(file,units)	;
	N cascade S cascade="" ; the return List
	N changed S changed=1 ; iteration flag
	N elm
	N SCAUCRTNS S SCAUCRTNS=$$SCAU^%TRNLNM("CRTNS") ; .proc and .m directory
	;
	F  Q:'(changed)  D
	.	S changed=0
	.	F elm=1:1:$S((units=""):0,1:$L(units,",")) D
	..		N m ; generated M code
	..		N unit S unit=$piece(units,",",elm)
	..		;
	..		N bNeed S bNeed=$$needCompile(unit,SCAUCRTNS,.m)
	..		D cascInfo(unit,file,bNeed) ; show unit info
	..		;
	..		I 'bNeed Q 
	..		;
	..		S cascade=$S(((","_cascade_",")[(","_unit_",")):cascade,1:$S((cascade=""):unit,1:cascade_","_unit))
	..		I 'file Q 
	..		;
	..		; file the new unit, copy to SCAU_MRTNS, no ZLINK
	..		D ^%ZRTNCMP(unit,"m",1)
	..		S changed=1
	..		Q 
	.	I changed D linkAll()
	.	Q 
	;
	Q cascade
	;
	; ---------------------------------------------------------------------
cascInfo(unit,file,need)	;
	N txt
	I 'need S txt="NOT needed"
	E  D
	.	S txt="needed, "
	.	I 'file S txt=txt_"NOT "
	.	S txt=txt_"filed"
	.	Q 
	D info(unit,unit_" // PSL compiler element cascade validation","Regenerate "_txt)
	Q 
	;
	; ---------------------------------------------------------------------
date(vStr,vMsk)	;
	N voZT set voZT=$ZT
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	Q $$vStrJD(vStr,vMsk)
	;
	; ---------------------------------------------------------------------
getBootData(bo)	; boot option array
	;
	I '($D(bo("boot","datadirectory"))#2) Q 
	;
	N tbl S tbl="CUVAR"
	N ptr S ptr=$$getBootRws($$SCAU^%TRNLNM("DIR"),tbl_".DAT")
	I '(ptr="") S bo("boot",tbl)=ptr
	;
	F tbl="STBLSYSKEYWD","STBLPSLFUNSUB" D
	.	N ptr S ptr=$$getBootRws(bo("boot","datadirectory"),tbl_".DAT")
	.	I '(ptr="") S bo("boot",tbl)=ptr
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
getBootOptions(bo)	; boot option array
	S bo("boot","restrictionlevel")=1
	S bo("Options","nolink")=1
	S bo("OPTIMIZE","FUNCTIONS")=0
	;
	Q 
	;
	; ---------------------------------------------------------------------
getBootRws(dir,file)	;
	N rws S rws=$$vRwsNew(" ",$C(9))
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"  ; ignore rws.loadFromFile() exception
	.	D vRwsLFF(rws,dir,file,1)
	.	Q 
	I ($O(vobj(rws,""),-1)=0) K vobj(+$G(rws)) Q ""
	Q rws
	;
	; ---------------------------------------------------------------------
getGroup(sRtn)	; the routine for which the grooup is requested
	N sGrp
	F sGrp="Insensitive","Dictionary","Upgrade","Data","Object" I ((","_($$getList(sGrp))_",")[(","_sRtn_",")) Q 
	E  S sGrp=""
	Q sGrp
	;
	; ---------------------------------------------------------------------
getCapabilities(sSec)	; section (*1)
	I sSec="FUNCTIONS" Q $$initFcts^UCGM()
	I sSec'="KEYWORDS" Q ""
	;
	N acmd
	N cmd S cmd=""
	N cmdl S cmdl=""
	D initCmds^UCGM(.acmd)
	;
	F  S cmd=$order(acmd(cmd)) Q:(cmd="")  S cmdl=$S((cmdl=""):$$vStrLC(cmd,0),1:cmdl_","_$$vStrLC(cmd,0))
	Q cmdl_","_"literal,private,public,local,void"_","_"#accept,#break,#bypass,#else,#end,#endif,#if,#optimize,#warn,#while,#xecute,#info,#option"
	;
	; ---------------------------------------------------------------------
getList(sGrp)	;
	;
	I sGrp="Compiler" Q "UCDBSET,UCERROR,UCGMR,UCIO,UCLIST,UCMEMO,UCMETHOD,UCNUMBER,UCPATCH,UCRECCIF,UCRECDEP,UCRECLN,UCREF,UCRESULT,UCROW,UCRUNTIM,UCSCHEMA,UCSTAT,UCSTRING,UCTS,UCUTILN,SQLA,SQLAGFUN,SQLBLOB,SQLF,SQLFILER,SQLFUNCS,SQLG,SQLQ,UCCOLSF,UCDBR,UCGMCU,UCIO0,UCPSLLR,UCPSLSR,UCPSLST,UCREC4OP,UCROWSET,UCTIME,UCGMCONV,UCPRIM,UCXOBJ,UCCLASS,UCCOLUMN,UCDB,UCGM,UCGMC,UCHTML,UCLABEL,UCOBJECT,UCQRYBLD,UCRECACN,UCRECORD,UCUTIL,SQL,SQLBUF,SQLCACHE,SQLCMP,SQLCOL,SQLCONV,SQLCRE,SQLDD,SQLJ,SQLM,SQLO,SQLODBC,SQLPROT,SQLTBL,UCDBRT,UCXDD,UCXDT25,DBMAP,DBSDBASE,DBSDDMAP,DBSDYNRA,DBSMACRO,DBSTBL,UCOPTS,UCBYTSTR,SQLUTL,UCDATE,UCDTAUTL,DBSDD,DBSDI,UCXCUVAR,UCDTASYS,UCLREGEN,UCSYSMAP,SQLEFD"
	I sGrp="Data" Q "UCOPTS,UCBYTSTR,SQLUTL,UCDATE,UCDTAUTL,DBSDD,DBSDI,UCXCUVAR,UCDTASYS,UCLREGEN,UCSYSMAP,SQLEFD"
	I sGrp="Dictionary" Q "UCCLASS,UCCOLUMN,UCDB,UCGM,UCGMC,UCHTML,UCLABEL,UCOBJECT,UCQRYBLD,UCRECACN,UCRECORD,UCUTIL,SQL,SQLBUF,SQLCACHE,SQLCMP,SQLCOL,SQLCONV,SQLCRE,SQLDD,SQLJ,SQLM,SQLO,SQLODBC,SQLPROT,SQLTBL,UCDBRT,UCXDD,UCXDT25,DBMAP,DBSDBASE,DBSDDMAP,DBSDYNRA,DBSMACRO,DBSTBL"
	I sGrp="Insensitive" Q "UCDBSET,UCERROR,UCGMR,UCIO,UCLIST,UCMEMO,UCMETHOD,UCNUMBER,UCPATCH,UCRECCIF,UCRECDEP,UCRECLN,UCREF,UCRESULT,UCROW,UCRUNTIM,UCSCHEMA,UCSTAT,UCSTRING,UCTS,UCUTILN,SQLA,SQLAGFUN,SQLBLOB,SQLF,SQLFILER,SQLFUNCS,SQLG,SQLQ,UCCOLSF,UCDBR,UCGMCU,UCIO0,UCPSLLR,UCPSLSR,UCPSLST,UCREC4OP,UCROWSET,UCTIME"
	I sGrp="Object" Q "UCGMCONV,UCPRIM,UCXOBJ"
	I sGrp="Upgrade" Q "UCBYTSTR,UCDATE,UCDTAUTL,UCTIME,UCXCUVAR,SQLUTL,DBSDD"
	Q ""
	;
	; ---------------------------------------------------------------------
getComList()	;
	Q $$getList("Compiler")
getDatList()	;
	Q $$getList("Data")
getDicList()	;
	Q $$getList("Dictionary")
getInsList()	;
	Q $$getList("Insensitive")
getObjList()	;
	Q $$getList("Object")
getUpgList()	;
	Q $$getList("Upgrade")
	;
	; ---------------------------------------------------------------------
info(subRou,line,info)	;
	N cmperr N commands N m2src
	N lptr S lptr=1
	S m2src(1)=line
	S commands("INFO","PSLBOOT")=1
	D INFO^UCGM("PSLBOOT",info)
	Q 
	;
	; ---------------------------------------------------------------------
isGroup(grp,rtn)	;
	Q ((","_($$getList(grp))_",")[(","_rtn_","))
	;
	; ---------------------------------------------------------------------
isCompiler(rtn)	;
	Q $$isGroup("Compiler",rtn)
isData(rtn)	;
	Q $$isGroup("Data",rtn)
isDictionary(rtn)	;
	Q $$isGroup("Dictionary",rtn)
isInsensitive(rtn)	;
	Q $$isGroup("Insensitive",rtn)
isObject(rtn)	;
	Q $$isGroup("Object",rtn)
isUpgrade(rtn)	;
	Q $$isGroup("Upgrade",rtn)
	;
	; ---------------------------------------------------------------------
linkAll()	;
	;
	D linkList($$getComList()) D linkList("_DBAPI,_ZM,_ZOPEN")
	Q 
	;
	; ---------------------------------------------------------------------
linkList(link)	;
	N i
	;
	F i=1:1:$S((link=""):0,1:$L(link,",")) D
	.	N rtn S rtn=$piece(link,",",i)
	.	;   #ACCEPT CR=11441; DATE=11/23/04; PGM=FSCW
	.	;*** Start of code by-passed by compiler
	.	if rtn'=$TEXT(+0) ZLINK rtn
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
needCompile(unit,dir,newCode)	;
	;
	N oldCode
	N nlp N olp
	;
	N proc
	D cmpF2X^UCGM(unit_".psl",.proc)
	I $D(proc)=0 Q ""
	F proc=$order(proc(""),-1):-1 Q:'(proc(proc)="")  K proc(proc)
	D cmpA2A^UCGM(.proc,.newCode)
	;
	I $D(newCode)=0 Q ""
	;
	D cmpF2X^UCGM(unit_".m",.oldCode)
	;
	N omax S omax=$order(oldCode(""),-1)
	;
	F olp=1:1:omax S oldCode(olp)=$$RTCHR^%ZFUNC($translate(oldCode(olp),$CHAR(9)," ")," ")
	S nlp=""
	F  S nlp=$O(newCode(nlp)) Q:nlp=""  S newCode(nlp)=$$RTCHR^%ZFUNC($translate(newCode(nlp),$CHAR(9)," ")," ")
	;
	F omax=omax:-1:1 Q:'(oldCode(omax)="") 
	S nlp=""
	F  S nlp=$order(newCode(nlp),-1) D  Q:(nlp="") 
	.	I (newCode(nlp)="") K newCode(nlp) Q 
	.	I newCode(nlp)=" ;" K newCode(nlp) Q 
	.	S nlp=""
	.	Q 
	;
	S nlp=""
	F olp=1:1:omax D
	.	S nlp=$order(newCode(nlp))
	.	I nlp="" S olp=omax Q 
	.	I oldCode(olp)=newCode(nlp) Q 
	.	I oldCode(olp)["Copyright",newCode(nlp)["Copyright" Q 
	.	S olp=omax S nlp=""
	.	Q 
	Q $order(newCode(nlp))'=""
	;
	; ---------------------------------------------------------------------
prep(vRtnDir,%VN,vGtmLvl,vChrLvl)	;
	;
	D linkAll() ; Ensure an up-to-date image
	;
	; Boot the remainder of the PSL compiler, SQL engine, and DBS kernel
	N comList S comList=$$getList("Compiler")
	N elm
	N unt
	;
	S comList=$S(((","_comList_",")[",TBXDQINT,"):comList,1:$S((comList=""):"TBXDQINT",1:comList_","_"TBXDQINT")) ; force TBXDQINT
	;
	F elm=1:1:$S((comList=""):0,1:$L(comList,",")) D
	.	N co ; compiler options (clean set per call)
	.	;
	.	I '($get(vRtnDir)="") S co("boot","rtndirectory")=vRtnDir
	.	I '($get(vGtmLvl)="") S co("boot","gtmlevel")=vGtmLvl
	.	S co("boot","charsetlevel")=$get(vChrLvl) ; unconditionally!
	.	;
	.	D getBootOptions(.co)
	.	;
	.	S co("boot","restrictionlevel")=-1 ; force restriction level
	.	;
	.	S unt=$piece(comList,",",elm)
	.	I $$getGroup(unt)="Data" Q  ; Data not distributed
	.	;
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap3^"_$T(+0)_""")"
	.	D prepCmp(unt,.co)
	.	D info("prep^UCGMCU()","","prepared "_unt)
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
prepCmp(unit,cco)	;
	N voZT set voZT=$ZT
	N dir
	;
	I '($D(cco("boot","rtndirectory"))#2) S $ZS="-1,"_$ZPOS_","_"%PSL-E-PREPARE,missing output directory" X $ZT
	F dir="CRTNS","MRTNS","PRTNS" I cco("boot","rtndirectory")=$$SCAU^%TRNLNM(dir) S $ZS="-1,"_$ZPOS_","_"%PSE-E-PREPARE,cannot use reserved directory,$SCAU_"_dir X $ZT
	;
	N dst N src N cfe
	;
	I $$isProc^UCXDT25(unit) D  ; DQ Procedure
	.	;
	.	;type String rtn = $$getSrc^UCXDT25( unit, .src(), 2)
	.	N rtn S rtn=$$getSrc^UCXDT25(unit,.src,0)
	.	;
	.	I (rtn="")!($D(src)<10) S $ZS="-1,"_$ZPOS_","_"%PSL-E-PREPARE,DQ procedure source not found" X $ZT
	.	I rtn'=unit S $ZS="-1,"_$ZPOS_","_"%PSL-E-PREPARE,different names,"_unit_"->"_rtn X $ZT
	.	;
	.	D cmpA2A^UCGM(.src,.dst,,,.cco,,.cfe)
	.	;
	.	I +$get(cfe)>0 S $ZS="-1,"_$ZPOS_","_"%PSL-E-PREPARE,compilation failure(s)" X $ZT
	.	Q 
	E  D  ; M Routine
	.	N rIo S rIo=$$vClNew("IO")
	.	N %ZI N %ZR
	.	N ln
	.	;
	.	S %ZI(unit)=""
	.	D INT^%RSEL
	.	I '($D(%ZR(unit))#2) S $ZS="-1,"_$ZPOS_","_"%PSL-E-PREPARE,routine not found" X $ZT
	.	;
	.	S $P(vobj(rIo,1),"|",2)=%ZR(unit)
	.	S $P(vobj(rIo,1),"|",1)=unit_".m"
	.	S $P(vobj(rIo,1),"|",3)="READ"
	.	S $P(vobj(rIo,1),"|",5)=32767
	.	;
	.	D
	..		N voZT set voZT=$ZT
	..		N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap4^"_$T(+0)_""")"
	..		D open^UCIO(rIo,$T(+0),"prepCmp","rIo")
	..		F ln=1:1 S dst(ln)=$$read^UCIO(rIo)
	..		Q 
	.	K vobj(+$G(rIo)) Q 
	;
	I $order(dst(""))="" Q  ; nothing to write
	;
	N rOutFile S rOutFile=$$vClNew("IO")
	S $P(vobj(rOutFile,1),"|",2)=cco("boot","rtndirectory")
	S $P(vobj(rOutFile,1),"|",1)=unit_".m"
	S $P(vobj(rOutFile,1),"|",3)="WRITE/NEWV"
	S $P(vobj(rOutFile,1),"|",5)=32767
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap5^"_$T(+0)_""")"
	;
	D open^UCIO(rOutFile,$T(+0),"prepCmp","rOutFile")
	N lnr S lnr="" N pos
	N txt
	F  S lnr=$order(dst(lnr)) Q:lnr=""  D
	.	S txt=$$RTCHR^%ZFUNC($translate(dst(lnr),$char(9)," ")," ")
	.	I (txt="") Q 
	.	S pos=$F(txt," ")
	.	I pos=0 S txt=txt_" " S pos=$L(txt)+1
	.	I pos<9 S txt=$E(txt,1,pos-2)_$char(9)_$E(dst(lnr),pos,$L(txt))
	.	;
	.	D write^UCIO(rOutFile,txt)
	.	Q 
	D close^UCIO(rOutFile)
	K vobj(+$G(rOutFile)) Q 
	;
	; ---------------------------------------------------------------------
prepProc(vUnit,vRtnDir,%VN,vGtmLvl,vChrLvl)	;
	;
	D linkAll() ; Ensure an up-to-date image
	;
	; Set up for perpare of single unit
	N co ; compiler options
	;
	I '($get(vRtnDir)="") S co("boot","rtndirectory")=vRtnDir
	I '($get(vGtmLvl)="") S co("boot","gtmlevel")=vGtmLvl
	S co("boot","charsetlevel")=$get(vChrLvl) ; unconditionally!
	;
	D getBootOptions(.co)
	;
	S co("boot","restrictionlevel")=-1 ; force restriction level
	;
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap6^"_$T(+0)_""")"
	.	D prepCmp(vUnit,.co)
	.	D info("prepProc^UCGMCU()","","prepared "_vUnit)
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
time(vStr)	; string representation of time
	Q $$vStrTM(vStr)
	; ----------------
	;  #OPTION ResultClass 0
vStrRep(object,p1,p2,p3,p4,qt)	; String.replace
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I p3<0 Q object
	I $L(p1)=1,$L(p2)<2,'p3,'p4,(qt="") Q $translate(object,p1,p2)
	;
	N y S y=0
	F  S y=$$vStrFnd(object,p1,y,p4,qt) Q:y=0  D
	.	S object=$E(object,1,y-$L(p1)-1)_p2_$E(object,y,1048575)
	.	S y=y+$L(p2)-$L(p1)
	.	I p3 S p3=p3-1 I p3=0 S y=$L(object)+1
	.	Q 
	Q object
	; ----------------
	;  #OPTION ResultClass 0
vStrJD(string,mask)	; String.toDate
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I 'string Q ""
	;
	N m N d N y
	;
	S d=$F(mask,"DD")
	S m=$F(mask,"MM")
	I $L(string)=5,$E(string,1,5)?1.5N Q string
	I '(m&d) Q $$^SCAJD(string,mask)
	S m=$E(string,m-2,m-1) S d=$E(string,d-2,d-1)
	I (m?1.N)'&(d?1.N) Q $$^SCAJD(string,mask)
	;
	S y=$F(mask,"YEAR")
	I y S y=$E(string,y-4,y-1)
	E  S y=$F(mask,"YY") I y S y=$E(string,y-2,y-1)
	E  Q $$^SCAJD(string,mask)
	;
	I m<1!(m>12) Q -1
	I y<100 S y=y+$S(y>50:1900,1:2000)
	I (y#4=0)&('(y#100=0)!(y#400=0)) S m=$piece("0,31,60,91,121,152,182,213,244,274,305,335,366",",",m,m+1)
	E  S m=$piece("0,31,59,90,120,151,181,212,243,273,304,334,365",",",m,m+1)
	I $piece((m),",",2)-$piece((m),",",1)<d Q -1
	S d=d+$piece((m),",",1)+((y-1841)*365)
	S d=d+((y-1841)\4)
	S d=d-(((y-1)\100)-18)
	S d=d+(((y-1)\400)-4)
	Q d
	; ----------------
	;  #OPTION ResultClass 0
vRwsLFF(vOid,vDir,vFil,vTyp)	; RowSet.loadFromFile
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vIO S vIO=$$vClNew("IO")
	S $P(vobj(vIO,1),"|",2)=vDir
	S $P(vobj(vIO,1),"|",1)=vFil
	S $P(vobj(vIO,1),"|",3)="READ"
	S $P(vobj(vIO,1),"|",5)=32767
	D open^UCIO(vIO,$T(+0),"vRwsLFF","vIO")
	N vEr
	N vPtr S vPtr=1
	I vTyp=1 D
	.	S vobj(vOid,-3)=$char(9)
	.	S vobj(vOid,-2)=$translate($$^%ZREAD($P(vobj(vIO,1),"|",6),.vEr),$char(9)_$char(10)_$char(13),",")
	.	F vPtr=1:1 S vobj(vOid,vPtr)=$translate($$^%ZREAD($P(vobj(vIO,1),"|",6),.vEr),$char(10)_$char(13)) I vEr Q 
	.	Q 
	K vobj(vOid,vPtr) S vobj(vOid,0)=0
	F  S vPtr=$order(vobj(vOid,vPtr)) Q:vPtr=""  K vobj(vOid,vPtr)
	D close^UCIO(vIO)
	K vobj(+$G(vIO)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ����������������������������������������","abcdefghijklmnopqrstuvwxyz����������������������������������������")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	; ----------------
	;  #OPTION ResultClass 0
vStrTM(object)	; String.toTime
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I 'object Q ""
	;
	I object["P",object<12 S $piece(object,":",1)=$piece(object,":",1)+12
	E  I object["A",$piece(object,":",1)=12 S $piece(object,":",1)=0
	I object["-"!($piece(object,":",1)>23)!($piece(object,":",2)>59)!($piece(object,":",3)>59) Q ""
	Q $piece(object,":",1)*60+$piece(object,":",2)*60+$piece(object,":",3)
	; ----------------
	;  #OPTION ResultClass 0
vStrFnd(object,p1,p2,p3,qt)	; String.find
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I (p1="") Q $SELECT(p2<1:1,1:+p2)
	I p3 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	S p2=$F(object,p1,p2)
	I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
	.	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
	.	Q 
	Q p2
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz����������������������������������������","ABCDEFGHIJKLMNOPQRSTUVWXYZ����������������������������������������")
	;
vClNew(vCls)	;	Create a new object
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls
	Q vOid
	;
vRwsNew(vCol,vDel)	;	new RowSet
	;
	N vOid S vOid=$$vClNew("RowSet")
	S vobj(vOid,0)=0
	S vobj(vOid,-2)=vCol
	S vobj(vOid,-3)=vDel
	Q vOid
	;
vtrap1	;	Error trap
	;
	N vErr S vErr=$ZS
	S $ZS="-1,"_$ZPOS_","_"%PSL-E-CONVERT,,"_vStr_"~"_vMsk X voZT
	Q 
	;
vtrap2	;	Error trap
	;
	N loadExep S loadExep=$ZS
	Q 
	;
vtrap3	;	Error trap
	;
	N vEx S vEx=$ZS
	D info("prep^UCGMCU()",vEx,"failed to prepare "_unt)
	Q 
	;
vtrap4	;	Error trap
	;
	N rEx S rEx=$ZS
	D close^UCIO(rIo)
	I $P(rEx,",",3)'["PSL-E-IO" S $ZS=rEx X voZT
	Q 
	;
vtrap5	;	Error trap
	;
	N rEx S rEx=$ZS
	D close^UCIO(rOutFile)
	S $ZS=rEx X voZT
	Q 
	;
vtrap6	;	Error trap
	;
	N vEx S vEx=$ZS
	D info("prepProc^UCGMCU()",vEx,"failed to prepare "_vUnit)
	Q 
