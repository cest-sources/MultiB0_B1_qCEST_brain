# MultiB0_B1_qCEST_brain

## Methods

 - Data acquisition from 1 healthy subject at two field strenghts
 - scanners: MAGNETOM Prisma (3T) and Terra.X (7T)
 - conventional Spin-Lock pulse train preparation (10 pulses, DC = 50%, tp = 100 ms, td = 100 ms)
 - B1 levels: 0.6, 0.9, 1.5, 2, 2.7, 4 µT
 - offsets: between -100 and 100 ppm, while a finer sampling between -6 and 6 ppm with a step of 0.25 ppm 
   for B1 < 4 µT
 - step width for B1 = 4 µT was 0.5 ppm which was later interpolated
 - Image readout: 3D snapshot-CEST GRE
 - B1 and B0 maps were measured with the WASABI method
 - Co-registration and reslicing 7T data onto 3T data
 - simultaneously homogenous B0 and B1 values for region-of-interest
 - Definition homogenous: ± 5 % deviation from B1 map, ± 0.1 ppm deviation from B0 map
 - grey and white matter regions within homogenous region

![Methods](../main/img/SL_train.jpg)

## EXCEL file with MultiB0_B1 data
Spin Lock Dataset for 3T and 7 T in grey and white matter

File contains four sheets:
 - GM_7T
 - WM_7T
 - GM_3T
 - WM_3T

Each sheet contains:
 - sequence setup
 - calculated T1 and T2
 - offsets
 - Mean Z spectra for ROI in grey and white matter


All data provided in the excelfile ready to use as descibed here:
https://cest-sources.org/doku.php?id=bm_sim_fit 

