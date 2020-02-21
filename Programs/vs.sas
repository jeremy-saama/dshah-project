/**-------------------------------------------------------------------------------------------**
** PROGRAM:    VS.SAS
** CREATED:    November 2019
** PURPOSE:    Create SDTM - VS dataset from Raw input data.
** PROGRAMMER: Deepti Shah
** INPUT:	   rawlib.vitals, rawlib.vitaltpt
** OUTPUT:	   sdtm.vs
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------*/
/* ----------- SAS University Edition 9.4 ----------- */


/* ----------- Define custom format  ----------- */
proc format;
    value $vsfmtpt 	'STUDY DAY 1' = 1
                 	'STUDY DAY 1 -5 min' = 2
                 	'STUDY DAY 1 0 min' = 3
                 	'STUDY DAY 1 5 min' = 4
                 	'STUDY DAY 1 10 min' = 5
                 	'STUDY DAY 1 15 min' = 6
                 	'STUDY DAY 1 20 min' = 7
                 	'STUDY DAY 1 25 min' = 8
                 	'STUDY DAY 1 30 min' = 9
                 	'STUDY DAY 1 35 min' = 10
                 	'STUDY DAY 1 40 min' = 11
                 	'STUDY DAY 1 45 min' = 12
                 	'STUDY DAY 1 50 min' = 13
                 	'STUDY DAY 1 55 min' = 14
            		'STUDY DAY 1 END OF INFUSION PERIOD #2' = 15
                 	'STUDY DAY 1 1 HOUR AFTER INFUSION PERIOD #2' = 16
                 	'STUDY DAY 2' = 17;
                
run;



data vs (rename=(vsacttm = vstacttm)) ;
	set rawlib.vital;
run;


data vstpt ;
	set rawlib.vitaltpt;
	visit = 'STUDY DAY 1';
run;


/* ----------- Used retain statement to copy value of study date for all the missing study date field for Day 1  ----------- */

data vs (drop= st_day_1 vsdt) ; 
	set vs vstpt;	
	by patid visit;
	
	format vsdt_temp mmddyy10.;
	
	if first.patid then st_day_1 = vsdt;
	retain st_day_1;

	if vsdt ne . then vsdt_temp = vsdt;
	else if vsdt = . then vsdt_temp = st_day_1;
	
run;

 

data vs1;
    length  studyid $8 
            domain $4
            siteid $5
            subjid $6
            usubjid $20
            visit $15
            visitnum $2
            vsblfl $6
            vstpt $80
            vstptnum $50
            vsdtc $50
            ;

    set vs;

    studyid = proto;
    domain = 'VS';
    siteid = put(inv_no,z2.) ;
    subjid = put(patid,z3.);
    usubjid = strip(proto) || '-' || put(inv_no,z2.) || '-' || put(patid,z3.);
    
    vsdtc_temp =  STRIP(PUT(YEAR(vsdt_temp),4.)) || '-' || STRIP(PUT(MONTH(vsdt_temp),Z2.)) || '-' || STRIP(PUT(DAY(vsdt_temp),Z2.)) ;
    
    vsacttm = put(vstacttm,TOD5.);	
	vsdtc = vsdtc_temp || "T" || vsacttm;
	
	
    If visit= "STUDY DAY 1" then visitnum = 1; 
	else If Visit= "STUDY DAY 2" then Visitnum = 2; 
	
	If 	(visit= "STUDY DAY 1" and vstptm="0 min") then vsblfl = "Y";
	
	if visit = "STUDY DAY 1" then vstpt = strip(visit) || " " || strip(vstptm);
	else if visit = "STUDY DAY 2" then vstpt = visit || vstptm;
	
	vstptnum = put(vstpt,vsfmtpt.);
        
run;



data vs2;

    length  vstestcd $10
    		vstest $30
    		vsorresu $20
    		vsstresu $20;
    
    set vs1;
    
	attrib vsorres length=8	format=5.1;
    

	/*Put - Numeric to Character */
	/*Input - Character to Numeric */
	
	
    if heart > .z then 
    do;
	    vstestcd = 'HR';								/* Vital Signs Test Short Name */
	    vstest = 'Heart Rate';							/* Vital Signs Test Name */
	    vsorres = strip(put(round(heart,5.1),best.));	/* Results or Findings in original units */
 	    vsorresu = 'beats/min';							/* Unit of measure */ 	   
 	    vsstresu = "beats/min";							/* Results or Findings in Standard units */
	    output;
    end;

	if sysbp > .z then 
    do;
	    vstestcd = 'SYSBP';
	    vstest = 'Systolic Blood Pressure';
	    vsorres = strip(put(sysbp,5.1));				
	    vsorresu = 'mmHg';	    
	    vsstresu = "mmHg";								/* Results or Findings in Standard units */
	    output;
    end;

    if diabp > .z then 
    do;
	    vstestcd = 'DIABP';
	    vstest = 'Diastolic Blood Pressure';
	    vsorres = strip(put(diabp,5.1));
	    vsorresu = 'mmHg';
	    vsstresu = "mmHg";							/* Results or Findings in Standard units */
	    output;
    end;

    if resp > .z then 
    do;
	    vstestcd = 'RESP';
	    vstest = 'Respiration Rate';
	    vsorres = strip(put(resp,5.1));
	    vsorresu = 'breaths/min';
	    vsstresu = "breaths/min";
	    output;
    end;

    if o2sat > .z then 
    do;
	    vstestcd = 'O2SAT';
	    vstest = 'Oxygen Saturation';
	    vsorres = strip(put(o2sat,3.1));
	    vsorresu = '%';
	    vsstresu = "%";									/* Results or Findings in Standard units */
	    output;
    end;
    
    if temp > .z then 
    do;
	    vstestcd = 'TEMP';
	    vstest = 'Temperature';
	    vsorres = strip(put(temp,5.1));
	    vsorresu = 'F';
	    vsstresu = "C";
	    output;
    end;
    
	if height > .z then 
    do;
	    vstestcd = 'HEIGHT';
	    vstest = 'Height';
	    vsorres = put(strip(height),5.1);   
	    vsorresu = 'in';
	    vsstresu = "cm";								/* Results or Findings in Standard units */
	    output;
    end;
    
		
    if weight > .z then 
    do;
	    vstestcd = 'WEIGHT';
	    vstest = 'Weight';
	    vsorres = put(strip(weight),6.2); 
	    vsorresu = 'kg';
	    vsstresu = "kg";								/* Results or Findings in Standard units */
	    output;
    end;


	
 
run;


/* ----------- For values that are not in standard format, conver them  ----------- */

data vs3;

    length vsstresc $10 vsstresn $5.1 vsstresu $20;
	
    set vs2;
    

    if upcase(vsorresu) = 'F' then do;
        vsstresn = round(5/9 *(input(vsorres,best.) - 32),.1);
        vsstresu = 'C';
    end;
    else if  upcase(vsorresu) = 'IN' then do;
        vsstresn = round(input(vsorres,best.) * 2.54,.1);
        vsstresu = 'cm';
    end;
    else do;
        vsstresn = input(vsorres,best.);
        vsstresu = vsorresu;
    end;

    vsstresc = strip(put(vsstresn,best.));

    keep studyid domain usubjid siteid subjid visit visitnum vstpt vstptm vsblfl vstptnum vstestcd vstest vsorres vsorresu vsstresc vsstresn vsstresu vsdtc;
    
run;


/* ----------- Define baseline flag : Last non missing value prior to the first dose  ----------- */

data vs4;
    set vs3;
    by usubjid;

	If 	visit= "STUDY DAY 1" and ( vstestcd="WEIGHT" or vstestcd="HEIGHT" or vstestcd="RESP" or vstestcd="TEMP" ) then vsblfl = "Y";
	
    vsseq + 1;
    if first.usubjid then vsseq = 1;
run;

 

**-------------------------------------------------------------------------------**;
**          Create Final VS dataset with all the key variable                    **;
**			Use Proc SQL - Create Table statement to create final VS dataset	 **;
**-------------------------------------------------------------------------------**;
  

proc sql;
    create table sdtmlib.vs(label = "Vital Signs") as
        select studyid,
                domain,
                usubjid,
                vsseq,
                vstestcd,
                vstest,
                vsorres,
                vsorresu,
                vsstresc,
                vsstresn,
                vsstresu,
                vsblfl,
                visitnum,
                visit,
                vsdtc,
				vstpt,
				vstptnum
       	from vs4;
quit;

proc print;
run;



