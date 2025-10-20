********************************************************************************
/*do-file: replication_supp_results
********************************************************************************
********************************************************************************
Project title: AUH_argentina			
Database used: INDEC - Encuesta permanente de hogares (EPH)
Author: S. Carrère	
********************************************************************************
********************************************************************************
Description: code for replication of additional results and robustness tests 
			 of the paper
 
Date: 20/11/2024	created
Date: 20/10/2025	modified
*/
********************************************************************************


/*
****************
**** Readme ****
****************

**Replication of the results:
*****************************

You can obtain the main results of the article from the ready-to-use database "MDD_base.dta".

Household selection for the main results: 
 -households with children in the first year (we do not consider here households with disabled members)
 -households interviewed at least three times
 -the poorest households located in the first three IPCF deciles
 -households between the pre/post AUH implementation period are excluded

To replicate the supplementary results, you can download the quarterly data files from the INDEC website and run the do-files to recreate the complete database.


**What you need:
****************

Several packages are needed for the analysis. You may need to install these packages:
 -diff- (Villa, 2016): for the Matched Diff-in-diff (MDD) analysis
 -reghdfe (Correia, S.): for the event study analysis
 -drdid- and -csdid- (Rios-Avila et al., 2021): for the Doubly Robust (DR) Diff-in-diff analysis
 -psmatch2- (Leuven and Sianesi, 2003): for the matching quality figures and tables 


**Note:
*******
/!\ results from the csdid command were produced under the 1.71 package version. Since this package is continuously
    updated, more recent package version could slighly modify the output. The 'ado' folder contains the 1.71 version of  
    the -drdid- and -csdid- package used in the paper. If you want to replicate correctly these results, you need to copy
    the 'c' and 'd' folder into you ado directory file, usually located in "C:\ado\plus\".

*/

********************************************************************************

*Set the visual style for figures
	global plotregion plotregion(margin(b=0 t=2) color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 
	global graphregion graphregion(margin(l=0 r=4 b=-2 t=-1) color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))
	global ylabel 	ylabel(, ang(hor) labsize(medsmall))
	global xlabel 	xlabel(,  labsize(medsmall))
	global scheme scheme(white_tableau)


********************************************************************************
	

*********************************
**** Supplementary Materials ****
*********************************

use "$AUH_argentina/data/MDD_base.dta", clear


**A) Descriptive statistics
***************************
**#
**Figure SA2 : Evolution of income structure by AUH eligibility status
**********************************************************************

*mean income (a)
est clear
qui reg mean_IPCF_US hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 & hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1 &  DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 , clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot,recast(connected) recastci(rarea) title("") name(evol_mean_income_bw, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall))  ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(100 "100" 150 "150" 200 "200" 250 "250" 300 "300" 350 "350" 400 "400", gmin gmax) ytitle("Monthly income per capita ({c S|}US PPP)", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xtitle ("")  xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) ///	
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 

*graph export "$AUH_argentina/results/graphs/evol_mean_income.emf", replace 

*labor income with pension (b)
est clear
qui reg m_income_lab_pen_full_prop hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 & hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7& ano_panel>=2 & auh_implementation==0 & nb_dupli>=3  , clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot,recast(connected) recastci(rarea) title("") name(evol_share_labor_bw, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall))  ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(0.5 "50" 0.6 "60" 0.70 "70" 0.80 "80" 0.90 "90" 1 "100", gmin gmax) ytitle("% of household income from labor", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xtitle ("")  xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) ///	
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 

*graph export "$AUH_argentina/results/graphs/evol_share_labor.emf", replace 

*income from friends/family (c)
est clear
qui reg m_V12_M_full_prop hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 & hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1 &  DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 , clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot,recast(connected) recastci(rarea) title("") name(evol_share_friends_bw, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall))  ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20", gmin gmax) ytitle("% of household income from friends/family", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xtitle ("")  xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) ///	
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 

*graph export "$AUH_argentina/results/graphs/evol_share_friends.emf", replace 

*income from the state/church (d)
est clear
qui reg m_V5_M_full_prop hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 & hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1 &  DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 , clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot,recast(connected) recastci(rarea) title("") name(evol_share_subs_bw, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall))  ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(0 "0" 0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20", gmin gmax) ytitle("% of household income from the state, church, etc. ", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xtitle ("")  xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) ///	
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 

*graph export "$AUH_argentina/results/graphs/evol_share_subs.emf", replace 



**B) Additional results
***********************
**#
**Table SB1: MDD results in Equivalised Income
**********************************************

cd "$AUH_argentina/results/tables"

//EQ CV
diff CV_eq_inc [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_eq_results.doc, replace word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//EQ CV-D
diff CV_eq_inc [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_eq_inc_an1>=m_eq_inc_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_eq_results.doc, append word ctitle (CV-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//EQ CV-U
diff CV_eq_inc [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_eq_inc_an1<m_eq_inc_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_eq_results.doc, append word ctitle (CV-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//EQ SD APC
diff sd_arcper_change_eq [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_eq_results.doc, append word ctitle (SD Arc) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//EQ SD APC-D
diff sd_arcper_change_eq [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_eq_inc_an1>=m_eq_inc_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_eq_results.doc, append word ctitle (SD Arc-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//EQ SD APC-U
diff sd_arcper_change_eq [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_eq_inc_an1<m_eq_inc_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single imput_hh_year educ_hog_seci educ_hog_pric educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_eq_results.doc, append word ctitle (SD Arc-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 


**#
**Table SB2: MDD results - SD and SD Equivalised Income
*******************************************************

//SD
diff sd_IPCF_US [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric     educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   imput_hh_year reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sd_app.doc, replace word ctitle (SD) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD-D
diff sd_IPCF_US [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sd_app.doc, append word ctitle (SDd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD-U
diff sd_IPCF_US [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric     educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   imput_hh_year reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sd_app.doc, append word ctitle (SDu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 


//EQ SD
diff sd_IPCF_US_eq [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric     educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   imput_hh_year reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sd_app.doc, append word ctitle (EQ SD) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//EQ SD-D
diff sd_IPCF_US_eq [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_eq_inc_an1>=m_eq_inc_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sd_app.doc, append word ctitle (EQ SDd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//EQ SD-U
diff sd_IPCF_US_eq [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_eq_inc_an1<m_eq_inc_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric     educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   imput_hh_year reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sd_app.doc, append word ctitle (EQ SDu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 



**C) Mechanisms
***************

cd "$AUH_argentina/results/tables"

**#
**Table SC1: MDD results - Labor supply and income volatility
*************************************************************

diff CV_inc_lab [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_mechanisms.doc, replace word ctitle (CV lab) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*	
diff sd_arcper_change_inc_lab [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_mechanisms.doc, append word ctitle (SD-APC lab) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*	
diff mean_period_tot_wk_h [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_mechanisms.doc, append word ctitle (Hours worked) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*
diff mean_period_tot_wk_h_head [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12    imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_mechanisms.doc, append word ctitle (Hours worked - Head) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*
diff mean_period_tot_wk_h_conj [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12    imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_mechanisms.doc, append word ctitle (Hours worked - Conj) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*
diff mean_tot_worker [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_mechanisms.doc, append word ctitle (Number workers) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 


**#
**Table SC2: MDD results - Household financial behavior
*******************************************************

*goods (food, clothes, etc.) from church, state
diff m_v6 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_vulnerability.doc, replace word ctitle (In-kind donations (church, state, association)) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*goods (food, clothes, etc.) from other people 
diff m_v7 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60  hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_vulnerability.doc, append word ctitle (In-kind donations (family, friends, neighbors)) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*money from other people
diff m_v12 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60  hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_vulnerability.doc, append word ctitle (Monetary donations (friends, neighbors)) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*use savings
diff m_v13 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60  hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_vulnerability.doc, append word ctitle (Drawing on savings) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*informal loan
diff m_v14 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60  hh_fem married single educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_vulnerability.doc, append word ctitle (Informal loans) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*sell goods
diff m_v17 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60  hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_vulnerability.doc, append word ctitle (Sales of assets) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*Formal loan
diff m_v15 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60  hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12    imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_vulnerability.doc, append word ctitle (Formal loans) dec(4) keep(_diff after hog_inform_par_all_full_an1) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
*Card
diff m_v16 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 trim1 trim2 trim3 t_2-t_5 t_9-t_12   imput_hh_year) clus(AGLOMERADO)
*outreg2 using tb_vulnerability.doc, append word ctitle (Credit card, deffered payment) dec(4) keep(_diff after hog_inform_par_all_full_an1) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 




**D) Robustness tests
*********************

cd "$AUH_argentina/results/tables"

**#
**Table SD1: MDD results with false interventions without controls
******************************************************************

//PT
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff mean_poor_period [pw=final_weights] if hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_1.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff mean_poor_period [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_1.doc, append word ctitle (Poverty trends) dec(4) keep(_diff) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff mean_poor_period [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_1.doc, append word ctitle (Poverty trends) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

//CV
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_2.doc, replace word ctitle (CV) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_2.doc, append word ctitle (CV) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_2.doc, append word ctitle (CV) dec(4) keep(_diff ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

//CV-D
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_3.doc, replace word ctitle (CV-down) dec(4) keep(_diff ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_3.doc, append word ctitle (CV-down) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_3.doc, append word ctitle (CV-down) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

//CV-U
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_4.doc, replace word ctitle (CV-up) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff )

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_4.doc, append word ctitle (CV-up) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_4.doc, append word ctitle (CV-up) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 


//SDAPC
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_5.doc, replace word ctitle (SD APC) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_5.doc, append word ctitle (SD APC) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_5.doc, append word ctitle (SD APC) dec(4) keep(_diff ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

//SDAPC-D
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_6.doc, replace word ctitle (SD APC-down) dec(4) keep(_diff ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_6.doc, append word ctitle (SD APC-down) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_6.doc, append word ctitle (SD APC-down) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

//SDAPC-U
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_7.doc, replace word ctitle (SD APC-up) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff )

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_7.doc, append word ctitle (SD APC-up) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo)  clus(AGLOMERADO)
*outreg2 using placebo_nocontrols_7.doc, append word ctitle (SD APC-up) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

**#
**Table SD2: MDD results with false interventions with controls
***************************************************************

//PT
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff mean_poor_period [pw=final_weights] if hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single trim2 trim3 trim4 age30 age60 hh_fem married educ_hog_pric  imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5  t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_1.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff mean_poor_period [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric    imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5  t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_1.doc, append word ctitle (Poverty trends) dec(4) keep(_diff) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff mean_poor_period [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric    imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_1.doc, append word ctitle (Poverty trends) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

//CV
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single trim2 trim3 trim4 age30 age60 hh_fem married  imput_hh_year  educ_hog_pric    educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5  t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_2.doc, replace word ctitle (CV) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single trim2 trim3 trim4 age30 age60 hh_fem married  imput_hh_year  educ_hog_pric    educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5  t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_2.doc, append word ctitle (CV) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single trim2 trim3 trim4 age30 age60 hh_fem married  imput_hh_year  educ_hog_pric    educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5  t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_2.doc, append word ctitle (CV) dec(4) keep(_diff ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

//CV-D
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_3.doc, replace word ctitle (CV-down) dec(4) keep(_diff ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_3.doc, append word ctitle (CV-down) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_3.doc, append word ctitle (CV-down) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

//CV-U
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_4.doc, replace word ctitle (CV-up) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff )

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_4.doc, append word ctitle (CV-up) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff CV_IPCF [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_4.doc, append word ctitle (CV-up) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 


//SDAPC
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single trim2 trim3 trim4 age30 age60 hh_fem married  imput_hh_year  educ_hog_pric    educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5  t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_5.doc, replace word ctitle (SD APC) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single trim2 trim3 trim4 age30 age60 hh_fem married  imput_hh_year  educ_hog_pric    educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5  t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_5.doc, append word ctitle (SD APC) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0  & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single trim2 trim3 trim4 age30 age60 hh_fem married  imput_hh_year  educ_hog_pric    educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5  t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_5.doc, append word ctitle (SD APC) dec(4) keep(_diff ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff) 

//SDAPC-D
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_6.doc, replace word ctitle (SD APC-down) dec(4) keep(_diff ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff)

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_6.doc, append word ctitle (SD APC-down) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_6.doc, append word ctitle (SD APC-down) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

//SDAPC-U
drop after_placebo
gen after_placebo = 0 //intervention in 2006-2007
replace after_placebo = 1 if ano_panel>=4 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_7.doc, replace word ctitle (SD APC-up) dec(4) keep(_diff  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff )

drop after_placebo
gen after_placebo = 0 //intervention in 2007-2008
replace after_placebo = 1 if ano_panel>=5 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_7.doc, append word ctitle (SD APC-up) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

drop after_placebo
gen after_placebo = 0 //intervention in 2008-2009
replace after_placebo = 1 if ano_panel>=6 & after==0
diff sd_arcper_change [pw=final_weights] if _support==1 & hog_obs_jefe==1 & hog_child_year_an1==1 & after==0 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0  ,  t(hog_inform_par_all_full_an1) p(after_placebo) cov( reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric   educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12) clus(AGLOMERADO)
*outreg2 using placebo_controls_7.doc, append word ctitle (SD APC-up) dec(4) keep(_diff   ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff ) 

**#
**Table SD3: Diff-in-diff robustness - Alternative specifications 
*****************************************************************

//Attrition correction

********************************************************************************
**Step 1: dataset creations tables

cd "$AUH_argentina/data"

//Load dataset
use "AUH_base_reduced.dta", clear

//Kernel weights calculation (must be calculated once - this calculation may take some times)
keep if hog_obs_jefe==1 & disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3
diff mean_poor_period [pw=PONDERA_c], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
//Kernel weights corrected for attrition
gen final_weights_c = PONDERA_c * _weights_rcs	
//Save the database with kernel weights * survey weights corrected for attrition
save "$AUH_argentina/data/alt_sample/matching_attrition.dta", replace

********************************************************************************
**Step 2: results tables

use "$AUH_argentina/data/alt_sample/matching_attrition.dta", clear

cd "$AUH_argentina/results/tables"

//PT
diff mean_poor_period_511 [pw=final_weights_c] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_attr_results.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV
diff CV_IPCF [pw=final_weights_c] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_attr_results.doc, append word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D
diff CV_IPCF [pw=final_weights_c] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_attr_results.doc, append word ctitle (CV-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U
diff CV_IPCF [pw=final_weights_c] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_attr_results.doc, append word ctitle (CV-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC
diff sd_arcper_change [pw=final_weights_c] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_attr_results.doc, append word ctitle (SD Arc) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-D
diff sd_arcper_change [pw=final_weights_c] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_attr_results.doc, append word ctitle (SD Arc-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-U
diff sd_arcper_change [pw=final_weights_c] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_attr_results.doc, append word ctitle (SD Arc-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

	
//Kernel weights only
use "$AUH_argentina/data/MDD_base", clear

//PT
diff mean_poor_period_511 [pw=_weights_rcs] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric  imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_Kernel_results.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV
diff CV_IPCF [pw=_weights_rcs] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_Kernel_results.doc, append word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D
diff CV_IPCF [pw=_weights_rcs] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_Kernel_results.doc, append word ctitle (CV-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U
diff CV_IPCF [pw=_weights_rcs] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_Kernel_results.doc, append word ctitle (CV-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC
diff sd_arcper_change [pw=_weights_rcs] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_Kernel_results.doc, append word ctitle (SD Arc) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-D
diff sd_arcper_change [pw=_weights_rcs] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_Kernel_results.doc, append word ctitle (SD Arc-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-U
diff sd_arcper_change [pw=_weights_rcs] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_Kernel_results.doc, append word ctitle (SD Arc-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 
	


//No matching	
	
//PT
diff mean_poor_period_511 [pw=PONDERA] if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_DD_results.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV
diff CV_IPCF [pw=PONDERA] if  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_DD_results.doc, append word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D
diff CV_IPCF [pw=PONDERA] if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_DD_results.doc, append word ctitle (CV-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U
diff CV_IPCF [pw=PONDERA] if  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_DD_results.doc, append word ctitle (CV-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC
diff sd_arcper_change [pw=PONDERA] if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_DD_results.doc, append word ctitle (SD Arc) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-D
diff sd_arcper_change [pw=PONDERA] if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_DD_results.doc, append word ctitle (SD Arc-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-U
diff sd_arcper_change [pw=PONDERA] if  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_DD_results.doc, append word ctitle (SD Arc-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 


	
**#
**Table SD4: MDD results - Sample size: income deciles
******************************************************

********************************************************************************
**Step 1: kernel weights calculation and dataset creation (must be calculated once - it may take some times)

cd "$AUH_argentina/data"

//Load dataset
use "AUH_base_reduced.dta", clear

//Decile 2
keep if disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=2 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
gen final_weights = PONDERA*_weights_rcs
save "$AUH_argentina/data/alt_sample/matching_DECCFR2.dta", replace

//Decile 3
use "AUH_base_reduced.dta", clear
keep if disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
gen final_weights = PONDERA*_weights_rcs
save "$AUH_argentina/data/alt_sample/matching_DECCFR3.dta", replace

//Decile 4
use "AUH_base_reduced.dta", clear
keep if disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=4 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
gen final_weights = PONDERA*_weights_rcs
save "$AUH_argentina/data/alt_sample/matching_DECCFR4.dta", replace

//Decile 5
use "AUH_base_reduced.dta", clear
keep if disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=5 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
gen final_weights = PONDERA*_weights_rcs
save "$AUH_argentina/data/alt_sample/matching_DECCFR5.dta", replace


********************************************************************************
**Step 2: results tables

cd "$AUH_argentina/results/tables"

//PT

*D2
use "$AUH_argentina/data/alt_sample/matching_DECCFR2.dta",clear
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=2 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_PT_results.doc, replace word ctitle (D2) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D3
use "$AUH_argentina/data/alt_sample/matching_DECCFR3.dta",clear
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_PT_results.doc, append word ctitle (D3) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D4
use "$AUH_argentina/data/alt_sample/matching_DECCFR4.dta",clear
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=4 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_PT_results.doc, append word ctitle (D4) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D5
use "$AUH_argentina/data/alt_sample/matching_DECCFR5.dta",clear
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=5 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_PT_results.doc, append word ctitle (D5) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 


//CV

*D2
use "$AUH_argentina/data/alt_sample/matching_DECCFR2.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=2 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CV_results.doc, replace word ctitle (D2) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D3
use "$AUH_argentina/data/alt_sample/matching_DECCFR3.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CV_results.doc, append word ctitle (D3) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D4
use "$AUH_argentina/data/alt_sample/matching_DECCFR4.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=4 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CV_results.doc, append word ctitle (D4) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D5
use "$AUH_argentina/data/alt_sample/matching_DECCFR5.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=5 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CV_results.doc, append word ctitle (D5) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D

*D2
use "$AUH_argentina/data/alt_sample/matching_DECCFR2.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=2 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CVd_results.doc, replace word ctitle (D2) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D3
use "$AUH_argentina/data/alt_sample/matching_DECCFR3.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CVd_results.doc, append word ctitle (D3) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D4
use "$AUH_argentina/data/alt_sample/matching_DECCFR4.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=4 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CVd_results.doc, append word ctitle (D4) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D5
use "$AUH_argentina/data/alt_sample/matching_DECCFR5.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=5 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CVd_results.doc, append word ctitle (D5) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U

*D2
use "$AUH_argentina/data/alt_sample/matching_DECCFR2.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=2 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric    imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CVu_results.doc, replace word ctitle (D2) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D3
use "$AUH_argentina/data/alt_sample/matching_DECCFR3.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric    imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CVu_results.doc, append word ctitle (D3) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D4
use "$AUH_argentina/data/alt_sample/matching_DECCFR4.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=4 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric    imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CVu_results.doc, append word ctitle (D4) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D5
use "$AUH_argentina/data/alt_sample/matching_DECCFR5.dta",clear
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=5 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric    imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_CVu_results.doc, append word ctitle (D5) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 



//SDAPC

*D2
use "$AUH_argentina/data/alt_sample/matching_DECCFR2.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=2 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPC_results.doc, replace word ctitle (D2) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D3
use "$AUH_argentina/data/alt_sample/matching_DECCFR3.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPC_results.doc, append word ctitle (D3) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D4
use "$AUH_argentina/data/alt_sample/matching_DECCFR4.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=4 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPC_results.doc, append word ctitle (D4) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D5
use "$AUH_argentina/data/alt_sample/matching_DECCFR5.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=5 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPC_results.doc, append word ctitle (D5) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//SDAPC-D

*D2
use "$AUH_argentina/data/alt_sample/matching_DECCFR2.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=2 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPCd_results.doc, replace word ctitle (D2) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D3
use "$AUH_argentina/data/alt_sample/matching_DECCFR3.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPCd_results.doc, append word ctitle (D3) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D4
use "$AUH_argentina/data/alt_sample/matching_DECCFR4.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=4 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPCd_results.doc, append word ctitle (D4) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D5
use "$AUH_argentina/data/alt_sample/matching_DECCFR5.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=5 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPCd_results.doc, append word ctitle (D5) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//SDAPC-U

*D2
use "$AUH_argentina/data/alt_sample/matching_DECCFR2.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=2 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPCu_results.doc, replace word ctitle (D2) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D3
use "$AUH_argentina/data/alt_sample/matching_DECCFR3.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPCu_results.doc, append word ctitle (D3) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D4
use "$AUH_argentina/data/alt_sample/matching_DECCFR4.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=4 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPCu_results.doc, append word ctitle (D4) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 
*D5
use "$AUH_argentina/data/alt_sample/matching_DECCFR5.dta",clear
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=5 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_decile_SDAPCu_results.doc, append word ctitle (D5) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 


**#
**Table SD5: MDD results - Sample size: eligibility
***************************************************


********************************************************************************
**Step 1: kernel weights calculation and dataset creation (must be calculated once - it may take some times)

cd "$AUH_argentina/data"

//Load dataset
use "AUH_base_reduced.dta", clear

//Full inform
keep if hog_obs_jefe==1 & disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 & hog_inform_par_all_full_an1==hog_inform_par_all_full_an2 & hog_child_year_an1==hog_child_year_an2
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
gen final_weights = PONDERA*_weights_rcs
save "$AUH_argentina/data/alt_sample/matching_full_inform.dta", replace

//Time
use "AUH_base_reduced.dta", clear
keep if hog_obs_jefe==1 & disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2  & auh_implementation==0 & nb_dupli>=3 & ano_panel<=10
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
gen final_weights = PONDERA*_weights_rcs
save "$AUH_argentina/data/alt_sample/matching_time.dta", replace

//Incomplete follow-up
use "AUH_base_reduced.dta", clear
keep if hog_obs_jefe==1 & disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=2
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
gen final_weights = PONDERA*_weights_rcs	
save "$AUH_argentina/data/alt_sample/matching_inc_follow.dta", replace

//Complete follow-up
use "AUH_base_reduced.dta", clear
keep if hog_obs_jefe==1 & disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli==4
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
gen final_weights = PONDERA*_weights_rcs
save "$AUH_argentina/data/alt_sample/matching_comp_follow.dta", replace

//No income imputation
use "AUH_base_reduced.dta", clear
keep if hog_obs_jefe==1 & disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 & imput_hh_year==0
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)
gen final_weights = PONDERA*_weights_rcs
save "$AUH_argentina/data/alt_sample/matching_no_imput.dta", replace


********************************************************************************
**Step 2: results tables

cd "$AUH_argentina/results/tables"

**time
use "$AUH_argentina/data/alt_sample/matching_time.dta",clear	
//PT
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_time.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_time.doc, append word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_time.doc, append word ctitle (CVd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_time.doc, append word ctitle (CVu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_time.doc, append word ctitle (SD-APC) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-D
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_time.doc, append word ctitle (SD-APCd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-U
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_time.doc, append word ctitle (SD-APCu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 


**No income imputation
use "$AUH_argentina/data/alt_sample/matching_no_imput.dta",clear	
//PT
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & imput_hh_year==0  & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_no_imput.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & imput_hh_year==0 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_no_imput.doc, append word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & imput_hh_year==0  & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_no_imput.doc, append word ctitle (CVd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & imput_hh_year==0  & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_no_imput.doc, append word ctitle (CVu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & imput_hh_year==0 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_no_imput.doc, append word ctitle (SD-APC) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-D
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & imput_hh_year==0 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_no_imput.doc, append word ctitle (SD-APCd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-U
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & imput_hh_year==0 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_no_imput.doc, append word ctitle (SD-APCu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 


**Full inform
use "$AUH_argentina/data/alt_sample/matching_full_inform.dta",clear	
//PT
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_full_inform.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_full_inform.doc, append word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_full_inform.doc, append word ctitle (CVd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_full_inform.doc, append word ctitle (CVu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_full_inform.doc, append word ctitle (SD-APC) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-D
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_full_inform.doc, append word ctitle (SD-APCd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-U
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_full_inform.doc, append word ctitle (SD-APCu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 


**Complete follow-up
use "$AUH_argentina/data/alt_sample/matching_comp_follow.dta",clear	
//PT
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli==4 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_complete_follow.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli==4  & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_complete_follow.doc, append word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli==4 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_complete_follow.doc, append word ctitle (CVd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli==4 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_complete_follow.doc, append word ctitle (CVu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli==4& auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_complete_follow.doc, append word ctitle (SD-APC) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-D
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli==4& auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_complete_follow.doc, append word ctitle (SD-APCd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-U
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli==4 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_complete_follow.doc, append word ctitle (SD-APCu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 


**incomplete follow-up
use "$AUH_argentina/data/alt_sample/matching_inc_follow.dta",clear	
//PT
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=2 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_incomplete_follow.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=2   & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_incomplete_follow.doc, append word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=2  & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_incomplete_follow.doc, append word ctitle (CVd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=2  & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_incomplete_follow.doc, append word ctitle (CVu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=2 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_incomplete_follow.doc, append word ctitle (SD-APC) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-D
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=2 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_sens_incomplete_follow.doc, append word ctitle (SD-APCd) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-U
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=2 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single   educ_hog_pric       imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_sens_incomplete_follow.doc, append word ctitle (SD-APCu) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 


**#
**Table SD6: DR results - ITT: Alternative estimators
*****************************************************
use "$AUH_argentina/data/MDD_base", clear

**With wildbootstrap SEs
//PT
csdid ( mean_poor_period ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( mean_poor_period ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( mean_poor_period ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
//CV
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
//CV-D
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
//CV-U
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
//SDAPC
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
//SDAPC-D
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
//SDAPC-U
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(simple) long2

**#
**Table SD7: DR results - Dynamic ITT: Alternative estimators
*************************************************************

**DRIMP
csdid ( mean_poor_period ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(drimp) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot


**DRIPW
csdid ( mean_poor_period ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(dripw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot


**STDIPW
csdid ( mean_poor_period ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( CV_IPCF ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1>=m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot
csdid ( sd_arcper_change ) child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single age30 age60 hh_fem married single  educ_hog_pric imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3  & disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & m_IPCF_US_an1<m_IPCF_US_an2 [iw=PONDERA] , time(timeToTreat_pos) gvar(gvarname) method(stdipw) wboot(reps(5000)  cluster(AGLOMERADO)) rseed(12345) agg(event) long2
test Tm5 Tm4 Tm3 Tm2
*csdid_plot




**E) Matching quality
*********************

cd "$AUH_argentina\results\graphs"
**#
**Table SE1: Standardised differences
*************************************
pstest   trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup if _support==1 , t(hog_inform_par_all_full_an1) mweight(final_weights) graph both ///
	$plotregion $graphregion $scheme  	

**#
**Figure SE2: Boxplot Propensity scores	
***************************************

gen no_weight = 1

graph box _ps [pw=PONDERA], over(hog_inform_par_all_full_an1)  ///
	asyvars legend(order( 1 "Non-eligible" 2 "Eligible") pos(6) col(2)) ///
	box(2,color(gray) fcolor(%90) lcolor(black)) marker(2, mcolor(gray%90)) ///	
	box(1,color(gs12) fcolor(%20) lcolor(black)) marker(1, mcolor(gs12)) ///	
	ytitle("Propensity score") ///
	$plotregion $graphregion $scheme  name(no_matching,replace) 
	
graph box _ps [pw=final_weights] if _support==1, over(hog_inform_par_all_full_an1)  ///
	asyvars legend(order( 1 "Non-eligible" 2 "Eligible") pos(6) col(2)) ///
	box(2,color(gray) fcolor(%90) lcolor(black)) marker(2, mcolor(gray%90)) ///	
	box(1,color(gs12) fcolor(%20) lcolor(black)) marker(1, mcolor(gs12)) ///	
	ytitle("Propensity score") ///
	$plotregion $graphregion $scheme  name(matching,replace) 
	
graph combine no_matching matching, 	$plotregion $graphregion $scheme  


**#
**Figure SE3: Distribution propensity scores
********************************************

* before
twoway (kdensity _ps if hog_inform_par_all_full_an1==1 [aw=PONDERA], bw(0.03) color(gray) fcolor(%90)) (kdensity _ps if hog_inform_par_all_full_an1==0 [aw=PONDERA],  bw(0.03) color(gs12) fcolor(%20) ///
	$plotregion $graphregion $scheme lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" ) pos(6) col(2) ) ///
xtitle("Propensity scores before matching") ytitle("Kdensity") name(before, replace) 

* after
twoway (kdensity _ps if hog_inform_par_all_full_an1==1 [aweight=final_weights], bw(0.03) color(gray) fcolor(%90)) (kdensity _ps if hog_inform_par_all_full_an1==0 [aweight=_weights], bw(0.03) color(gs12) fcolor(%20) ///
	$plotregion $graphregion $scheme lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" ) pos(6) col(2) ) ///
xtitle("Propensity scores after matching") ytitle("Kdensity") name(after, replace)

* combined
graph combine before after, $plotregion $graphregion $scheme ycommon
	
	
**Figure SE4: Propensity scores across groups
********************************************* 
	
preserve
keep if _support==1 & (after==1 & hog_inform_par_all_full_an1==1)|  _support==1 &(after==0 & hog_inform_par_all_full_an1==0)
psgraph, treated(hog_inform_par_all_full_an1) sup(_support) pscore(_ps) name(psgraph_1,replace) ///
	$plotregion $graphregion $scheme  ///
	xlabel(0.2(0.2)1) ///	
	legend(order( 2 "Treated Post" 1 "Control Pre") pos(6) col(3))
restore

preserve
keep if  _support==1 & (after==1 & hog_inform_par_all_full_an1==1)|  _support==1 &(after==1 & hog_inform_par_all_full_an1==0)
psgraph, treated(hog_inform_par_all_full_an1) sup(_support) pscore(_ps) name(psgraph_2,replace) ///
	$plotregion $graphregion $scheme ///
	xlabel(0.2(0.2)1) ///	
	legend(order(2 "Treated Post" 1 "Control Post") pos(6) col(2))
restore

preserve
keep if  _support==1 & (after==1 & hog_inform_par_all_full_an1==1)|  _support==1 & (after==0 & hog_inform_par_all_full_an1==1) 
psgraph, treated(after) sup(_support) pscore(_ps ) name(psgraph_3,replace) ///
legend(order(2 "Treated Post" 1 "Treated Pre" ) pos(6) col(2)) ///
	xlabel(0.2(0.2)1) ///	
	$plotregion $graphregion $scheme 
restore

graph combine psgraph_1 psgraph_2 psgraph_3, $plotregion $graphregion $scheme  
