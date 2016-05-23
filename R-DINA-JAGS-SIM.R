# nohup Rscript R-DINA-JAGS-Sim.R | tee R-DINA-log.txt
# nohup Rscript R-DINA-JAGS-Sim.R > log.txt 2&1&

library('devtools')
install_github("drackham/CDADataSims", ref="develop") 
install_github("drackham/CDASimStudies", ref="develop") 
library('CDADataSims')
library('CDASimStudies')
library('coda')
library('ggmcmc')
library('parallel')
library('runjags')

# setwd("/home/drackham")
setwd("~/Desktop")

data <- rDINASimpleQ(10)
save(data, file="R-DINA-JAGS/RDINA-JAGS Simulated Data.RData")

q <- simpleQ()

generateRDINAJags()

sim <- rDINAJagsSim(data, jagsModel="RDINA.jags",
                   adaptSteps = 5, burnInSteps = 5, numSavedSteps = 5, thinSteps = 1)
save(sim, file = "R-DINA JAGS Sim.RData")

oneChain <- combine.mcmc(sim)

codaSamples = as.mcmc.list(oneChain) # resulting codaSamples object has these indices: codaSamples[[ chainIdx ]][ stepIdx , paramIdx ]

S <- ggs(as.mcmc.list(sim))
ggmcmc(S, file=paste("CDA/ConvergencePlots F.pdf", sep=""), plot=c("traceplot", "autocorrelation"), family="^f", param_page=1)
ggmcmc(S, file=paste("CDA/ConvergencePlots D.pdf", sep=""), plot=c("traceplot", "autocorrelation"), family="^d", param_page=1)
