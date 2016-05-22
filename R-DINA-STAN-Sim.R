# nohup Rscript R-DINA-STAN-Sim.R | tee R-DINA-log.txt

library('devtools')
install_github("drackham/CDADataSims", ref="develop")
install_github("drackham/CDASimStudies", ref="develop")
library("CDADataSims")
library("CDASimStudies")
library("rstan")

# Configure RSTAN
rstan::rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Load the simulated data
data <- rDINASimpleQ(100)
# Load the Q-matrix
q <- simpleQ()

# Set working directories
wdLocal <- "~/Desktop/RDINA"
wdRemote <- "/home/drackham/RDINA-STAN"

# Start the timer!
ptm <- proc.time()

print("Starting simulation...")

# Run the simulation
fit <- stanSim (data = data, q, wdLocal, 1, 20, 1)

# Save the output
save(fit, file="stanFit.R")

# Stop the timer...
duration <- proc.time() - ptm
duration

