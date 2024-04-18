#-------------------------------------------------------------------------------
# minimum wage application using LOU, CIC, and IFE
#-------------------------------------------------------------------------------

# load packages
library(revealEquations)
library(did)
library(BMisc)
library(twfeweights)
library(fixest)
library(modelsummary)
library(ggplot2)
library(pte)
library(qte)
library(ife)
library(dplyr)
library(tidyr)
load("data2.RData")


data2$G2 <- data2$G 
# lagged outcomes identification strategy
lo_res <- pte::pte_default(yname="lemp",
                           tname="year",
                           idname="id",
                           gname="G2",
                           data=data2,
                           d_outcome=FALSE,
                           lagged_outcome_cov=TRUE)

did::ggdid(lo_res$att_gt, ylim=c(-.2,0.05))
summary(lo_res)
ggpte(lo_res)


## change-in-changes
data2$G2 <- data2$G
cic_res <- qte::cic2(yname="lemp", 
                     gname="G2",
                     tname="year",
                     idname="id",
                     data=data2,
                     boot_type="empirical",
                     cl=4)
ggpte(cic_res) + geom_hline(yintercept=0, size=1.2)


## staggered ife
load("data3.RData")
data4 <- subset(data3, G %in% c(2007,2006,0))
sife_res <- ife::staggered_ife2(yname="lemp",
                                gname="G",
                                tname="year",
                                idname="id",
                                data=data4,
                                nife=1)
did::ggdid(sife_res$att_gt)

