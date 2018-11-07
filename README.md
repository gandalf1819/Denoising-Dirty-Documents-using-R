# Denoising Dirty Documents using R
This project aimed at removal of stains from documents by providing dirty and clean images as data-sets for the model to learn and the model would clean the test images by observing results from the training dataset using Linear Regression.

# The Structure of the Problem

We have been given a series of training images, both dirty (with stains and creased paper) and clean (with a white background and black letters). We are asked to develop an algorithm that converts, as close as possible, the dirty images into clean images.

![alt-text](https://colinpriestdotcom.files.wordpress.com/2015/07/the-problem-to-be-solved.jpg)

A greyscale image can be thought of as a three-dimensional surface. The x and y axes are the location within the image, and the z axis is the brightness of the image at that location. The great the brightness, the whiter the image at that location.

We are being asked to transform one three-dimensional surface into another three dimensional surface.

Our task is to clean the images, to remove the stains, remove the paper creases, improve the contrast, and just leave the writing.
Loading the Image Data

In R, images are stored as matrices, with the row being the y-axis, the column being the x-axis, and the numerical value being the brightness of the pixel. Since Kaggle has stored the images in png format, we can use the png package to load the images.

1 if (!require("pacman")) install.packages("pacman")
2 pacman::p_load(png, raster)
  
3 img = readPNG("C:\\Users\\Colin\\Kaggle\\Denoising Dirty Documents\\data\\train\\6.png")
4 head(img)
5 plot(raster(img))

You can see that the brightness values lie within the [0, 1] range, with 0 being black and 1 being white.

# Restructuring the Data for Machine Learning
Instead of modelling the entire image at once, we should predict the cleaned-up brightness for each pixel within the image, and construct a cleaned image by combining together a set of predicted pixel brightnesses. We want a vector of y values, and a matrix of x values. The simplest data set is where the x values are just the pixel brightnesses of the dirty images.

1 if (!require("pacman")) install.packages("pacman")
2 pacman::p_load(png, raster, data.table)
 
3 dirtyFolder = "C:\\Users\\Colin\\Kaggle\\Denoising Dirty Documents\\data\\train"
4 cleanFolder = "C:\\Users\\Colin\\Kaggle\\Denoising Dirty Documents\\data\\train_cleaned"
5 outFolder = "C:\\Users\\Colin\\Kaggle\\Denoising Dirty Documents\\data\\train_predicted"
 
6 outPath = file.path(outFolder, "trainingdata.csv")
7 filenames = list.files(dirtyFolder)
8 for (f in filenames)
9 {
10 print(f)
11 imgX = readPNG(file.path(dirtyFolder, f))
14 imgY = readPNG(file.path(cleanFolder, f))
 
15 x = matrix(imgX, nrow(imgX) * ncol(imgX), 1)
16 y = matrix(imgY, nrow(imgY) * ncol(imgY), 1)
 
17 dat = data.table(cbind(y, x))
18 setnames(dat,c("y", "x"))
19 write.table(dat, file=outPath, append=(f != filenames[1]), sep=",", row.names=FALSE, col.names=(f == filenames[1]), quote=FALSE)
}

20 dat = read.csv(outPath)
21 head(dat)
22 rows = sample(nrow(dat), 10000)
23 plot(dat$x[rows], dat$y[rows]

The data is now in a familiar format, which each row representing a data point, the first column being the target value, and the remaining column being the predictors.

# Our First Predictive Model
Look at the relationship between x and y.

![alt-text](https://colinpriestdotcom.files.wordpress.com/2015/08/20150801-output-3.png)

Except at the extremes, there is a linear relationship between the brightness of the dirty images and the cleaned images. There is some noise around this linear relationship, and a clump of pixels that are halfway between white and black. There is a broad spread of x values as y approaches 1, and these pixels probably represent stains that need to be removed.

So the obvious first model would be a linear transformation, with truncation to ensure that the predicted brightnesses remain within the [0, 1] range.
 
fit a linear model, ignoring the data points at the extremes
 lm.mod.1 = lm(y ~ x, data=dat[dat$y &gt; 0.05 & dat$y &lt; 0.95,])
 summary(lm.mod.1)
 dat$predicted = sapply(predict(lm.mod.1, newdata=dat), function(x) max(min(x, 1),0))
 plot(dat$predicted[rows], dat$y[rows])
 rmse1 = sqrt(mean( (dat$y - dat$x) ^ 2))
 rmse2 = sqrt(mean( (dat$predicted - dat$y) ^ 2))
 c(rmse1, rmse2)

![alt-text](https://colinpriestdotcom.files.wordpress.com/2015/08/20150801-output-5.png)

The linear model has done a brightness and contrast correction. This reduces the RMSE score from 0.157 to 0.078. Let’s see an output image:

show the predicted result for a sample image
 img = readPNG("C:\\Users\\Colin\\Dropbox\\Kaggle\\Denoising Dirty Documents\\data\\train\\6.png")
 x = data.table(matrix(img, nrow(img) * ncol(img), 1))
 setnames(x, "x")
 yHat = sapply(predict(lm.mod.1, newdata=x), function(x) max(min(x, 1),0))
 imgOut = matrix(yHat, nrow(img), ncol(img))
 writePNG(imgOut, "C:\\Users\\Colin\\Dropbox\\Kaggle\\Denoising Dirty Documents\\data\\sample.png")
plot(raster(imgOut))

![alt-text](https://colinpriestdotcom.files.wordpress.com/2015/08/20150801-output-7.png)

# Results 
Although we have used a very simple model, we have been able to clean up this image:

![alt-text](https://colinpriestdotcom.files.wordpress.com/2015/08/20150801-before.png)

Predicted computer
![alt-text](https://colinpriestdotcom.files.wordpress.com/2015/08/20150801-after.png)

