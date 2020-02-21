/**-------------------------------------------------------------------------------------------**
** PROGRAM:    TDM.SAS 
** CREATED:    December 2019
** PURPOSE:    Create Demographics Table - 2
** PROGRAMMER: Deepti Shah
** INPUT:      adsllib.adsl
** OUTPUT:     Table 2 (DM_T2.rtf)
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**/
/* ----------- SAS University Edition 9.4 ----------- */



**-------------------------------------------------------------------------------**;
**         Custom Format		                                                 **;
**-------------------------------------------------------------------------------**;

proc format ;
     value $PFormat 
       "1"="n"
	   "2"="Mean"
       "3"="SD" 
       "4"="Median"
	   "5"="Range (Min, Max)";
run;

/* ----------- Clear the work library ----------- */


proc delete data=work._all_;
run;

/* ----------- Get only subject from ADSL with Baseline flag = true  ----------- */

data tdm;
	set adsllib.adsl(where=(saffl="Y"));
run;

/* ----------- Define the Total and All columns  ----------- */

data tdm_1;
	set tdm;
	output;
	trt01pn=3;
	trt01p="Total";
	output;
	trt01pn=4;
	trt01p = "All";
	output;
run;
proc sort data=tdm_1 out=tdm_s;
	by trt01pn trt01p;
run;

**-------------------------------------------------------------------------------**;
**          Calculate Totals   		                                             **;
**-------------------------------------------------------------------------------**;

proc freq data=tdm_s noprint;
	tables trt01pn/list nocum nopercent out=TotPats;
run;
**----------- Assign Totals into Macro Varibles	----------------**;

data _null_;
	set TotPats;
	call symput("cohortTot"||compress(put(trt01pn,1.)),put(count,2.));
run;

**-------------------------------------------------------------------------------**;
**          Derive Race Statistics                                               **;
**-------------------------------------------------------------------------------**;

proc freq data=tdm_s noprint;
	tables trt01pn*race/list out=RaceStat;
run;

/**----------- concatenate required statistics	----------------**/;

data RaceSt (drop=count percent);
	set RaceStat;
	length stat $20;
	stat = strip(put(count,12.)) || " ("||strip(put(percent,4.1))||")";
run;
proc sort data=RaceSt out=RaceSt_s;
	by race;
run;
proc transpose data=RaceSt_s
				out=RaceStat_t(drop=_name_)
				prefix=cohort;
				id trt01pn;
				var stat;
				by race;
run;

/**-----------Generate printable table	----------------**/;

data racestat_t1;
	attrib printord format=best1.
			sortord	format=best1.
			PrintName length=$30;
	;
	set RaceStat_t(rename=(race=printname));

	printord = 3;
	sortord+1;

run;

**-------------------------------------------------------------------------------**;
**          Derive Weight Statistics                                             **;
**-------------------------------------------------------------------------------**;
 

proc means data=tdm_s n mean std min max median noprint  ;
	by trt01pn;
	var weight;
	output out=WtMean(drop=_type_) n= mean= std= min= max= median=/ autoname  ;
run;
	
	

/**----------- Convert variables to character before transpose to avoid log message	----------------**/;

data WeigthM_1(drop=_freq_ weight_n weight_mean weight_stddev weight_min weight_max weight_median);
	set wtmean;
	length wt_range $20 n mean sd median $6;
	n=strip(put(weight_n,8.));
	mean=strip(put(weight_mean,6.1));
	sd=strip(put(weight_stddev,6.1));
	median=strip(put(weight_median,6.1));
	wt_range = "("||strip(put(weight_min,6.))||","||strip(put(weight_max,6.))||")";
run;
proc transpose data=WeigthM_1
				out=wtmean_t
				prefix=Cohort;
				id trt01pn;
				var n mean sd median wt_range;
run;

data wtmean_t1(drop=_name_);
	attrib printord format=best1.
			sortord	format=best1.
			PrintName length=$30 format=PFormat.;
	;
	set wtmean_t;

	printord = 4;
	sortord+1;
	PrintName = put(sortord,1.);
run;

**-------------------------------------------------------------------------------**;
**          Derive Height Stat                                                **;
**-------------------------------------------------------------------------------**;
 

proc means data=tdm_s n mean std min max median noprint  ;
	by trt01pn;
	var height;
	output out=HtMean(drop=_type_) n= mean= std= min= max= median=/ autoname  ;
run;
	

/**----------- Convert all variables to character to avoid log message	----------------**/;

data HeightM_1(drop=_freq_ height_n height_mean height_stddev height_min height_max height_median);
	set htmean;
	length ht_range $20 n mean sd median $6;
	n=strip(put(height_n,8.));
	mean=strip(put(height_mean,6.1));
	sd=strip(put(height_stddev,6.1));
	median=strip(put(height_median,6.1));
	ht_range = "("||strip(put(height_min,6.))||","||strip(put(height_max,6.))||")";
run;
proc transpose data=HeightM_1
				out=htmean_t
				prefix=Cohort;
				id trt01pn;
				var n mean sd median ht_range;
run;

data HeightM_t1(drop=_name_);
	attrib printord format=best1.
			sortord	format=best1.
			PrintName length=$30 format=PFormat.;
	;
	set htmean_t;

	printord = 5;
	sortord+1;
	PrintName = put(sortord,1.);
run;


**-------------------------------------------------------------------------------**;
**          Derive Age Stat                                                      **;
**-------------------------------------------------------------------------------**;
 
proc means data=tdm_s n mean std min max median noprint  ;
	by trt01pn;
	var age;
	output out=AgMean(drop=_type_) n= mean= std= min= max= median=/ autoname  ;
run;


**----------- Convert all variables to character to avoid log message	----------------**;

data agmean1(drop=_freq_ age_n age_mean age_stddev age_min age_max age_median);
	set agmean;
	length range $20 n mean sd median $6;
	n=strip(put(age_n,8.));
	mean=strip(put(age_mean,6.1));
	sd=strip(put(age_stddev,6.1));
	median=strip(put(age_median,6.1));
	range = "("||strip(put(age_min,6.))||","||strip(put(age_max,6.))||")";
run;
proc transpose data=agmean1
				out=agmean_t
				prefix=Cohort;
				id trt01pn;
				var n mean sd median range;
run;

data agmean_t1(drop=_name_);
	attrib printord format=best1.
			sortord	format=best1.
			PrintName length=$30 format=PFormat.
			
	;
	set agmean_t;

	printord = 1;
	sortord+1;
	PrintName = put(sortord,1.);
	
run;


**-------------------------------------------------------------------------------**;
**          Derive Gender Stat                                                   **;
**-------------------------------------------------------------------------------**;
proc freq data=tdm_s noprint;
	tables sex*trt01pn/list out=GenStat;
run;

**----------- concatenate required statistics	----------------**;

data genstat1 (drop=count percent);
	set genstat;
	length stat $20;
	stat = strip(put(count,12.)) || " ("||strip(put(percent,4.1))||")";
run;
proc sort data=genstat1 out=genstat_s;
	by sex;
run;
proc transpose data=Genstat_s
				out=Genstat_t(drop=_name_)
				prefix=cohort;
				id trt01pn;
				var stat;
				by sex;
run;

/**-----------Generate table	----------------**/;

data genstat_t1(drop=sex);
	attrib printord format=best1.
			sortord	format=best1.
			PrintName length=$30;
	;
	set genstat_t;

	printord = 2;
	if Sex = "Male" then sortord = 1;
	else sortord = 2;
	PrintName = sex;
run;

**-------------------------------------------------------------------------------**;
**      Combine all the statistics and generate printable table values           **;
**-------------------------------------------------------------------------------**;

data tdm_final;
	set agmean_t1 genstat_t1 racestat_t1 wtmean_t1 HeightM_t1;
run;

/**----------- Set Parent Header	----------------**/;

data prnt_order;
	printord=1; sortord=0; printname="Age (yrs)    "; output;
	printord=2; sortord=0; printname="Sex n(%)     "; output;
	printord=3; sortord=0; printname="Race n(%)    "; output;
	printord=4; sortord=0; printname="Weight (kg)  "; output;
	printord=5; sortord=0; printname="Height (inch)"; output;
run;

data tdm_header;
	set tdm_final prnt_order;
run;

proc sort data=tdm_header;
	by printord sortord;
run;

/**----------- Set Indents for SubCategory----------------**/;

data tdm_final1;
	set tdm_header;

	by printord sortord;
	length newname $130;

	if first.printord then newname= put(printname,$PFormat.);
	else newname =  "^R'\li220\ '" || put(printname,$PFormat.);
run;

**-------------------------------------------------------------------------------**;
**         RTF SETUP                       								         **;
**-------------------------------------------------------------------------------**;

/**----- RTF SETUP -----**/;

options nodate nonumber orientation=landscape;
ods listing close ;
ods escapechar='^' ;
ods rtf style=TStyleRTF file="&outpath.DM_T2.rtf" ;

/**----- TITLES/FOOTNOTES -----**/;

title1 j=left "&ptitle1" j=right 'Page ^{pageof}' ;
title2 j=left "&ptitle2" j=right "&sysdate9"  ;
title3 j=center "Table 2" ;
title4 j=center "Demographic and Baseline Characteristics" ;
title5 j=left "Study Population: Safety" ;
footnote1 j=left "&llastfoot adsllib.adsl" j=right "&rlastfoot tdm.sas";

**-------------------------------------------------------------------------------**;
**       BEGIN THE REPORT                                                        **;
**-------------------------------------------------------------------------------**;

/**----------- REPORT DEFINITION	----------------**/;
	
proc report data=tdm_final1  missing center center split='|' style(report)=[outputwidth=9.0in];
	
	column printord sortord newname cohort3 ("^S={borderbottomcolor=black borderbottomwidth=2} Evaluable Population"(cohort4 cohort1 cohort2)) ;

	define newname/display "Characteristic" style(header)=[just=left] style(column)=[width=2.0 in];
	define cohort3/display "All Subject| (N=&cohorttot3)" style(column)=[width=1.2 in just=center];
	define cohort4/display "All | (N=&cohorttot4)" style(column)=[width=1.2 in just=center];
	define cohort1/display "Cohort 1 | (N=&cohorttot1)" style(column)=[width=1.2 in just=center];
	define cohort2/display "Cohort 2 | (N=&cohorttot2)" style(column)=[width=1.2 in just=center];
		
	define printord/order noprint;
	define sortord/order noprint;

	compute after printord;
	  line ' ';
	endcomp;
run ;

ods rtf close ;
ods listing ;
