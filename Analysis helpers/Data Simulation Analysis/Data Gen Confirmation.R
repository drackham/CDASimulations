library('dplyr')
library('devtools')
install_github("drackham/CDADataSims", ref="develop")
install_github("drackham/CDASimStudies", ref="develop")
library('CDADataSims')
library('CDASimStudies')

generateLatentClasses <- function(qmatrix){

  num_att = length(qmatrix[1,])
  max_att = 2^num_att
  latent_classes = matrix (data=NA, max_att, num_att)
  m <- max_att

  for (a in 1:num_att) {
    m = m/2     # Number of repititions of entries 0 or 1 in one cycle
    anf <- 1

    while (anf < max_att) {
      latent_classes[anf : (anf + m -1),a] <- 0
      anf <- anf + m
      latent_classes[anf : (anf + m -1),a] <- 1
      anf <- anf + m
    }
  }
  rownames(latent_classes) = paste("c", 1:max_att, sep= "")
  latent_classes

}

q <- simpleQ()
data <- simpleData()

probCorrect <- data$probCorrect
xMat <- data$xMat
iParamsLow <- data$iParamsLow
alphaJK <- data$alphaJK
masteryJK <- data$masteryJK

itemMeans <- data.frame(means=rowMeans(xMat[,-1]))
plot(density(itemMeans[,1]), main="Item Difficulty")


###### Inspect rStar #########
latentClasses <- generateLatentClasses(q)
rStar <- list()
rStarItem <- matrix(nrow=data$I, ncol=1)
for (c in 1:nrow(latentClasses)){
  for (i in 1:data$I){ # items
    rStarItem[i,] <- prod(iParamsLow[i,]^((1-latentClasses[c,])*q[i,]))  # Using mastery NOT alphaJK
  }
  rStar[[c]] <- rStarItem
}
pdf("rStar by Latent Class.pdf")
par(mfrow=c(2,2))
for (i in 1:nrow(latentClasses)){
  # plot(density(rStarMastered[[i]]), main=paste("Class", i, sep=" "))
  plot(rStar[[i]], main=paste("Class", i, sep=" "), ylim=c(0,1))
}
dev.off()

uniqueResponseSets <- unique(t(xMat))

uniqueMastery <- unique(alphaJK)


itemDifficulty <- c()
for (i in 1:40){
  itemDifficulty[i] <- sum(xMat[i,])/5000
}
plot(itemDifficulty)
mean(itemDifficulty)

xMaxTotal <- c()
for (j in 1:10000){
  xMaxTotal[j] <- sum(xMat[,j])
}
max(xMaxTotal)
mean(xMaxTotal)

# Histogram of probs of correct response
hist(as.vector(probCorrect))
mean(probCorrect)

##### Prob Correct by Latent Class ######
subjMastery <- data$alphaJK

pdf("Prob Correct by Class")
for (c in 1:nrow(latentClasses)){
  plot(density(mastered <- t(probCorrect)[ which(subjMastery[,1] == latentClasses[c,1] & subjMastery[,2] == latentClasses[c,2]), ]),
       main=paste("Latent Class: ", latentClasses[c,],sep=""))
}
dev.off()


##### Get cell frequencies for each item ######
pdf("Three-Way Table for Each Item")
for (i in 1:I){

}

nonMasterAlpha1 <- matrix(nrow=2, ncol=2)

nonMasterAlpha1[1,1] <- sum(t(xMat)[which(subjMastery[,1] == 0 & subjMastery[,2] == 1), 1 ]) # Correct answer master alpha2
nonMasterAlpha1[1,2] <- sum(t(xMat)[which(subjMastery[,1] == 0 & subjMastery[,2] == 0), 1 ]) # Correct answer non-master alpha2
nonMasterAlpha1[2,1] <- length(t(xMat)[which(subjMastery[,1] == 0 & subjMastery[,2] == 1), 1 ]) - nonMasterAlpha1[1,1] # Incorrect answer master alpha2
nonMasterAlpha1[2,2] <- length(t(xMat)[which(subjMastery[,1] == 0 & subjMastery[,2] == 1), 1 ]) - nonMasterAlpha1[1,2] # Incorrect answer non-master alpha2






