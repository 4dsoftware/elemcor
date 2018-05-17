# ElemCor

ElemCor is a software tool to correct LC-MS data for natural abundance and isotopic impurity in isotope labeling experiments. It is based on the correction matrix (Ref. 1) and uses two different approaches to account for resolution effect, mass different theory (Ref. 2), and unlabeled samples (Ref. 3). ElemCor refined the numerical schemes from both methods. 

![elemcor_snapshot](https://user-images.githubusercontent.com/15344717/39780053-bea204ec-52d0-11e8-9e74-e71091154081.jpg)


## Installation

ElemCor is packaged using MATLAB compiler. Similar to Java application, the software tool requires installation of MATLAB Compiler Runtime (MCR), which is included in the package. Double-clicking "MyAppInstaller_web.exe" will initialize the installation. After it is complete, one can use ElemCor as an executable by double-clicking "ElemCor.exe" from the download folder.  

## Instruction

The example data file from labeled samples is "test_labelN_sim.xlsx", and the associated file from unlabeled samples is "test_unlabelN_sim.xlsx".

## Tutorial

The software tool takes data in a spreadsheet (xlsx) format. In Steps 1 and 2, labeled and unlabeled data are loaded. Step 2 is optional, and when it is not performed, ElemCor runs based on mass difference theory only. In Step 3, isotopic purity of nutrient and nominal instrument resolution are specified. In Step 4, the tracer element is selected. In addition to 13C, 2H, and 15N, ElemCor allows 18O and 34S as the tracer element for correction. In Step 5, the mass analyzer is selected. Then the loaded data are analyzed and isotopic enrichment is calculated for each compound in Step 6. Users can select a cell in the data table, and FAM (fractional abundances of measured isotopomers) and MDV (mass distribution vectors) for the corresponding compound and sample before and after correction are shown in the figure above.

## References
1. Millard, P., et al. IsoCor: correcting MS data in isotope labeling experiments. Bioinformatics 2012;28:1294-1296
2. Su, X., et al. Metabolite Spectral Accuracy on Orbitraps. Analytical Chemistry 2017; 89:5940–5948
3. Trefely, S., et al. FluxFix: automatic isotopologue normalization for metabolic tracer analysis. BMC Bioinformatics 2016; 17:485

## Contact
4D
dudthu06@gmail.com

Xiaoyang Su
xs137@rwjms.rutgers.edu
