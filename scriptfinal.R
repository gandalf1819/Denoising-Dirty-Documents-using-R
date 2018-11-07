
# libraries
library("pacman")
pacman::p_load(png, raster, data.table, reshape)
#dirtyfolderfortraing

dirtyFolder = "D:/Documents/Projects/Denoising Dirty Documents/dirtyFolder/train/train"

#cleanedfolderfor training

cleanFolder = "D:/Documents/Projects/Denoising Dirty Documents/cleanFolder/train_cleaned/train_cleaned"

#data object

dat = NULL

filenames = list.files(dirtyFolder)
i=0
for (f in filenames)
{
  i = i+1
  #if(i%% 20 == 0)
  
  print(f)
  imgX = readPNG(file.path(dirtyFolder, f))
  imgY = readPNG(file.path(cleanFolder, f))
  
  # turn the images into vectors
  x = matrix(imgX, nrow(imgX) * ncol(imgX), 1)
  y = matrix(imgY, nrow(imgY) * ncol(imgY), 1)
  
  if (f == filenames[1])
  {
    dat = cbind(y, x)
    names(dat) = NULL
  } else
  {
    dat = rbind(cbind(y, x))
  }
  
}
dat = data.frame(dat)

names(dat) = c("y", "x")

lm.mod.1 = lm(y ~ x, data = dat[y > 0.05 & y < 0.95,])  #ignore extremities
summary(lm.mod.1)


# fit a linear model, ignoring the data points at the extremes


rows = sample(nrow(dat), 10000)
plot(dat$x[rows], dat$y[rows])
lm.mod.1 = lm(y ~ x, data=dat[dat$y > 0.05 & dat$y < 0.95,])
summary(lm.mod.1)
dat$predicted = sapply(predict(lm.mod.1, newdata=dat), function(x) max(min(x, 1),0))
plot(dat$predicted[rows], dat$y[rows])
rmse1 = sqrt(mean( (dat$y - dat$x) ^ 2))
rmse2 = sqrt(mean( (dat$predicted - dat$y) ^ 2))
c(rmse1, rmse2)
print(c(rmse1,rmse2))
#show the predicted result for a sample image
img = readPNG("D:/Documents/Projects/Denoising Dirty Documents/MiniProject/pothis.png")
x = data.table(matrix(img, nrow(img) * ncol(img), 1))
setnames(x, "x")
yHat = sapply(predict(lm.mod.1, newdata=x), function(x) max(min(x, 1),0))
imgOut = matrix(yHat, nrow(img), ncol(img))
writePNG(imgOut, "C:/Users/Chinmay/Desktop/d_5_1.png")
plot(raster(imgOut))



#testing

dirtyFolder = "C:/Users/Chinmay/Desktop/singleds/df"
filenames = list.files(dirtyFolder)
print("Processing")
for (f in filenames)
{
  
  print(".")
  imgX = readPNG(file.path(dirtyFolder, f))
  x = matrix(imgX, nrow(imgX) * ncol(imgX), 1)
  y = coef(lm.mod.1)[1] + coef(lm.mod.1)[2] * x
  print(coef(lm.mod.1)[2])
  
  y[y < 0] = 0
  y[y > 1] = 1
  img = matrix(y, nrow(imgX), ncol(imgX))
  img.dt=data.table(melt(img))
  names.dt<-names(img.dt)
  setnames(img.dt,names.dt[1],"X1")
  setnames(img.dt,names.dt[2],"X2")
  Numfile = gsub(".png", "", f, fixed=TRUE)
  img.dt[,id:=paste(Numfile,X1,X2,sep="_")]
  write.table(img.dt[,c("id","value"),with=FALSE], file = "C:/Users/Chinmay/Desktop/submission_test1.csv", sep = ",", col.names = (f == filenames[1]),row.names = FALSE,quote = FALSE,append=(f != filenames[1]))
  lm(y~x)
  
}
  #plot(y~x, data = dat)
  
  # show a sample
  #if (f == "d3_1.png")
  #{
    #writePNG(imgX, "C:/Users/Chinmay/Desktop/d3_dirty1232.png")
    #writePNG(img, "C:/Users/Chinmay/Desktop/d3_cleaned1232.png")
  #}
  #plot(f)
  
  
  
