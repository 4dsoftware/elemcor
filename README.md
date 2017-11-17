# ElemCor

MIsoCor is a software tool for the correction for natural abundance and isotopic impurity in isotope labeling experiments. It is a combination of three exisiting software, IsoCor, AccuCor, and FluxFix. ElemCor has combined the advantages of the three software and corrected their errors.  

## Instruction

The example file is "elemcor_example.m", which performs the analysis over a representative example of tracer experiment on cancer cell line. It calls the main function "elemcor.m". 

## Tutorial

To use the elemcor package for other applications, one can simply call the function "elemcor.m". The m-function requires 7 input variables, z, formula, tracer, purity, zun, nom_res, and nom_res_mass. "z" is the fractional abundance of measured ion (FAM). The format is a vector and is also given in the example, for example, [0.9 0.1 0 0]. "formula" is the chemical formula of the compound, for example, 'C3H6O3'. "tracer" is the tracer element, for example, 'C'. "purity" is the isotopic purity of the nutrient. "zun" is the FAM of the same compound from an unlabeled sample. "nom_res" is the nominal resolution of the instrument. "nom_res_mass" is mass where the nominal resolution of the instrument is defined.

The output of the m-function "elemcor.m" includes the mass distribution vector (MDV) after the natural abundance and isotopic impurity are deconvoluted, the total correction matrix, and a table that stores the contribution from different elements considering the effect of resolution.

Please see "ElemCor_Tutorial.pdf" for more details.

## References
1. Millard, P., et al. IsoCor: correcting MS data in isotope labeling experiments. Bioinformatics 2012;28:1294-1296
2. Su, X., et al. Metabolite Spectral Accuracy on Orbitraps. Analytical Chemistry 2017; 89:5940–5948
3. Trefely, S., et al. FluxFix: automatic isotopologue normalization for metabolic tracer analysis. BMC Bioinformatics 2016; 17:485
