# load data
library(did)
library(BMisc)
library(twfeweights)
library(fixest)
library(modelsummary)
library(ggplot2)
load("data2.RData")


## ---------------------------------------------------------------------------------
# run TWFE regression
twfe_x <- fixest::feols(lemp ~ post | id + region^year,
                        data=data2)
modelsummary(twfe_x, gof_omit=".*")



# region covariate
cs_x <- att_gt(yname="lemp",
               tname="year",
               idname="id",
               gname="G",
               xformla=~region,
               control_group="nevertreated",
               base_period="universal",
               data=data2)
cs_x_res <- aggte(cs_x, type="group")
summary(cs_x_res)
cs_x_dyn <- aggte(cs_x, type="dynamic")
ggdid(cs_x_dyn)


## ---------------------------------------------------------------------------------
# run TWFE regression
twfe_x <- fixest::feols(lemp ~ post + lpop + lavg_pay | id + region^year,
                        data=data2)
modelsummary(twfe_x, gof_omit=".*")

# more covariates
# regression adjustment
cs_x <- att_gt(yname="lemp",
               tname="year",
               idname="id",
               gname="G",
               xformla=~region + lpop + lavg_pay,
               control_group="nevertreated",
               base_period="universal",
               est_method="reg",
               data=data2)
cs_x_res <- aggte(cs_x, type="group")
summary(cs_x_res)
cs_x_dyn <- aggte(cs_x, type="dynamic")
ggdid(cs_x_dyn)

# ipw
cs_x <- att_gt(yname="lemp",
               tname="year",
               idname="id",
               gname="G",
               xformla=~region + lpop + lavg_pay,
               control_group="nevertreated",
               base_period="universal",
               est_method="ipw",
               data=data2)
cs_x_res <- aggte(cs_x, type="group")
summary(cs_x_res)
cs_x_dyn <- aggte(cs_x, type="dynamic")
ggdid(cs_x_dyn)

#doubly robust
cs_x <- att_gt(yname="lemp",
               tname="year",
               idname="id",
               gname="G",
               xformla=~region + lpop + lavg_pay,
               control_group="nevertreated",
               base_period="universal",
               est_method="dr",
               data=data2)
cs_x_res <- aggte(cs_x, type="group")
summary(cs_x_res)
cs_x_dyn <- aggte(cs_x, type="dynamic")
ggdid(cs_x_dyn)


# varying base period
cs_x <- att_gt(yname="lemp",
               tname="year",
               idname="id",
               gname="G",
               xformla=~region + lpop + lavg_pay,
               control_group="nevertreated",
               base_period="varying",
               est_method="dr",
               data=data2)
cs_x_res <- aggte(cs_x, type="group")
summary(cs_x_res)
cs_x_dyn <- aggte(cs_x, type="dynamic")
ggdid(cs_x_dyn)


# not-yet-treated comparison group
cs_x <- att_gt(yname="lemp",
               tname="year",
               idname="id",
               gname="G",
               xformla=~region + lpop + lavg_pay,
               control_group="notyettreated",
               base_period="universal",
               est_method="dr",
               data=data2)
cs_x_res <- aggte(cs_x, type="group")
summary(cs_x_res)
cs_x_dyn <- aggte(cs_x, type="dynamic")
ggdid(cs_x_dyn)


# anticipation
cs_x <- att_gt(yname="lemp",
               tname="year",
               idname="id",
               gname="G",
               xformla=~region + lpop + lavg_pay,
               control_group="nevertreated",
               base_period="universal",
               est_method="dr",
               anticipation=1,
               data=data2)
cs_x_res <- aggte(cs_x, type="group")
summary(cs_x_res)
cs_x_dyn <- aggte(cs_x, type="dynamic")
ggdid(cs_x_dyn)


#------------------------------------------------------------
# Rambachan & Roth sensitivity analysis
attgt <- did::att_gt(yname="lemp",
                     idname="id",
                     gname="G",
                     tname="year",
                     data=data2,
                     control_group="nevertreated",
                     base_period="universal")

ggdid(aggte(attgt,type="dynamic",cband=FALSE))


# devtools::install_github("asheshrambachan/HonestDiD")
library(HonestDiD)
source("honest_did.R")
cs_es <- aggte(attgt, type="dynamic")
hd_cs <- honest_did(es=cs_es, 
                    e=0,
                    type="relative_magnitude")
createSensitivityPlot_relativeMagnitudes(hd_cs$robust_ci,
                                         hd_cs$orig_ci)

hd_cs <- honest_did(es=cs_es, 
                    e=0,
                    type="smoothness")
createSensitivityPlot(hd_cs$robust_ci,
                      hd_cs$orig_ci)
