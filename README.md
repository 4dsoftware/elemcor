# ElemCor

MIsoCor is a software tool for the correction for natural abundance and isotopic impurity in isotope labeling experiments. It is a combination of three exisiting software, IsoCor (Ref. 1), AccuCor (Ref. 2), and FluxFix (Ref. 3). ElemCor software was built based upon the structure of IsoCor. It uses the mass difference theory described in the AccuCor article (Ref. 2), and/or the data from unlabeled samples described in the FluxFix article (Ref. 3). ElemCor refined the numerical schemes of each software tool. 

![sasd](https://user-images.githubusercontent.com/15344717/37380798-42a724ba-2708-11e8-93da-8c6d27bae7e7.png)


## Installation

ElemCor is developed under MATLAB, and is packaged using MATLAB compiler. Similar to Java application, the software tool requires installation of MATLAB Compiler Runtime (MCR), which is included in the package. Double-clicking "MyAppInstaller_web.exe" will initialize the installation. After installation of MCR is complete, one can use ElemCor as an executable by double-clicking "ElemCor.exe".  

## Instruction

The example data file from labeled samples is "test_labeled.xlsx", and the associated file from unlabeled samples is "test_unlabeled.xlsx".

## Tutorial

The software tool takes data in a spreadsheet format, preferrably in XLSX. Step 1 and 2 are data browser for labeled and unlabeld samples respectively, while Step 2 is optional. When unlabeled samples are not provided, ElemCor runs correction based on the mass difference theory (see Reference 2). The other options include inpurity, nominal resolution, tracer element, and analyzer. We recommend 100,000 as nominal resolution for Orbitrap and 340,000 for high frequency Orbitrap. The others are specified by the users. 

After the parameters are specified, one can run the last step "analyze the data". It takes a few seconds to analyze, and the output is shown in the table on the right. The table can be copied and saved in a spreadsheet. One can select a cell to view the isotopologs before and after correction. Isotopic enrichments are also calculated and shown with the isotopologs.  

## References
1. Millard, P., et al. IsoCor: correcting MS data in isotope labeling experiments. Bioinformatics 2012;28:1294-1296
2. Su, X., et al. Metabolite Spectral Accuracy on Orbitraps. Analytical Chemistry 2017; 89:5940–5948
3. Trefely, S., et al. FluxFix: automatic isotopologue normalization for metabolic tracer analysis. BMC Bioinformatics 2016; 17:485

## Contact
Daniel Du
dudthu06@gmail.com

Xiaoyang Su
xs137@rwjms.rutgers.edu
