# Rscript sim1.R &> log.txt

library('devtools')
install_github("drackham/CDADataSims", ref="fe55393cfe817810b842bc00a8d59a116af2da96") # RDINA
install_github("drackham/CDASimStudies", ref="35aecb2a0e94910794c47cf7094cc07ca375233b") # RDINA
library('CDADataSims')
library('CDASimStudies')
library('coda')
library('ggmcmc')
library('parallel')
library('runjags')

setwd("/home/drackham")

data <- rDINASimpleQ(1000)
save(data, file="CDA/Simulated Data.R")

q <- simpleQ()
save(q, file="CDA/Simulated Q.R")

generateRDINAJags()

sim <- rDINAJagsSim(data, q, jagsModel="RDINA.jags",
                   adaptSteps = 1000, burnInSteps = 1000, numSavedSteps = 10000, thinSteps = 1)

outPutFileName <- paste("CDA/Sim", simulationCondition = 1, ".RData", sep="")
oneChain <- combine.mcmc(sim1)

codaSamples = as.mcmc.list(oneChain) # resulting codaSamples object has these indices: codaSamples[[ chainIdx ]][ stepIdx , paramIdx ]
save(codaSamples, file=paste("", outPutFileName, sep=""))

S <- ggs(as.mcmc.list(sim1))
ggmcmc(S, file=paste("CDA/ConvergencePlots F.pdf", sep=""), plot=c("traceplot", "autocorrelation"), family="^f", param_page=1)
ggmcmc(S, file=paste("CDA/ConvergencePlots D.pdf", sep=""), plot=c("traceplot", "autocorrelation"), family="^d", param_page=1)
