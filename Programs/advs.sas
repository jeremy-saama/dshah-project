

/**-------------------------------------------------------------------------------------------**
** PROGRAM:    ADVS.SAS 
** CREATED:    December 2019
** PURPOSE:    CREATE ADVS DATASET FROM SDTM VS DATASET
** PROGRAMMER: Deepti Shah
** INPUT:      sdtmlib.vs, adsllib.adsl
** OUTPUT:     adsllib.advs
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**/
/* ----------- SAS University Edition 9.4 ----------- */





/* ----------- Clear work library ----------- */
proc delete data=work._all_;
run;

/* Bring the SDTM VS dataset */

data advs;
	set sdtmlib.vs;
run;

proc sort data=advs out=advs_s;
	by usubjid;
run;

/* Bring the ADSL dataset for subject with baseline flag = true */

data adsl(keep=usubjid saffl trt01pn trt01p TRTSDTM TRTEDTM );
	set adsllib.adsl(where=(saffl="Y"));
run;
proc sort data=adsl out=adsl_s;
	by usubjid;
run;


/* Use Merge to combine VS and ADSL dataset */

data advs_1(drop=domain);
	merge adsl_s advs_s(in=invs);
	by usubjid;

	if invs;
run;

data advs_2;
	set advs_1;

	attrib studyid 	label="Study Identifier" 					
		   usubjid	label="Unique Subject Identifier"		
		   adt		label="Analysis Date"						format=yymmdd10.
		   atm		label="Analysis Time"						format=hhmm.
		   adtm		label="Analysis DateTime"					format=is8601dt.
		   astdt	label="Analysis Start Date"					format=yymmdd10.
		   asttm	label="Analysis Start Time	"				format=hhmm.
		   astdtM	label="Analysis Start DateTime"				format=is8601dt.
		   avisit	label="Analysis Visit"						length=$80
		   avisitN	label="Analysis Visit (N)"		
		   param	label="Parameter"	
		   paramCD  label="Parameter Code"
		   paramN	label="Parameter (N)"						length=3				
		   aval		label="Analysis Value"
		   avalC	label="Analysis Value (C)"
	;

	adt = input(vsdtc,is8601da.);
	atm = input(substr(vsdtc,12),is8601tm.);
	adtm = input(vsdtc,is8601dt.);
	astdt = input(vsdtc,is8601da.);
	asttm = input(substr(vsdtc,12),is8601tm.);
	astdtM = input(vsdtc,is8601dt.);

	avisit = visit;
	avisitN = input(visitnum,2.); 

	/**----------- Analysis Parameter Variables ----------------**/;

		param = vstest;
		paramCD = vstestcd;
		
		select(paramcd);
			when("WEIGHT")	paramN = 1;
			when("HEIGHT")	paramN = 2;
			when("HR")		paramN = 3;
			when("SYSBP")	paramN = 4;
			when("DIABP")	paramN = 5;
			when("O2SAT")	paramN = 6;
			when("RESP")	paramN = 7;
			when("TEMP")	paramN = 8;
		end;
	
		aval = VSSTRESN;
		avalC = VSSTRESC;
		avisit = vstpt;
		avisitN = input(vstptnum,2.); 

run;

proc sort data=advs_2;
	by usubjid vsseq;
run;

/**----------- generate Sequence number by subect and baseline flag -------**/;

data advs_3;
	set advs_2;
	by usubjid;
	
	attrib aseq 	label="Analysis Sequence Number" 			format=best12.
		   ablfl	label="Baseline Record Flag"	;

	aseq + 1 ;
	
	if first.usubjid then aseq=1;
	if vsblfl = "Y" then ablfl = "Y";
	
run;

/**----------- BASE/BASEC ----------------**/;

data advs_bl(keep=usubjid paramcd base basec ablfl);
	set advs_3(where=(ablfl = "Y"));

	attrib BASE 	label="Baseline Value" 		
		   BASEC 	label="Baseline Value (C)" 	;		

	BASE = 	aval;
	BASEC = avalc;
	
run;

/**----------- merge baseline with main dataset ----------------**/;

proc sort data=advs_bl(drop=ablfl);
	by usubjid paramcd;
run;

proc sort data=advs_3;
	by usubjid paramcd;
run;

data advs_4;
	merge advs_3(in=invs) advs_bl;

	by usubjid paramcd;

	if invs;
run;

/* Determine the Change from baseline  */

data advs_5;
	set advs_4;

	attrib CHG label="Change from Baseline"	;

	if paramcd not in( "WEIGHT" "HEIGHT") then do;
		if ablfl = "Y" and (vstpt not in ("STUDY DAY 1" "STUDY DAY 1 -5 min" "STUDY DAY 1 0 min" "STUDY DAY 1 5 min" )) then;
		do;
			CHG = aval-BASE;
		end;
	end;
	
run;


**-------------------------------------------------------------------------------**;
**          Create ADVS dataset with attributes                                **;
**-------------------------------------------------------------------------------**;

proc sql;

	create table adsllib.advs (label='Vital Signs') as
	select  studyid, 
			usubjid,
			aseq,
			saffl,
			trt01p,
			trt01pn,
			vsseq,
			vstestcd,
			vstest,
			vsorres,
			vsorresu,
			vsstresc,
			vsstresn,
			vsblfl,
			visitnum,
			visit,
			vsdtc,
			vstpt,
			vstptnum,
			adt,
			atm,
			adtm,
			astdt,
			asttm,
			astdtm,
			avisit,
			avisitn,
			param,
			paramcd,
			paramn,
			aval,
			avalc,
			base,
			basec,
			chg,
			ablfl
	from advs_5
	;
quit;

proc print;
run;
