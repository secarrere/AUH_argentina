********************************************************************************
/*do-file: replication_main_results
********************************************************************************
********************************************************************************
Project title: AUH_argentina			
Database used: INDEC - Encuesta permanente de hogares (EPH)
Author: S. Carrère	
********************************************************************************
********************************************************************************
Description: code for replication of the main results of the paper
 
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

Option 1: you can obtain the main results of the article from the ready-to-use database "MDD_base.dta".

Household selection for the main results: 
 -households with children in the first year (we do not consider here households with disabled members)
 -households interviewed at least three times
 -the poorest households located in the first three IPCF deciles
 -households between the pre/post AUH implementation period are excluded

Option 2: To compute the full database and obtain the results from the supplementary materials, you can download the quarterly data files from the INDEC website and run the do-files to recreate the complete database.


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

//OPTION 1:
***********

//Load dataset
use "$AUH_argentina/data/AUH_ready_base.dta", clear

//Compute the kernel weights (must be calculated once - this calculation may take some times)
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)

//Interaction between kernel weights and survey weights to keep national representativity
gen final_weights = PONDERA*_weights_rcs
label variable final_weights "Kernel weights * survey weights"

//Save the database with kernel weights
save "$AUH_argentina/data/MDD_base.dta", replace


//OPTION 2: Code when using the full dataset:
*******************************************

//Load dataset
use "$AUH_argentina/data/AUH_base_reduced", clear

//Household selection for the main analysis
keep if disable_tot==0 &  hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3

//Compute the kernel weights (this calculation may take some times)
diff mean_poor_period [pw=PONDERA], p(after) t(hog_inform_par_all_full_an1) cov(trim1 trim2 trim3  child_min_tot large_hh young_child5 married age30 age60  hh_fem educ_hog_sec educ_hog_sup) kernel report rcs support clu(AGLOMERADO)

//Interaction between kernel weights and survey weights to keep national representativity
gen final_weights = PONDERA*_weights_rcs
label variable final_weights "Kernel weights * survey weights"

//Save the database with kernel weights
save "$AUH_argentina/data/MDD_base.dta", replace




********************************************************************************

**#
*********************************
**** Main results tables MDD ****
*********************************

use "$AUH_argentina/data/MDD_base.dta", clear


**Table 2: MDD results
**********************

//Destination folder for table creation
cd "$AUH_argentina/results/tables"


//PT
diff mean_poor_period_511 [pw=final_weights] if _support==1 &hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_main_results.doc, replace word ctitle (Poverty trends) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_main_results.doc, append word ctitle (CV) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-D
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_main_results.doc, append word ctitle (CV-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes) groupvar(_diff hog_inform_par_all_full_an1 after) 

//CV-U
diff CV_IPCF [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_main_results.doc, append word ctitle (CV-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_main_results.doc, append word ctitle (SDAPC) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-D
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 ,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh single trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric  imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc   reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12 ) clus(AGLOMERADO)
*outreg2 using tb_main_results.doc, append word ctitle (SDAPC-down) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

//SD APC-U
diff sd_arcper_change [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0,  t(hog_inform_par_all_full_an1) p(after) cov(child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq young_child5 large_hh  trim2 trim3 trim4 age30 age60 hh_fem married single  educ_hog_pric   imput_hh_year educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc  reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 t_2-t_5 t_9-t_12) clus(AGLOMERADO)
*outreg2 using tb_main_results.doc, append word ctitle (SDAPC-up) dec(4) keep(_diff after hog_inform_par_all_full_an1  ) addstat(Mean control, r(mean_c0)) nocons addtext(Controls time and regional dummies, Yes)  groupvar(_diff hog_inform_par_all_full_an1 after) 

**#
**Table 3: MDD results - Heterogeneity
**************************************

*Woman head of household

//PT
reg mean_poor_period_511 1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1 1.after#1.hh_fem 1.hog_inform_par_all_full_an1#1.hh_fem 1.hog_inform_par_all_full_an1 1.after 1.hh_fem reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_fem.doc, replace word nocons ctitle (Poverty trends) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

//CV
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1 1.after#1.hh_fem 1.hog_inform_par_all_full_an1#1.hh_fem 1.hog_inform_par_all_full_an1 1.after 1.hh_fem reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_fem.doc, append word nocons ctitle (CV) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//CV-D
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1 1.after#1.hh_fem 1.hog_inform_par_all_full_an1#1.hh_fem 1.hog_inform_par_all_full_an1 1.after 1.hh_fem reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_fem.doc, append word nocons ctitle (CV-down) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//CV-U
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1 1.after#1.hh_fem 1.hog_inform_par_all_full_an1#1.hh_fem 1.hog_inform_par_all_full_an1 1.after 1.hh_fem reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_fem.doc, append word nocons ctitle (CV-up) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

//SDAPC
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1 1.after#1.hh_fem 1.hog_inform_par_all_full_an1#1.hh_fem 1.hog_inform_par_all_full_an1 1.after 1.hh_fem reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_fem.doc, append word nocons ctitle (SDAPC) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//SDAPC-D
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1 1.after#1.hh_fem 1.hog_inform_par_all_full_an1#1.hh_fem 1.hog_inform_par_all_full_an1 1.after 1.hh_fem reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_fem.doc, append word nocons ctitle (SDAPC-down) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//SDAPC-U
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1 1.after#1.hh_fem 1.hog_inform_par_all_full_an1#1.hh_fem 1.hog_inform_par_all_full_an1 1.after 1.hh_fem reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_fem.doc, append word nocons ctitle (SDAPC-up) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.hh_fem 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)


*Single parent head

//PT
reg mean_poor_period_511 1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1 1.after#1.single 1.hog_inform_par_all_full_an1#1.single 1.hog_inform_par_all_full_an1 1.after 1.single reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_single.doc, replace word nocons ctitle (Poverty trends) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

//CV
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1 1.after#1.single 1.hog_inform_par_all_full_an1#1.single 1.hog_inform_par_all_full_an1 1.after 1.single reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_single.doc, append word nocons ctitle (CV) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//CV-D
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1 1.after#1.single 1.hog_inform_par_all_full_an1#1.single 1.hog_inform_par_all_full_an1 1.after 1.single reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_single.doc, append word nocons ctitle (CV-down) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//CV-U
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1 1.after#1.single 1.hog_inform_par_all_full_an1#1.single 1.hog_inform_par_all_full_an1 1.after 1.single reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_single.doc, append word nocons ctitle (CV-up) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

//SDAPC
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1 1.after#1.single 1.hog_inform_par_all_full_an1#1.single 1.hog_inform_par_all_full_an1 1.after 1.single reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_single.doc, append word nocons ctitle (SDAPC) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//SDAPC-D
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1 1.after#1.single 1.hog_inform_par_all_full_an1#1.single 1.hog_inform_par_all_full_an1 1.after 1.single reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_single.doc, append word nocons ctitle (SDAPC-down) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//SDAPC-U
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1 1.after#1.single 1.hog_inform_par_all_full_an1#1.single 1.hog_inform_par_all_full_an1 1.after 1.single reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12 if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_single.doc, append word nocons ctitle (SDAPC-up) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.single 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

*3 or more children

//PT
reg mean_poor_period_511 1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1 1.after#1.more_children_3 1.hog_inform_par_all_full_an1#1.more_children_3 1.hog_inform_par_all_full_an1 1.after 1.more_children_3 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6  child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_children.doc, replace word nocons ctitle (Poverty trends) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

//CV
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1 1.after#1.more_children_3 1.hog_inform_par_all_full_an1#1.more_children_3 1.hog_inform_par_all_full_an1 1.after 1.more_children_3 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6  child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_children.doc, append word nocons ctitle (CV) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//CV-D
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1 1.after#1.more_children_3 1.hog_inform_par_all_full_an1#1.more_children_3 1.hog_inform_par_all_full_an1 1.after 1.more_children_3 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6  child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_children.doc, append word nocons ctitle (CV-down) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//CV-U
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1 1.after#1.more_children_3 1.hog_inform_par_all_full_an1#1.more_children_3 1.hog_inform_par_all_full_an1 1.after 1.more_children_3 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6  child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_children.doc, append word nocons ctitle (CV-up) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

//SDAPC
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1 1.after#1.more_children_3 1.hog_inform_par_all_full_an1#1.more_children_3 1.hog_inform_par_all_full_an1 1.after 1.more_children_3 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6  child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_children.doc, append word nocons ctitle (SDAPC) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//SDAPC-D
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1 1.after#1.more_children_3 1.hog_inform_par_all_full_an1#1.more_children_3 1.hog_inform_par_all_full_an1 1.after 1.more_children_3 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6  child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_children.doc, append word nocons ctitle (SDAPC-down) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//SDAPC-U
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1 1.after#1.more_children_3 1.hog_inform_par_all_full_an1#1.more_children_3 1.hog_inform_par_all_full_an1 1.after 1.more_children_3 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6  child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_children.doc, append word nocons ctitle (SDAPC-up) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.more_children_3 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

*young children (<=5 y.o)

//PT
reg mean_poor_period_511 1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1 1.after#1.young_child5 1.hog_inform_par_all_full_an1#1.young_child5 1.hog_inform_par_all_full_an1 1.after 1.young_child5 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_young5.doc, replace word nocons ctitle (Poverty trends) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

//CV
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1 1.after#1.young_child5 1.hog_inform_par_all_full_an1#1.young_child5 1.hog_inform_par_all_full_an1 1.after 1.young_child5 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_young5.doc, append word nocons ctitle (CV) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//CV-D
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1 1.after#1.young_child5 1.hog_inform_par_all_full_an1#1.young_child5 1.hog_inform_par_all_full_an1 1.after 1.young_child5 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_young5.doc, append word nocons ctitle (CV-down) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//CV-U
reg CV_IPCF 1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1 1.after#1.young_child5 1.hog_inform_par_all_full_an1#1.young_child5 1.hog_inform_par_all_full_an1 1.after 1.young_child5 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_young5.doc, append word nocons ctitle (CV-up) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)

//SDAPC
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1 1.after#1.young_child5 1.hog_inform_par_all_full_an1#1.young_child5 1.hog_inform_par_all_full_an1 1.after 1.young_child5 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married  educ_hog_pric educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_young5.doc, append word nocons ctitle (SDAPC) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//SDAPC-D
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1 1.after#1.young_child5 1.hog_inform_par_all_full_an1#1.young_child5 1.hog_inform_par_all_full_an1 1.after 1.young_child5 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_young5.doc, append word nocons ctitle (SDAPC-down) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)
//SDAPC-U
reg sd_arcper_change 1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1 1.after#1.young_child5 1.hog_inform_par_all_full_an1#1.young_child5 1.hog_inform_par_all_full_an1 1.after 1.young_child5 reg_n1 reg_n2 reg_n3 reg_n5 reg_n6 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single  imput_hh_year trim2 trim3 trim4 age30 age60 hh_fem married   educ_hog_pric  educ_hog_seci educ_hog_secc educ_hog_supi educ_hog_supc young_child5   t_2 t_3 t_4 t_5 t_9 t_10 t_11 t_12  if hog_obs_jefe==1 & hog_child_year_an1==1 & ano_panel>=2 & ano_panel<=12 & ano_panel!=7 & DECCFR_num_mob_an1<=3 &   disable_tot==0 & ano_panel>=2 & nb_dupli>=3 & auh_implementation==0 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2 [pw= final_weights ], clu(AGLOMERADO)
*outreg2 using tb_heterogeneity_young5.doc, append word nocons ctitle (SDAPC-up) dec(4) keep (1.after#1.hog_inform_par_all_full_an1#1.young_child5 1.after#1.hog_inform_par_all_full_an1) addtext(Controls, Yes)


**************************
**** Main figures MDD ****
**************************

**#
//Parallel trends

*(a) Poverty trends
est clear
qui reg mean_poor_period_511 hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1 &  DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 , clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot,recast(connected) recastci(rarea)  title("") name(ptrends_poor_period, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall)) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(0 "0" 0.10 "0.10" 0.20 "0.20" 0.30 "0.30" 0.40 "0.40" 0.50 "0.50" 0.60 "0.60" 0.70 "0.70", gmin gmax)  ytitle("Average time spent in poverty (%)", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xtitle ("")  xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) ///	
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 

*graph export "$AUH_argentina/results/graphs/ptrends_pov.emf", replace 


*(b) CV_all
est clear
qui reg CV_IPCF hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 , clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot, recast(connected) recastci(rarea) title("") name(ptrends_CV_all, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall)) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(0.20 "0.20" 0.30 "0.30" 0.40 "0.40" 0.50 "0.50" 0.60 "0.60", gmin gmax) ytitle("Coefficient of variation of household income", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) xtitle ("") ///
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 

*graph export "$AUH_argentina/results/graphs/ptrends_cv_all.emf", replace 
	
*(c) CV-down
est clear
qui reg CV_IPCF hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1  & DECCFR_num_mob_an1<=3 & ano_panel!=7 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 , clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot, recast(connected) recastci(rarea) title("") name(ptrends_CV_down, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall)) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(0.20 "0.20" 0.30 "0.30" 0.40 "0.40" 0.50 "0.50" 0.60 "0.60", gmin gmax) ytitle("Coefficient of variation of household income", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) xtitle ("") ///
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 
	
*graph export "$AUH_argentina/results/graphs/ptrends_cvd.emf", replace 
	
*(d) CV_up
est clear
qui reg CV_IPCF hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 & hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1  & DECCFR_num_mob_an1<=3 & ano_panel!=7 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 , clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot, recast(connected) recastci(rarea) title("") name(ptrends_CV_up, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall)) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel( 0.20 "0.20" 0.30 "0.30" 0.40 "0.40" 0.50 "0.50" 0.60 "0.60", gmin gmax) ytitle("Coefficient of variation of household income", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) xtitle ("") ///
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 

*graph export "$AUH_argentina/results/graphs/ptrends_cvu.emf", replace 


*(e) sd_arcper_change-all
est clear
qui reg sd_arcper_change hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1 & DECCFR_num_mob_an1<=3 & ano_panel!=7 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3 , clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot, recast(connected) recastci(rarea) title("") name(ptrends_CV_all, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall)) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80", gmin gmax) ytitle("SD (Arc Percentage Change) of income (%)", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) xtitle ("") ///
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 

*graph export "$AUH_argentina/results/graphs/ptrends_sdapc_all.emf", replace 
	
*(f) sd_arcper_change-down
est clear
qui reg sd_arcper_change hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 &  hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1  & DECCFR_num_mob_an1<=3 & ano_panel!=7 & m_IPCF_US_an1>=m_IPCF_US_an2 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3, clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot, recast(connected) recastci(rarea) title("") name(ptrends_CV_down, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall)) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80", gmin gmax) ytitle("SD (Arc Percentage Change) of income (%)", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) xtitle ("") ///
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 
	
*graph export "$AUH_argentina/results/graphs/ptrends_sdapcd.emf", replace 
	
*(g) sd_arcper_change-up
est clear
qui reg sd_arcper_change hog_inform_par_all_full_an1##ib5.ano_panel_temp [pw=final_weights] if _support==1 & hog_obs_jefe==1 & disable_tot==0  & hog_child_year_an1==1  & DECCFR_num_mob_an1<=3 & ano_panel!=7 & m_IPCF_US_an1<m_IPCF_US_an2 & ano_panel>=2 & auh_implementation==0 & nb_dupli>=3, clu(AGLOMERADO)
qui margins hog_inform_par_all_full_an1, at(ano_panel_temp= (1 2 3 4 5 6 7 8 9 10))

marginsplot, recast(connected) recastci(rarea) title("") name(ptrends_CV_up, replace) ///
	legend(order(4 "Eligible households" 3 "Non-eligible households") pos(6) col(2) size(medsmall)) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(30 "30" 40 "40" 50 "50" 60 "60" 70 "70" 80 "80", gmin gmax) ytitle("SD (Arc Percentage Change) of income (%)", margin(0 1 0 0) size(medsmall)) ///
	xlabel(1 "2004-2005" 2 "2005-2006" 3 "2006-2007" 4 "2007-2008" 5 "2008-2009" 6 "2010-2011" 7 "2011-2012" 8 "2012-2013" 9 "2013-2014" 10 "2014-2015", ang(35)) xline(5.5, lcolor(black) lpattern(-) lwidth(*1)) xtitle ("") ///
	plotopts(lc(gs0) lpattern(solid) msymbol(O) msize(*1) mlcolor(gs0) mfcolor(gs0)) ciopt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black))  ///
	plot1opts(lc(gs10) lpattern(solid) msymbol(X) msize(*2) mlcolor(gs10) mfcolor(gs10)) ci1opt(acolor(gs14%60) lwidth(*0.5) lpattern(dash) lcolor(*1) lcolor(black)) 

*graph export "$AUH_argentina/results/graphs/ptrends_sdapcu.emf", replace 


**#
//Event studies
	
*(a) Poverty trends
est clear
qui reghdfe mean_poor_period_511 lead_treat_m5 lead_treat_m4 lead_treat_m3 lead_treat_m2 zero lag_treat_p1 lag_treat_p2 lag_treat_p3 lag_treat_p4 lag_treat_p5 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single hh_fem married age30 age60 educ_hog_pric educ_hog_secc educ_hog_supi educ_hog_supc  young_child5 hog_inform_par_all_full_an1  imput_hh_year if hog_obs_jefe==1 & auh_implementation==0 & ano_panel>=2 & DECCFR_num_mob_an1<=3 & hog_child_year_an1==1 & disable_tot==0 & ano_panel!=7 & nb_dupli>=3 & _support==1 [pw=final_weights] ,absorb(ib6.ano_panel reg_n1 reg_n2 reg_n3 reg_n4 reg_n6 trim2 trim3 trim4)  vce(cluster AGLOMERADO)

coefplot, omitted keep( lead_* zero lag_*) ///
	vertical mlcolor(gs0) mfcolor(gs0)  msize (*1) msymbol(c) levels(95   )  ///
	legend(off) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(-0.20 "-0.20" -0.15 "-0.15" -0.10 "-0.10" -0.05 "-0.05" 0 "0" 0.05 "0.05" 0.10 "0.10", gmin gmax) ///
	yline(0, lcolor(black) lwidth(*0.5) lpattern(-)) ///
	xline(5.5, lcolor(black) lpattern(-) lwidth(*0.5)) ///
	xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "+1" 8 "+2" 9 "+3" 10 "+4") xtitle("Event time", size(medsmall)) ///
	ytitle("Estimated Coeffecient", margin(0 1 0 0)  size(medsmall)) ///
	ciopts(recast( rcap ) lwidth(*1) lcolor( black ))
	
*graph export "$AUH_argentina/results/graphs/event_pov_trends_match.emf", replace 
		
*(b) CV
est clear
qui reghdfe CV_IPCF lead_treat_m5 lead_treat_m4 lead_treat_m3 lead_treat_m2  zero lag_treat_p1 lag_treat_p2 lag_treat_p3 lag_treat_p4 lag_treat_p5 child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh single hh_fem married age30 age60 educ_hog_pric educ_hog_secc educ_hog_supi educ_hog_supc  young_child5 hog_inform_par_all_full_an1  imput_hh_year if hog_obs_jefe==1 & auh_implementation==0 & ano_panel>=2 & DECCFR_num_mob_an1<=3 & hog_child_year_an1==1 & disable_tot==0 & ano_panel!=7 & nb_dupli>=3 & _support==1 [pw=final_weights] ,absorb(ib6.ano_panel reg_n1 reg_n2 reg_n3 reg_n4 reg_n6 trim2 trim3 trim4 )  vce(cluster AGLOMERADO)
coefplot, omitted keep( lead_* zero lag_*) ///
	vertical mlcolor(gs0) mfcolor(gs0)  msize (*1) msymbol(c) levels(95  )  ///
	legend(off) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(-0.15 "-0.15" -0.10 "-0.10" -0.05 "-0.05" 0 "0" 0.05 "0.05" 0.10 "0.10", gmin gmax) ///
	yline(0, lcolor(black) lwidth(*0.5) lpattern(-)) ///
	xline(5.5, lcolor(black) lpattern(-) lwidth(*0.5)) ///
	xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "+1" 8 "+2" 9 "+3" 10 "+4") xtitle("Event time", size(medsmall)) ///
	ytitle("Estimated Coeffecient", margin(0 1 0 0)  size(medsmall)) ///
	ciopts(recast( rcap ) lwidth(*1) lcolor( black ))

*graph export "$AUH_argentina/results/graphs/event_cv_match.emf", replace 
		
*(c) CV-d
est clear
qui reghdfe CV_IPCF lead_treat_m5 lead_treat_m4 lead_treat_m3 lead_treat_m2 zero lag_treat_p1 lag_treat_p2 lag_treat_p3 lag_treat_p4 lag_treat_p5  child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh age30 age60 hh_fem married single educ_hog_pric educ_hog_secc educ_hog_supi educ_hog_supc  young_child5 hog_inform_par_all_full_an1  imput_hh_year if hog_obs_jefe==1 & auh_implementation==0 & ano_panel>=2 & DECCFR_num_mob_an1<=3 & hog_child_year_an1==1 & disable_tot==0 & ano_panel!=7 & nb_dupli>=3 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2 [pw=final_weights] ,absorb(ib6.ano_panel reg_n1 reg_n2 reg_n3 reg_n4 reg_n6 trim2 trim3 trim4)  vce(cluster AGLOMERADO)
coefplot, omitted keep( lead_* zero lag_*) ///
	vertical mlcolor(gs0) mfcolor(gs0)  msize (*1) msymbol(c) levels(95   )  ///
	legend(off) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(-0.20 "-0.20" -0.15 "-0.15" -0.10 "-0.10" -0.05 "-0.05" 0 "0" 0.05 "0.05" 0.10 "0.10" 0.15 "0.15" 0.20 "0.20", gmin gmax) ///
	yline(0, lcolor(black) lwidth(*0.5) lpattern(-)) ///
	xline(5.5, lcolor(black) lpattern(-) lwidth(*0.5)) ///
	xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "+1" 8 "+2" 9 "+3" 10 "+4") xtitle("Event time", size(medsmall)) ///
	ytitle("Estimated Coeffecient", margin(0 1 0 0)  size(medsmall)) ///
	ciopts(recast( rcap ) lwidth(*1) lcolor( black ))
	

*graph export "$AUH_argentina/results/graphs/event_cv_d_match.emf", replace 


*(c) CV-u
est clear
qui reghdfe CV_IPCF lead_treat_m5 lead_treat_m4 lead_treat_m3 lead_treat_m2 zero lag_treat_p1 lag_treat_p2 lag_treat_p3 lag_treat_p4 lag_treat_p5  child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh age30 age60 hh_fem married single educ_hog_pric educ_hog_secc educ_hog_supi educ_hog_supc  young_child5 hog_inform_par_all_full_an1  imput_hh_year if hog_obs_jefe==1 & auh_implementation==0 & ano_panel>=2 & DECCFR_num_mob_an1<=3 & hog_child_year_an1==1 & disable_tot==0 & ano_panel!=7 & nb_dupli>=3 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2   [pw=final_weights] ,absorb(ib6.ano_panel  reg_n1 reg_n2 reg_n3 reg_n4 reg_n6 trim2 trim3 trim4)  vce(cluster AGLOMERADO)
coefplot, omitted keep( lead_* zero lag_*) ///
	vertical mlcolor(gs0) mfcolor(gs0)  msize (*1) msymbol(c) levels(95   )  ///
	legend(off) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	ylabel(-0.20 "-0.20" -0.15 "-0.15" -0.10 "-0.10" -0.05 "-0.05" 0 "0" 0.05 "0.05" 0.10 "0.10", gmin gmax) ///
	yline(0, lcolor(black) lwidth(*0.5) lpattern(-)) ///
	xline(5.5, lcolor(black) lpattern(-) lwidth(*0.5)) ///
	xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "+1" 8 "+2" 9 "+3" 10 "+4") xtitle("Event time", size(medsmall)) ///
	ytitle("Estimated Coeffecient", margin(0 1 0 0)  size(medsmall)) ///
	ciopts(recast( rcap ) lwidth(*1) lcolor( black ))
	
*graph export "$AUH_argentina/results/graphs/event_cv_u_match.emf", replace 			

*(e) sd_arcper_change
est clear
qui reghdfe sd_arcper_change lead_treat_m5 lead_treat_m4 lead_treat_m3 lead_treat_m2 zero lag_treat_p1 lag_treat_p2 lag_treat_p3 lag_treat_p4 lag_treat_p5  child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh age30 age60 hh_fem married single educ_hog_pric educ_hog_secc educ_hog_supi educ_hog_supc  young_child5 hog_inform_par_all_full_an1  imput_hh_year if hog_obs_jefe==1 & auh_implementation==0 & ano_panel>=2 & DECCFR_num_mob_an1<=3 & hog_child_year_an1==1 & disable_tot==0 & ano_panel!=7 & nb_dupli>=3 & _support==1  [pw=final_weights] ,absorb(ib6.ano_panel reg_n1 reg_n2 reg_n3 reg_n4 reg_n6 trim2 trim3 trim4)  vce(cluster AGLOMERADO)
coefplot, omitted keep( lead_* zero lag_*) ///
	vertical mlcolor(gs0) mfcolor(gs0)  msize (*1) msymbol(c) levels(95   )  ///
	legend(off) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	yline(0, lcolor(black) lwidth(*0.5) lpattern(-)) ///
	xline(5.5, lcolor(black) lpattern(-) lwidth(*0.5)) ///
	ylabel(-30 "-30" -20 "-20" -10 "-10" 0 "0" 10 "10" 20 "20", gmin gmax) ///
	xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "+1" 8 "+2" 9 "+3" 10 "+4") xtitle("Event time", size(medsmall)) ///
	ytitle("Estimated Coeffecient", margin(0 1 0 0)  size(medsmall)) ///
	ciopts(recast( rcap ) lwidth(*1) lcolor( black ))

*graph export "$AUH_argentina/results/graphs/event_sdarc_match.emf", replace 
		
*(f) sd_arcper_change-d
est clear
qui reghdfe sd_arcper_change lead_treat_m5 lead_treat_m4 lead_treat_m3 lead_treat_m2 zero lag_treat_p1 lag_treat_p2 lag_treat_p3 lag_treat_p4 lag_treat_p5  child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh age30 age60 hh_fem married single educ_hog_pric educ_hog_secc educ_hog_supi educ_hog_supc  young_child5 hog_inform_par_all_full_an1  imput_hh_year if hog_obs_jefe==1 & auh_implementation==0 & ano_panel>=2 & DECCFR_num_mob_an1<=3 & hog_child_year_an1==1 & disable_tot==0 & ano_panel!=7 & nb_dupli>=3 & _support==1 & m_IPCF_US_an1>=m_IPCF_US_an2  [pw=final_weights] ,absorb(ib6.ano_panel  reg_n1 reg_n2 reg_n3 reg_n4 reg_n6 trim2 trim3 trim4)  vce(cluster AGLOMERADO)
coefplot, omitted keep( lead_* zero lag_*) ///
	vertical mlcolor(gs0) mfcolor(gs0)  msize (*1) msymbol(c) levels(95   )  ///
	legend(off) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	yline(0, lcolor(black) lwidth(*0.5) lpattern(-)) ///
	xline(5.5, lcolor(black) lpattern(-) lwidth(*0.5)) ///
	ylabel(-60 "-60" -40 "-40" -20 "-20" 0 "0" 20 "20" 40 "40", gmin gmax) ///
	xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "+1" 8 "+2" 9 "+3" 10 "+4") xtitle("Event time", size(medsmall)) ///
	ytitle("Estimated Coeffecient", margin(0 1 0 0)  size(medsmall)) ///
	ciopts(recast( rcap ) lwidth(*1) lcolor( black ))
	

*graph export "$AUH_argentina/results/graphs/event_sdarc_d_match.emf", replace 


*(g) sd_arcper_change-u
est clear
qui reghdfe sd_arcper_change lead_treat_m5 lead_treat_m4 lead_treat_m3 lead_treat_m2 zero lag_treat_p1 lag_treat_p2 lag_treat_p3 lag_treat_p4 lag_treat_p5  child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh age30 age60 hh_fem married single educ_hog_pric educ_hog_secc educ_hog_supi educ_hog_supc  young_child5 hog_inform_par_all_full_an1  imput_hh_year if hog_obs_jefe==1 & auh_implementation==0 & ano_panel>=2 & DECCFR_num_mob_an1<=3 & hog_child_year_an1==1 & disable_tot==0 & ano_panel!=7 & nb_dupli>=3 & _support==1 & m_IPCF_US_an1<m_IPCF_US_an2 [pw=final_weights] ,absorb(ib6.ano_panel reg_n1 reg_n2 reg_n3 reg_n4 reg_n6 trim2 trim3 trim4)  vce(cluster AGLOMERADO)
coefplot, omitted keep( lead_* zero lag_*) ///
	vertical mlcolor(gs0) mfcolor(gs0)  msize (*1) msymbol(c) levels(95  )  ///
	legend(off) ///
	$plotregion $graphregion $scheme $ylabel $xlabel ///
	yline(0, lcolor(black) lwidth(*0.5) lpattern(-)) ///
	xline(5.5, lcolor(black) lpattern(-) lwidth(*0.5)) ///
	ylabel(-30 "-30" -20 "-20" -10 "-10" 0 "0" 10 "10" 20 "20", gmin gmax) ///
	xlabel(1 "-5" 2 "-4" 3 "-3" 4 "-2" 5 "-1" 6 "0" 7 "+1" 8 "+2" 9 "+3" 10 "+4") xtitle("Event time", size(medsmall)) ///
	ytitle("Estimated Coeffecient", margin(0 1 0 0)  size(medsmall)) ///
	ciopts(recast( rcap ) lwidth(*1) lcolor( black ))
	
*graph export "$AUH_argentina/results/graphs/event_sdarc_u_match.emf", replace 			
