function [x,tcm,contrib,nt,vtr,pool] = elemcor(z,formula,tracer,purity,zun,nom_res,nom_res_mass,analyzer)
%--------------------------------------------------------------------------
%ElemCor
%
%Di Du, Ph.D.
%Xiaoyang Su, Ph.D.
%
%--------------------------------------------------------------------------
%Input
%
% - z, fraction abundance of measured ion (FAM), e.g. [0.9 0.1 0 0 0 0 0]
% - formula, the chemical formula of the compound of interest, e.g. C6H12O6
% - tracer, the tracer element, e.g. C
% - x, mass distribution vector (MDV) with unwanted contribution removed
% - tcm, the total correction matrix
% - zun, optional, is the FAM from an unlabeled experiment
% - nom_res, nominal resolution, required if zun is empty
% - nom_res_mass, the mass where nominal resolution is considered, 200 for
%   Orbitrap and default
% - analyzer, 1 orbitrap, 2 FTICR
%
%--------------------------------------------------------------------------
%Output
%
% - x, mass distribution vector (MDV), e.g. [0.9 0.1 0 0 0 0 0]
% - tcm, total correction matrix (TCM)
% - contrib, contribution from resolution constraint to the difference of
%   IsoCor and AccuCor, a table that contains different elements and their
%   contribution
%
%--------------------------------------------------------------------------
%Log:
%1. FluxFix added, 10/17/2017
%   FluxFix considers experiment measurement of unlabeled compound to
%   construct the correction matrix(CM). However, it does not consider the 
%   fact that each column of the CM is different due to tracer atom change.
%   This is corrected in ElemCor.
%
%2. Matrices truncated for the case where mdv_length < nt+1, 10/18/2017
%   This is an important correction to misocor, though change is barely
%   noticeable. For AcetylCoA in FluxFix paper, the last 18 components
%   in FAM should not enter constrained regression. And in fact, though
%   they are zeros, the resulted MDV could be non-zero at these components. 
%
%3. AccuCor added, 10/19/2017
%   Resolution of the instrument is considered. However, AccuCor was
%   incorrect in calculating mass difference. Specifically, AccuCor
%   calculates correction limits for each non-tracer isotope and uses them
%   in the for-loop. This is wrong as different isotopes may have different
%   mass difference from carbon, and the correction limits on individual
%   isotops don't apply to the situation where different isotopes are
%   possible in a molecule. This is corrected in ElemCor.
%
%4. Output resolution contribution, 10/21/2017
%   The contribution from resolution constraint is evaluated. 
%
%5. 18O and 34S added as tracer, 3/4/2018
%   The CM for tracer is modifed. 
%
%6. Analyzer added, 3/4/2018
%
%7. 18O and 34S edited, 5/18/2018
%   The CM for tracer is modifed, no odd number extra mass is considered,
%   FAM only has even number extra mass, namely, M+0, M+2, M+4, etc.

%% 0 Preparation
if isempty(zun) == 1 && isempty(nom_res) == 1
    error('Either resolution or unlabeled FAM has to be provided.\n');
end   
if isempty(nom_res) == 1 
    nom_res = 1e5;  %if nor_res is empty, fill 100000, which is the default
end   
if isempty(nom_res_mass) == 1 
    nom_res_mass = 200;  %normally it is 200, unless it is otherwise stated in instrument software.
end   
if iscolumn(z) == 0; z = z'; end %first make sure z (fam) is a column vector
mdv_length = length(z); %length of mdv or fam
contrib = []; %initialize contrib table
corlim_ar = []; %AccuCor
  
%% 1 parse formula
%library
el_lib = {'O','H','N','C','Si','S'}; %library element
iso_dist_lib = {[0.99757	0.00038	0.00205],[0.99985	0.00015],[0.99632...	
    0.00368],[0.9893	0.0107],[0.922297	0.046832	0.030872],...
    [0.9493	0.0076	0.0429	0	0.0002]};%natural abundances for the library elements
el_vtr = [2 1 1 1 1 2]; %valence of tracer element above base
mass_lib = {[15.99491461956 16.99913170 17.9991610],[1.00782503224	2.014101778],[14.0030740048 15.0001088982],...
    [12.0000000 13.0033548378],[27.9769265325 28.976494700 29.97377017],[31.97207100 32.97145876 33.96786690 34.96903216 35.96708076]};

%3/4/2018 18O and 34S added
%{ 
if strcmp(tracer,'C')+strcmp(tracer,'N')+strcmp(tracer,'H') == 0
	error('ElemCor can only correct for tracer C, N or H.\n');   
end    
%} 

if isempty(formula) == 1 %if no formula, then only tracer element is corrected
    formula = [tracer,num2str(length(z)-1)]; 
end
parsed_formula = parse_formula(formula); %parse chemical formula into a struct
find_tracer = find(strcmp(fieldnames(parsed_formula),tracer)==1,1); %locate tracer atom in the chemical formula
if isempty(find_tracer) == 1 
    error('The tracer element is not found in the formula!\n'); 
    %report error if the tracer atom is not present in the chemical formula
else
    nt = getfield(parsed_formula,tracer); %the number of tracer atoms, and different from Nt
    vtr = el_vtr(find(strcmp(el_lib,tracer)==1,1)); %valence of tracer
end
parsed_formula_q = rmfield(parsed_formula,tracer); %parsed formula for non-tracer only
nontracer = fieldnames(parsed_formula_q); %non-tracer atom list, similar to tracer
mw = molecular_weight(formula);  %molecular weight of the analyte
const = 1.67;
switch analyzer
    case 1
        delta_m = mw^1.5*const/(nom_res*sqrt(nom_res_mass)); %Orbitrap
    case 2
        delta_m = mw^2*const/(nom_res*nom_res_mass); %FTICR
end

%% 2 construct total correction matrix

ms = nt+1; %matrix size, for S and O, only even number extra mass will be measured
if length(z) > ms; z = z(1:ms); end
if length(z) < ms; z = [z;zeros(ms-length(z),1)]; end %edited 5/18/2018, z should have length nt+1\
z = z/sum(z); %normalize z

%--------------------------------------------------------------------------
if isempty(zun) == 1 %when unlabeled data are not available
%MDT   
tcm = eye(ms); %initialize the total correction matrix

%CM of non-tracer element(s)
tmass = mass_lib{strcmp(el_lib,tracer)==1};  %isotopic masses of tracer element
tmass = tmass([1 vtr+1]);  %base and label
varname = {}; cont_ar = [];
if isempty(nontracer) == 0
    for k = 1:length(nontracer)
        el = nontracer{k}; %the non-tracer element
        nq = getfield(parsed_formula,el); %the number of non-tracer atom, and different from Nq
        el_index = find(strcmp(el_lib,el)==1,1); %calculate correction matrix only when the element is in the library
        if isempty(el_index) == 0
            qmass = mass_lib{el_index}; %isotopic masses of non-tracer element
            dqmass = qmass(2:end)-qmass(1); %mass differences 
            iso_dist = iso_dist_lib{el_index}; %natural abundance of the non-tracer element
            pst = permlist((0:nq),(length(qmass)-1));
            cv = zeros(1,(length(qmass)-1)*nq+1);
            count_q = 0;
            for j = 1:size(pst,1)
                pst_curr = pst(j,:); %current permutation list
                nq0 = nq - sum(pst(j,:)); %number of q0 atoms
                val = 1:(length(qmass)-1); %valence
                isomass = dot(pst_curr,val); %isotopomer mass
                if (nq0>=0) && (abs(dot(dqmass,pst_curr) - isomass*diff(tmass)/vtr) < delta_m) && (mod(isomass,vtr) == 0)
                    count_q = count_q + 1;
                    cv(isomass+1) = cv(isomass+1) + factorial(nq)/prod(factorial([nq0 pst_curr]))*prod(iso_dist.^[nq0 pst_curr]);
                end
            end
            cont_ar = [cont_ar count_q/factorial(nq+length(qmass)-1)*factorial(nq)*factorial(length(qmass)-1)]; %count different between ElemCor and AccuCor
            varname = [varname el];           
            
            %construct CM from cv
            cv = cv(1:vtr:end); %filter cv
            cm = zeros((ms+length(cv)-1),ms); %correction matrix, ms = nt + 1
            pcv = [cv';zeros(ms-1,1)]; %padded correction vector, for ms columns
            cm(:,1) = pcv;
            for i = 2:ms
                cm(:,i) = cm([end 1:end-1],i-1); %construct the column vector
            end
            tcm = tcm*cm(1:ms,:); %truncate the rows beyond nt+1
        end
    end
end
contrib = array2table(cont_ar);
contrib.Properties.VariableNames = varname;

%CM of tracer element (updated 3/4/2018)
iso_dist = iso_dist_lib{strcmp(el_lib,tracer)==1}; %natural abundance of the tracer element
cm = zeros(ms,ms);    
for i = 1:ms
        cv = 1;
        for j = 1:ms-i
            cv = conv(cv,iso_dist); %use convolution to obtain a column vector of the matrix
        end
        vec = [zeros(i-1,1);cv(1:vtr:end)'];
        cm(:,i) = vec(1:ms); %pad the column vector with zeros
end
cm = cm(1:ms,:);
tcm = tcm*cm; %update tcm

%for i = 1:ms
%    tcm(:,i) = tcm(:,i)/sum(tcm(:,i));
%end
    
%--------------------------------------------------------------------------
else %when unlabeled data are available
%ULS, updated 3/4/2018, added 18O and 34S

if iscolumn(zun) == 0; zun = zun'; end %first make sure zun is a column vector
if length(zun) > ms; zun = zun(1:ms); end
if length(zun) < ms; zun = [zun;zeros(ms-length(zun),1)]; end %edited 5/18/2018, zun should have length nt+1
zun = zun/sum(zun); %normalize zun, like the theoretical tcm
tcm = zeros(ms); %abundance matrix
tcm(:,1) = zun;
iso_dist = iso_dist_lib{strcmp(el_lib,tracer)==1}; %natural abundance of the tracer element
iso_dist = iso_dist([1 vtr+1]);  %base and label, normalization leads to larger error, don't normalize, 05/18/2018

for i = 2:ms
    zun = deconv(zun,iso_dist');
    tcm(:,i) = [zeros(i-1,1);zun];
end
tcm = tcm(1:ms,1:ms);
end

%--------------------------------------------------------------------------
%CM of impurity, required for both FluxFix and AccuCor/MIsoCor
cm = zeros(ms);
for i = 1:ms
    cv = 1;
    for j = 1:i-1
        cv = conv(cv,[1-purity purity]); %use convolution to obtain a column vector of the matrix
    end
    cm(:,i) = [cv';zeros(ms-i,1)]; %pad the column vector with zeros
end
tcm = tcm*cm;

%% 3 constrained regression
function f = funcost(x)
f = norm(tcm*x-z); %cost function
end
x0 = ones(ms,1); %initial guess
options = optimset('TolX',1e-12,'TolFun',1e-12,'MaxIter',1e4,'MaxFunEval',1e4,'Display','off','Algorithm','sqp');
x = fmincon(@funcost,x0,[],[],[],[],zeros(ms,1),[],[],options); %this is correct, the equality constraint is not, from chemistry perspective
pool = sum(x); %pool size, added 05/18/2018
x = x/sum(x);

end