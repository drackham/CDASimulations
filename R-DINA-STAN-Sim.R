# nohup Rscript R-DINA-STAN-Sim.R | tee R-DINA-log.txt

library('devtools')
install_github("drackham/dcmdata", ref="develop")
install_github("drackham/dcms", ref="develop")
library("dcmdata")
library("dcms")
library("rstan")
library("uuid")

# Set the simID
simID <- UUIDgenerate()

# Configure RSTAN
rstan::rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Set working directories
wdLocal <- "~/Desktop/R-DINA-STAN"
wdRemote <- "/home/drackham/R-DINA-STAN"

# Load and save the simulated data
N <- 500
data(R_DINA_SimpleQ.500)

# Specify which model to use
model <- "R-DINA-Non-Logit.stan"

cores <- 2
iter <- 5000
chains <- 2

# Start the timer!
ptm <- proc.time()

print("Starting simulation...")

# Run the simulation
fit <- stanSim (model = model, data = R_DINA_SimpleQ.500, wd = wdLocal,
                cores = cores, iter = iter, chains = chains)

# Stop the timer...
duration <- proc.time() - ptm
duration
totalTime <- as.numeric(duration[3])

# Save the output
save(fit, file = paste(simID, "-stanFit.R", sep=""))

#.......... Document the simulation ..............
simType = model
dataSet = paste("R_DINA_SimpleQ.", N, sep = "")
dateStarted <- Sys.time()

# Get the SHA1 that was used
dcms.SHA1 <- unlist(strsplit(system("git ls-remote https://github.com/drackham/dcms develop", intern = TRUE), "\t"))[[1]] # Execute system command, split on \t unlist and keep only the SHA1

simInfo <- data.frame(simID, simType, dateStarted, dcms.SHA1, dataSet, cores, iter, chains, totalTime)

# Save the simInfo object
write.table(simInfo, file = paste(simID, "-R-DINA-STAN-Info.csv", sep=","))
