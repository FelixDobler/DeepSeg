
# DeepSeg

These are the code and data for the paper: [DeepSeg: Deep Learning-based Activity Segmentation Framework for Activity Recognition using WiFi](https://github.com/ChunjingXiao/DeepSeg/blob/master/DeepSeg_JIoT_Online.pdf), IEEE Internet of Things Journal, 2020. https://ieeexplore.ieee.org/document/9235578

DeepSeg aims at segmenting activities for WiFi Channel State Information (CSI)-based activity recognition.


# Citation

@ARTICLE{DeepSeg2021,  
&nbsp; &nbsp; author={Chunjing Xiao and Yue Lei and Yongsen Ma and Fan Zhou and Zhiguang Qin},  
&nbsp; &nbsp; journal={IEEE Internet of Things Journal},  
&nbsp; &nbsp;  title={DeepSeg: Deep Learning-based Activity Segmentation Framework for Activity Recognition using WiFi},  
&nbsp; &nbsp;  year={2021},  
&nbsp; &nbsp; volume={8},  
&nbsp; &nbsp; number={7},  
&nbsp; &nbsp; pages={5669-5681},  
&nbsp; &nbsp; doi={10.1109/JIOT.2020.3033173}  
}

# DataSet

The data that we extract from raw CSI data for our experiments can be downloaded from Baidu Netdisk or Google Drive:

Data of CSI amplitudes: Data_CsiAmplitudeCut  
Baidu Netdisk: https://pan.baidu.com/s/12DwlT58PzlVAyBc-lYx1lw (Password: k8yp)  
Google Drive: https://drive.google.com/drive/folders/1PLzV6ZWAauMQLf08NUkd5UeKrqyGMHgv

Manually marked Labels for CSI amplitude data: Label_CsiAmplitudeCut  
Baidu: https://pan.baidu.com/s/1nY5Og4NlLb7VH5oBQ-LH9w (Password: xnra)  
Google: https://drive.google.com/drive/folders/1855zX-93QjmAt2wSeJk0rTJRiPaFMGBd  
(1	boxing; 2	hand swing; 3	picking up; 4	hand raising; 5	running; 6	pushing; 7	squatting; 8	drawing O; 9	walking; 10	drawing X)

Also the raw CSI data we collected can be downloaded via Baidu or Google: Data_RawCSIDat. Note that there is no need to download the raw CSI data for running our experiments. Downloading Data_CsiAmplitudeCut and Label_CsiAmplitudeCut is enough for our experiments.  
Baidu: https://pan.baidu.com/s/1FpA2u_fzFIh4FuNIcWOPdQ (Password: hhcv)  
Google: https://drive.google.com/drive/folders/1vUeJYChsDgBzv7bJbiKDEfAHQje3SW9G


# Requirement
Python3.5  
Tensorflow 1.8  
Matlab 2018a  
The codes are tested under window7 and it should be ok for Ubuntu. 

# Folder descriptions:

*01Data_PreProcess:*
This is used to extract amplitudes from raw CSI *.dat files, and save as *.mat files, aiming at generating files in the folder Data_CsiAmplitudeCut. There is no need to run these codes for our experiments. The files in Data_CsiAmplitudeCut can directly be downloaded from Baidu Netdisk or Google Drive.


*02Segment_ExtractTrainData:*
This is used to extract training data for training the state inference model which will be used in the activity segmentation algorithm. 

*03Segment_DiscretizeCsi:*
This is used to discreize continuous CSI data into bins for segmentation

*04Segment_StateInference:*
This is for training the state inference model, and inferring the state labels of CSI data bins generated by 03Segment_DiscretizeCsi.

*05Segment_CnnSegAlgorithm1:*
This is used to segment activities according to the state labels of CSI data bins generated by 04Segment_StateInference. 

*06Classification_ClassifyActivity:*
This is for classifying activities using CNN, and outputting the feedback for the activity segmentation algorithm.

*11Classification_ExtractTrainData:*
This is used to extract training data for the activity classification model.

*12Visual_ActivitySegmentation:*
This is used to implement a graphical display about start and end points of activities, as shown in Figure 1.

![Figure](https://github.com/ChunjingXiao/DeepSeg/blob/master/FigVisualActivitySegmentation.jpg)
<p align="center">Figure 1. Visual Inspection about start and end points of activities. </p>



# Motivation for DeepSeg
Because fluctuation ranges of CSI amplitudes when activities occur are much larger than that when no activity presents, most existing works focus on designing threshold-based segmentation methods, which attempt to seek an optimal threshold to detect the start and end of an activity. If the fluctuation degree of CSI waveforms exceeds this threshold, an activity is considered to happen.

However, there exist some weaknesses for these threshold-based segmentation methods.
First, policies of noise removal and threshold calculation are usually determined based on subjective observations and experience, and some recommended policies might even be conflicted. Second, threshold-based segmentation methods may suffer from significant performance degradation when applying to the scenario including both fine-grained and coarse-grained activities, as shown in Figure 2. Third, motion segmentation and activity classification, which are closely interrelated, are usually treated as two separate states.

![Figure](https://github.com/ChunjingXiao/DeepSeg/blob/master/FigDiffThresholdSample.jpg)
<p align="center">Figure 2. Performance of threshold-based activity segmentation methods for mixed activities. A small threshold is appropriate for the fine-grained activity but not for the coarse-grained one. And the reverse is true for a big threshold.</p>

# DeepSeg Overview

DeepSeg tries to adopt deep learning techniques to address these problems. DeepSeg is composed of the motion segmentation algorithm and the activity classification model. To avoid experience-dependent noise removal and threshold calculation and address the problem of performance decline for mixed activities, we propose a CNN-based activity segmentation algorithm to segment activities. To enhance overall performance, we introduce a feedback mechanism which can refine the activity segmentation algorithm based on the feedback computed using activity classification results.

![Figure](https://github.com/ChunjingXiao/DeepSeg/blob/master/FigDeepSegFramework.jpg)
<p align="center">Figure 3. DeepSeg Framework. </p>


Figure 3 presents an illustration of how the proposed framework works. The DeepSeg framework mainly consists of the two parts: the activity segmentation algorithm and the activity classification model. For activity segmentation, the continuously received CSI streams are first discretized into equally sized bins. And then the state inference model is used to infer states of these bins. Here we define four states: static-state, start-state, motion-state and end-state. Finally, the start and end points of activities are detected based on the inferred state labels, and activity data is extracted. For activity classification, the classification model takes segmented activity data as input and outputs the probabilities of it belonging to activity classes. And these probabilities are further used to compute the concentration degree as the feedback for the state inference model. Meanwhile, based on the feedback, the state inference model is tuned by increasing the weights of samples with higher confidence.



