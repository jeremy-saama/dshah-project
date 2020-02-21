

/**-------------------------------------------------------------------------------------------**
** PROGRAM:    TEX.SAS 
** CREATED:    December 2019
** PURPOSE:    Create Exposure Table - 6
** PROGRAMMER: Deepti Shah
** INPUT:      adsllib.adsl
** OUTPUT:     Table 6 (EX_T6.rtf)
** PROTOCOL:   PROD-124
**-------------------------------------------------------------------------------------------**/
/* ----------- SAS University Edition 9.4 ----------- */


proc delete data=work._all_;
run;

**-------------------------------------------------------------------------------**;
**          Calculate Safety population count from adsl                   **;
**-------------------------------------------------------------------------------**;

data tdm;
	set adsllib.adsl(where=(saffl="Y"));
run;
data tdm_1;
	set tdm;
	output;
	trt01pn=3;
	trt01p="Total";
	output;
run;
proc sort data=tdm_1 out=tdm_s;
	by trt01pn trt01p;
run;

/**----------- calculate the pop count ----------------**/;

proc freq data=tdm_s noprint;
	tables trt01pn/list nocum nopercent out=TotPats;
run;

/**----------- Assign Totals into Macro Varibles	----------------**/;

data _null_;
	set TotPats;
	call symputx("cohortTot"||compress(put(trt01pn,1.)),put(count,2.));
run;

**-------------------------------------------------------------------------------**;
**         Bring in EXPOSURE analysis data                    **;
**-------------------------------------------------------------------------------**;

data ex;
	set adsllib.adex;
run;

**-------------------------------------------------------------------------------**;
**	  Derive Totals  for Bag and Bottle         **;
**-------------------------------------------------------------------------------**;

proc freq data=ex noprint;
	tables excat/list nocum nopercent out=total_mode(drop=percent);
run;

/**----------- Assign totals in macro variables ----------------**/;

data _null_;
	set total_mode;
	call symputx(compress(excat)||"N",put(count,2.));
run;

/**----------- Check Mode Totals ----------------**/;

**-------------------------------------------------------------------------------**;
**       Segregate weight-based amount administered to a new dataset      **;
**-------------------------------------------------------------------------------**;

data wtex;
	set ex(where=(paramcd="DOSEWT"));
run;


**-------------------------------------------------------------------------------**;
** 		Derive Total Statistics for Bag and Bottle                             **;
**-------------------------------------------------------------------------------**;
proc sort data=ex out=ex_s;
	by excat;
run;

/**----------- Stat for Bag and Bottle based for mg----------------**/;

proc means data=ex_s noprint;
	var exdose;
	by excat;
	output out=mg_total(drop=_type_ _freq_) n=N mean=Mean Std=SD median=Median min=Min max=Max;
run;

data mg_total;
	set mg_total;
	format range $40.;
	RANGE = "(" || put(min, best3.0) || "," || put(max, best3.0) || ")";
run;

/**----------- Transpose ----------------**/;

proc transpose data=mg_total 
			   out=mg_total_t;
			   var n mean sd median range;
			   id excat;
run;

data mg_total_t;
	set mg_total_t;
	printord=1;
	sortord=1;
run;

/**----------- Stat for Bag and Bottle based for mg/kg----------------**/;

proc sort data=wtex out=wtex_s;
	by excat;
run;

proc means data=wtex_s noprint;
	var aval;
	by excat;
	output out=wt_total(drop=_type_ _freq_) n=N mean=Mean Std=SD median=Median min=Min max=Max;
run;

data wt_total;
	set wt_total;
	format range $40.;
	RANGE = "(" || put(min, best2.0) || "," || put(max, best2.0) || ")";
run;

/**----------- Transpose ----------------**/;

proc transpose data=wt_total
			   out=wt_total_t;
			   var n mean sd median range;
			   id excat;
run;

data wt_total_t;
	set wt_total_t;
	printord=2;
	sortord=1;
run;

**-------------------------------------------------------------------------------**;
** 		Derive Bag Config Statistics by Infusion Period 1 & 2                   **;
**-------------------------------------------------------------------------------**;
data bagconfig;
	set ex(where=(EXCAT="BAG"));
run;

/**----------- Assign totals in macro variables ----------------**/;

proc freq data=bagconfig noprint;
	tables epoch/list nocum nopercent out=IP_Bag(drop=percent);
run;

data _null_;
	set IP_Bag;
	call symputx("BagIP"||substr(epoch,18),put(count,2.));
run;

/**----------- Check Totals ----------------**/;


**----------- Stat for Infusion Period 1 & 2 based for mg----------------**;

proc sort data=bagconfig out=bagconfig_s;
	by epoch;
run;

proc means data=bagconfig_s  noprint;
	var exdose;
	by epoch;
	output out=mg_bag(drop=_type_ _freq_) n=N mean=Mean Std=SD median=Median min=Min max=Max;
run;

data mg_bag;
	set mg_bag;
	format range $40.;
	RANGE = "(" || put(min, best2.0) || "," || put(max, best2.0) || ")";
run;


/**----------- Transpose ----------------**/;

proc transpose data=mg_bag 
			   out=mg_bag_t;
			   var n mean sd median range;
			   id epoch;
run;

/**----------- Stat for Infusion Period 1 & 2 for mg/kg----------------**/;

proc sort data=wtex out=wtex_s1;
	by epoch;
run;

proc means data=wtex_s1 noprint;
	var aval;
	by epoch;
	output out=wt_bag(drop=_type_ _freq_) n=N mean=Mean Std=SD median=Median min=Min max=Max;
run;

data wt_bag;
	set wt_bag;
	format range $40.;
	RANGE = "(" || put(min, best2.0) || "," || put(max, best2.0) || ")";
run;

/**----------- Transpose ----------------**/;

proc transpose data=wt_bag
			   out=wt_bag_t;
			   var n mean sd median range;
			   id epoch;
run;

**-------------------------------------------------------------------------------**;
** 		Derive Bottle Config Statistics by Infusion Period 1 & 2                   **;
**-------------------------------------------------------------------------------**;
data btlconfig;
	set ex(where=(EXCAT="BOTTLE"));
run;

/**----------- Assign totals in macro variables ----------------**/;

proc freq data=btlconfig noprint;
	tables epoch/list nocum nopercent out=IP_Btl(drop=percent);
run;

data _null_;
	set IP_Btl;
	call symputx("BtlIP"||substr(epoch,18),put(count,2.));
run;

/**----------- Check Totals ----------------**/;

%put &=btlip1;
%put &=btlip2;

/**----------- Stat for Infusion Period 1 & 2 based for mg----------------**/;

proc sort data=btlconfig out=btlconfig_s;
	by epoch;
run;

proc means data=btlconfig_s  noprint;
	var exdose;
	by epoch;
	output out=mg_btl(drop=_type_ _freq_) n=N mean=Mean Std=SD median=Median min=Min max=Max;
run;

data mg_btl;
	set mg_btl;
	format range $40.;
	RANGE = "(" || put(min, best3.0) || "," || put(max, best3.0) || ")";
run;

/**----------- Transpose ----------------**/;

proc transpose data=mg_btl 
			   out=mg_btl_t;
			   var n mean sd median range;
			   id epoch;
run;

/**----------- Stat for Infusion Period 1 & 2 for mg/kg----------------**/;

proc sort data=wtex out=wtex_s2;
	by epoch;
run;

proc means data=wtex_s2 noprint;
	var aval;
	by epoch;
	output out=wt_btl(drop=_type_ _freq_) n=N mean=Mean Std=SD median=Median min=Min max=Max;
run;

data wt_btl;
	set wt_btl;
	format range $40.;
	RANGE = "(" || put(min, best3.0) || "," || put(max, best3.0) || ")";
run;

/**----------- Transpose ----------------**/;

proc transpose data=wt_btl
			   out=wt_btl_t;
			   var n mean sd median range;
			   id epoch;
run;

**-------------------------------------------------------------------------------**;
**         Combine Statistics for Amount and Weight administration               **;
**-------------------------------------------------------------------------------**;

/**----------- append Total stat ----------------**/;

data tex;
	set mg_total_t wt_total_t;
run;

/**----------- append Bag config ----------------**/;
data tex1;
	set mg_bag_t wt_bag_t;
run;

/**----------- append bottle config ----------------**/;
data tex2;
	set mg_btl_t wt_btl_t;
run;

**-------------------------------------------------------------------------------**;
**          Merge all statistics                   **;
**-------------------------------------------------------------------------------**;

data tex_fin;
	set tex;
	set tex1;
	set tex2(rename=(infusion_period__1 = BtlIP1 infusion_period__2 = BtlIP2));
run;

/**----------- Set Parent Header	----------------**/;

data dummy;
	printord=1; sortord=0; printname="Amount Administered (mg)    					"; output;
	printord=2; sortord=0; printname="Weight-based Amount Administered (mg/kg)      "; output;
run;

data tex_header;
	set tex_fin dummy;
run;

proc sort data=tex_header;
	by printord sortord;
run;

/**----------- Set Indents for SubCategory----------------**/;

data tex_final1;
	set tex_header;

	by printord sortord;
	length newname $130;

	if first.printord then newname= printname;
	else newname =  "^R'\li220\ '" || propcase(_name_);
run;

**-------------------------------------------------------------------------------**;
**         RTF SETUP                       								         **;
**-------------------------------------------------------------------------------**;

/**----- RTF SETUP -----**/;

options nodate nonumber orientation=landscape;
ods listing close ;
ods escapechar='^' ;
ods rtf style=TStyleRTF file="&outpath.EX_T6.rtf" ;

/**----- TITLES/FOOTNOTES -----**/;

title1 j=left "&ptitle1" j=right 'Page ^{pageof}' ;
title2 j=left "&ptitle2" j=right "&sysdate9"  ;
title3 j=center "Table 6" ;
title4 j=center "Exposure to PROD" ;
title5 j=left "Study Population: Safety (N=&cohortTot3)" ;
footnote1 j=left "&llastfoot adsllib.adex" j=right "&rlastfoot tex.sas";

**-------------------------------------------------------------------------------**;
**       BEGIN THE REPORT                                                        **;
**-------------------------------------------------------------------------------**;

/**----------- REPORT DEFINITION	----------------**/;
	
proc report data=tex_final1  missing center split='|' style(report)=[outputwidth=9.0in];
	
	column printord sortord newname ("^S={borderbottomcolor=black borderbottomwidth=2} Total"(Bag Bottle)) 
									("^S={borderbottomcolor=black borderbottomwidth=2} Bag Configuration"(infusion_period__1 infusion_period__2)) 
									("^S={borderbottomcolor=black borderbottomwidth=2} Bottle Configuration"(btlip1 btlip2));

	define newname/display "Parameter" style(header)=[just=left] ;
	define Bag/display "Bag| (N=&bagn)" style(column)=[just=center];
	define Bottle/display "Bottle | (N=&bottlen)" style(column)=[just=center];
	define infusion_period__1/display "Infusion|Period 1 | (N=&bagip1)" style(column)=[just=center];
	define infusion_period__2/display "Infusion|Period 2 | (N=&bagip2)" style(column)=[just=center];
	define btlip1/display "Infusion|Period 1 | (N=&btlip1)" style(column)=[just=center];
	define btlip2/display "Infusion|Period 2 | (N=&btlip2)" style(column)=[just=center];

	define printord/order noprint;
	define sortord/order noprint;

	compute after printord;
	  line ' ';
	endcomp;
run ;

ods rtf close ;
ods listing ;
title;
footnote;
