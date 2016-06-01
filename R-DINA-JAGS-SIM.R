# nohup Rscript R-DINA-JAGS-SIM.R | tee R-DINA-log.txt

library('devtools')
install_github("drackham/dcms", ref="develop")
library('dcms')
library('uuid')
library('coda')
library('ggmcmc')
library('parallel')
library('runjags')

# Set the simID
simID <- UUIDgenerate()

# setwd("/home/drackham")
setwd("~/Desktop")

data(R_DINA_SimpleQ.500)

# generateRDINAJags()
generateHO_R_DINA_Jags()

cores = min(1, parallel::detectCores()-1)
iter = 5000
chains = cores

# Start the timer!
ptm <- proc.time()

sim <- rDINAJagsSim(R_DINA_SimpleQ.500, jagsModel="HO-R-DINA.jags", maxCores = cores, adaptSteps = 500, burnInSteps = 500,
										numSavedSteps = iter, thinSteps = 1)

# Stop the timer...
duration <- proc.time() - ptm
totalTime <- as.numeric(duration[3])

save(sim, file = paste("R-DINA-JAGS/", simID, "-Sim.RData", sep=""))

#.......... Document the simulation ..............
simType = "R-DINA Non-Hierarchical JAGS"
dataSet = "R_DINA_SimpleQ.500"
dateStarted <- Sys.time()

# Get the SHA1 that was used
dcms.SHA1 <- unlist(strsplit(system("git ls-remote https://github.com/drackham/dcms develop", intern = TRUE), "\t"))[[1]] # Execute system command, split on \t unlist and keep only the SHA1

simInfo <- data.frame(simID, simType, dateStarted, dcms.SHA1, dataSet, cores, iter, chains, totalTime)

# Save the simInfo object
write.table(simInfo, file = paste("R-DINA-JAGS/", simID, "-R-DINA Non-Hierarchical JAGS.txt", sep=""))
