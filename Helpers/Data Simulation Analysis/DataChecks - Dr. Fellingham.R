# resulting codaSamples object has these indices: codaSamples[[ chainIdx ]][ stepIdx , paramIdx ]

# param <- codaSamples[[1]][,35280]
param <- codaSamples[[1]][,35240]

plot(density(param))
curve(dbeta(x,2,8), add=TRUE)


subj <- data$alphaJK
answers <- data$xMat


mastered <- subj[ which(subj[,6]==1 
                         & subj[,7] ==1), ]

who <- which(subj[,6]==1 & subj[,7] ==1)

masteredAnswers <- answers[,who]
question40 <- masteredAnswers[40,]
mean(question40)

non <- subj[ which(subj[,6]==0 
                  & subj[,7] ==0), ]

not <- which(subj[,6]==0 & subj[,7] ==0)

notAnswers <- answers[,not]
question40 <- notAnswers[40,]
mean(question40)

# Mastered 6, not 7

mastered6 <- subj[ which(subj[,6]== 1 
                        & subj[,7] == 0), ]

# only6 <- subj[which(subj[,6]==1), ]

which6 <- which(subj[,6]==1 & subj[,7] ==0)

mastered6 <- answers[,which6]
question40 <- mastered6[40,]
mean(question40)


# Mastered 7, not 6

mastered7 <- subj[ which(subj[,6]==0 
                         & subj[,7] ==1), ]

which7 <- which(subj[,]==0 & subj[,7] ==1)

masteredAnswers <- answers[,which7]
question40 <- mastered7[40,]
mean(question40)
