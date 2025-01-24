# MultiB0_B1_qCEST_brain

Open MultiB0-MultiB1 CEST MRI dataset for comparing different quantification models

## Methods

 - **Data acquisition**: obtained from 1 healthy subject at two field strengths
 - **Scanners**: MAGNETOM Prisma (3T) and Terra.X (7T)
 - **Pulse train preparation**: conventional Spin-Lock pulse train preparation (10 pulses, DC = 50%, tp = 100 ms, td = 100 ms)
 - **B1 levels**: 0.3, 0.6, 0.9, 1.5, 2, 2.7, 4 µT
 - **Offsets**:
   - between -100 and 100 ppm
   - finer sampling between -6 and 6 ppm with a step of 0.25 ppm 
   for B1 < 4 µT
   - step width for B1 = 4 µT was 0.5 ppm which was later interpolated
 - **Image readout**: 3D snapshot-CEST GRE
 - **Mapping methods**:
   - B1 and B0 maps measured using the WASABI method
   - Co-registration and reslicing 7T data onto 3T data
 - **Homogeneity criteria**:
   - simultaneously homogenous B0 and B1 values for region-of-interest
   - Defined as:
     - ± 5 % deviation from B1 map
     -  ± 0.1 ppm deviation from B0 map
 -  **Regions of Interest (ROI)**:
   - Grey and white matter regions within homogenous region

![SL_train](https://github.com/user-attachments/assets/74c6e4e7-f222-46dd-b0d2-11a36618e1f1)

## Data Description

### NIfTI (.nii) Data

 - This Git repository contains .nii files for each measured sequence at 3T and 7T
 - The corresponding WASABI data (B0 and B1 maps) is provided as .mat file
 - A mask for simultaneously homogenous B0 and B1 values is included as .nii file
 - Segmentation data of grey and white matter regions is provided

### EXCEL file with MultiB0_B1 data
The Spin Lock dataset for 3T and 7 T in grey and white matter is available in an Excel file

**Sheets included**:
 - **GM_7T**: Grey matter data at 7T
 - **WM_7T**: White matter data at 7T
 - **GM_3T**: Grey matter data at 3T
 - **WM_3T**: White matter data at 3T

Each sheet includes:
 - Sequence setup
 - Calculated T1 and T2 values
 - Offsets
 - Mean Z spectra for ROI in grey and white matter


All data provided in the Excel file ready to use as described here:
https://cest-sources.org/doku.php?id=bm_sim_fit 

