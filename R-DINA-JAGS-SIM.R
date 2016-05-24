# nohup Rscript R-DINA-JAGS-SIM.R | tee R-DINA-log.txt

library('devtools')
install_github("drackham/CDADataSims", ref="develop")
install_github("drackham/CDASimStudies", ref="develop")
library('CDADataSims')
library('CDASimStudies')
library('coda')
library('ggmcmc')
library('parallel')
library('runjags')

# Set the simID
simID <- UUIDgenerate()

setwd("/home/drackham")
# setwd("~/Desktop")

data <- rDINASimpleQ(500)
save(data, file="R-DINA-JAGS/RDINA-JAGS-Simulated-Data.RData")

q <- simpleQ()

generateRDINAJagsNonHierachical()

# Start the timer!
ptm <- proc.time()

sim <- rDINAJagsSim(data, jagsModel="RDINA.jags", maxCores = 4, adaptSteps = 1000, burnInSteps = 1000,
										numSavedSteps = 5000, thinSteps = 1)

# Stop the timer...
duration <- proc.time() - ptm
totalTime <- as.numeric(duration[3])

save(sim, file = paste("R-DINA-JAGS/", simID, "-Sim.RData", sep=""))

#.......... Document the simulation ..............
simType = "R-DINA Non-Hierarchical JAGS"
dataSet = "R-DINA Simple Q 500"
dateStarted <- Sys.time()

# Get the SHA1 that was used
CDASimStudies.SHA1 <- unlist(strsplit(system("git ls-remote https://github.com/drackham/CDASimStudies develop", intern = TRUE), "\t"))[[1]] # Execute system command, split on \t unlist and keep only the SHA1

simInfo <- data.frame(simID, simType, dateStarted, CDASimStudies.SHA1, dataSet, cores, iter, chains, totalTime)

# Save the simInfo object
write.table(simInfo, file = paste(simID, "-R-DINA Non-Hierarchical JAGS.txt", sep=""))


# oneChain <- combine.mcmc(sim)

# codaSamples = as.mcmc.list(oneChain) # resulting codaSamples object has these indices: codaSamples[[ chainIdx ]][ stepIdx , paramIdx ]

# S <- ggs(as.mcmc.list(sim))
# ggmcmc(S, file=paste("CDA/ConvergencePlots F.pdf", sep=""), plot=c("traceplot", "autocorrelation"), family="^f", param_page=1)
# ggmcmc(S, file=paste("CDA/ConvergencePlots D.pdf", sep=""), plot=c("traceplot", "autocorrelation"), family="^d", param_page=1)
