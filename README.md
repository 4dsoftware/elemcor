# ElemCor

ElemCor is a software tool to correct LC-MS data in isotope labeling experiments. Due to the contribution of naturally occurring isotopes and isotopic impurity from the tracer, the fractional abundances of measured isotopologues (FAM) collected from the instrument must be corrected to obtain mass distribution vectors (MDV) that correspond to the contribution from isotopic labeling. ElemCor is based on the correction matrix (Ref. 1) and uses two different approaches to account for resolution effect, mass different theory (Ref. 2), and unlabeled samples (Ref. 3). ElemCor corrects and improves the numerical schemes of both methods. 

![elemcor](https://user-images.githubusercontent.com/15344717/40388920-80e588d4-5dd6-11e8-81c6-66c2c119afbb.jpg)


## Installation

ElemCor is packaged using MATLAB compiler. Similar to Java application, the software tool requires installation of MATLAB Compiler Runtime (MCR), which is included in the package. Double-clicking "MyAppInstaller_web.exe" will initialize the installation. After it is complete, one can use ElemCor as an executable by double-clicking "ElemCor.exe" from the download folder. The installation requires network connection, but after that the software tool can be used offline. 

## Instruction

The example data files from labeled samples are "test_labelN_sim.xlsx" and "test_labelS_sim.xlsx", and the associated files from unlabeled samples are "test_unlabelN_sim.xlsx" and "test_unlabelS_sim.xlsx". Both data are simulated from XCalibur. The 15N data include 24 metabolites and the 34S data include 10 metabolites. The files show the standard format of input files. Each column vector correspond to FAM of all compounds in each sample. After correction, the MDV's of corresponding samples are stored with a similar format in the same file. 

## Tutorial

The software tool takes data in a spreadsheet (XLSX) format. In Steps 1 and 2, labeled and unlabeled data are loaded. Step 2 is optional, and when it is not performed, ElemCor runs based on mass difference theory only. In Step 3, isotopic purity of nutrient and nominal instrument resolution are specified. In Step 4, the tracer element is selected. In addition to 13C, 2H, and 15N, ElemCor allows 18O and 34S as the tracer element for correction. PLEASE MAKE SURE THE CORRECT TRACER IS SELECTED! In Step 5, the mass analyzer is selected. Then the loaded data are analyzed and isotopic enrichment is calculated for each compound in Step 6. Users can select a cell in the data table, and FAM and MDV for the corresponding compound and sample before and after correction are shown in the figure above.

## Q&A

1. Where are the final results?

The final results are previewed in the graphic interface. They are automatically saved into additional sheets in the original XLSX file. The final results include, MDV, enrichment, and fold change of pool size for differerent compounds and samples.  

2. Can the FAM have a different length than one plus the number of tracer atoms?

FAM typically has a length of Nt + 1 to cover M+0, M+1, ..., M+Nt isotopologues. Here Nt stands for the number of tracer atoms. But ElemCor is able to handle FAM that has a length other than Nt + 1, and the answer is Yes. 

3. What's the advantage of ElemCor over IsoCor?

IsoCor performs correction based on combinatorics without considering ressolution effect. When instrument resolution is extremely low, ElemCor is identical to IsoCor. When instrument resolution is extremely high, ElemCor performs no correction at all. Therefore, the amount of correction perform by ElemCor is monotonically dependent on instrument resolution. 

## Trouble Shooting

1. The results sometimes don't come out after a minute. 

Please check if the correct tracer is selected. If the 15N data are loaded, but C or S is selected as tracer, then the software tool would not run properly. This is because some compounds may not have C or S in their formula, and the algorithm will report error if the tracer is not present in the compound.

## References
1. Millard, P., et al. IsoCor: correcting MS data in isotope labeling experiments. Bioinformatics 2012;28:1294-1296
2. Su, X., et al. Metabolite Spectral Accuracy on Orbitraps. Analytical Chemistry 2017; 89:5940–5948
3. Trefely, S., et al. FluxFix: automatic isotopologue normalization for metabolic tracer analysis. BMC Bioinformatics 2016; 17:485

## Contact
Di Du
dudthu06@gmail.com

Xiaoyang Su
xs137@rwjms.rutgers.edu
