MATLAB propotype of our discriminatively trained fully-connected CRF model for blood vessel segmentation in fundus images.

This code will be released for academic purposes soon.
Any usage before is forbidden.

#################################################

If you use this software in your research, please cite the following papers:

J. I. Orlando, E. Prokofyeva and M. B. Blaschko: A Discriminatively Trained Fully Connected Conditional Random Field model for Blood Vessel Segmentation in Fundus Images.
IEEE Transactions on Biomedical Engineering (TBME), 2015. Submitted.

J. I. Orlando and M. B. Blaschko: Learning Fully-Connected CRFs for Blood Vessel Segmentation in Retinal Images.
Medical Image Computing and Computer Assisted Intervention (MICCAI), 2014.


#################################################

Our implementation uses some third party code that requires to include other citations if you use it.

----------------------------

* Responses to 2D Gabor wavelets by Soares et al.
J. V. Soares et al.: Retinal vessel segmentation using the 2-D Gabor wavelet and supervised classification.
IEEE Transactions on Medical Imaging, vol. 25, no. 9, 2006

----------------------------

* Line detectors by Nguyen et al.
U. T. Nguyen et al.: An effective retinal blood vessel segmentation method using multi-scale line detection.
Pattern Recognition, vol. 46, no. 3, pp. 703–715, 2013.

----------------------------

* Efficient inference in fully connected CRF by Krahenbul and Koltun (C++ implementation)
P. Krahenbuhl and V. Koltun: Efficient inference in fully connected CRFs with Gaussian edge potentials.
Advances in Neural Information Processing Systems, 2012, pp. 109–117.

(if you use the MEX function that wraps this code please also cite our IEEE TMBE and MICCAI papers)

----------------------------

* Graph-cut for local neighborhood based CRF inference
Y. Boykov and V. Kolmogorov: An experimental comparison of mincut/max-flow algorithms for energy minimization in vision.
IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 26, no. 9, pp. 1124–1137, 2004.


#################################################

The external library VLFeat is required in the Matlab path to compute the ROC curve.
Should you want to obtain those plots, please download the VLFeat library.