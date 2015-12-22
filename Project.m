%% Start with time from CT-Sim to Ready For Treatment
clear;
load('ProjectDataInitial.mat');

% Data is already imported into matlab from the sql database. Data includes
% the Flag (CT-Sim or Ready For Treatment), patient serial number and
% datetime vector

% Create a matrix for Sex: 1 -> male, 0 -> female
Sex = cell2mat(DOBSex(:,1));
Sex(:,2) = double(strcmp(DOBSex(:,3), 'Male'));

% Create a matrix for DOB (cuurent age relative to today)
DOB = Sex(:,1);
c = clock;
DOB(:,2) = c(1)-cell2mat(DOBSex(:,2));

% Create matrix for oncologist
Onc = cell2mat(Oncologist(:,1:2));

% Create matrix for priority
Prio = cell2mat(Priority);

% Create matrix for all Diagnosis (no grouping)
Diagn = cell2mat(Diagnosis(:,[1 3]));
% Get the data from each of the sequence events
CTDates = getDates(CTroREADY,'Ct-Sim');
MDDates = getDates(MDtoREADY,'READY FOR MD CONTOUR');
DOSEDates = getDates(DOSEtoREADY,'READY FOR DOSE CALCULATION');
PRESDates = getDates(PREStoREADY,'PRESCRIPTION APPROVED');
PHYSDates = getDates(PHYStoREADY,'READY FOR PHYSICS QA');

% Get the wait time for each sequence
CTtime = getTimes(CTDates);
MDtime = getTimes(MDDates);
DOSEtime = getTimes(DOSEDates);
PREStime = getTimes(PRESDates);
PHYStime = getTimes(PHYSDates);

% Make sure that every patient has all 5 events once

patientnum = intersect(CTtime(:,1),PHYStime(:,1),'stable');
patientnum = intersect(patientnum,MDtime(:,1),'stable');
patientnum = intersect(patientnum,DOSEtime(:,1),'stable');
patientnum = intersect(patientnum,PREStime(:,1),'stable');

[~,~,ind] = intersect(patientnum,CTtime(:,1),'stable');
CTtime = CTtime(ind,:);
[~,~,ind] = intersect(patientnum,PHYStime(:,1),'stable');
PHYStime = PHYStime(ind,:);
[~,~,ind] = intersect(patientnum,MDtime(:,1),'stable');
MDtime = MDtime(ind,:);
[~,~,ind] = intersect(patientnum,DOSEtime(:,1),'stable');
DOSEtime = DOSEtime(ind,:);
[~,~,ind] = intersect(patientnum,PREStime(:,1),'stable');
PREStime = PREStime(ind,:);
% Create X input and Y observation
properties_forall = {Sex , Onc, DOB, Prio, Diagn};

[CT_Features, CT_Output] = makeInputData(CTtime,properties_forall);
[MD_Features, MD_Output] = makeInputData(MDtime,properties_forall);
[DOSE_Features, DOSE_Output] = makeInputData(DOSEtime,properties_forall);
[PRES_Features, PRES_Output] = makeInputData(PREStime,properties_forall);
[PHYS_Features, PHYS_Output] = makeInputData(PHYStime,properties_forall);

% Make the X imputs binary vectors

CT_Features = makeFinalX(CT_Features);
MD_Features = makeFinalX(MD_Features);
DOSE_Features = makeFinalX(DOSE_Features);
PRES_Features = makeFinalX(PRES_Features);
PHYS_Features = makeFinalX(PHYS_Features);

X = {CT_Features, MD_Features, DOSE_Features, PRES_Features, PHYS_Features};
Y = {CT_Output, MD_Output, DOSE_Output, PRES_Output, PHYS_Output};
notify = {'CT Done', 'MD Done', 'Dose Done', 'Prescription Done', 'Physics Done'};
%% Time for Machine Learning! 
%Lasso
clear
load('FinalXY.mat')

[B, FitInfo] = lasso(X{1}, Y{1},'CV',10);
lassoPlot(B, FitInfo,'PlotType','CV');
lam = FitInfo.IndexMinMSE
lassoloss = FitInfo.MSE(lam)
sqrt(FitInfo.MSE(lam))
B(:,lam);
disp('LinReg Done')
% SVM Gaussian

svmmodelG = fitrsvm(X{1}, Y{1},'Standardize',true,...
    'KernelFunction','gaussian','CrossVal', 'on', 'Verbose',1);

lossG = kfoldLoss(svmmodelG,'mode','average')


% SVM Linear

svmmodelL = fitrsvm(X{1}, Y{1},'Standardize',true,...
    'KernelFunction','linear','CrossVal', 'on', 'Verbose',1);

lossLin = kfoldLoss(svmmodelL,'mode','average')
disp('SVM Done')
% Regression Tree

rtree = fitrtree(X{1}, Y{1});
[E,~,~,bestlevel] = cvLoss(rtree,...
    'SubTrees','All','TreeSize','min');
rtree = prune(rtree,'Level',bestlevel);
view(rtree,'Mode','graph');
treeloss = min(E)
disp('Tree Done')
% LSBOOST


ClassTreeEns = fitensemble(X{1}, Y{1},'LSBoost',100,'Tree','CrossVal','on');
genError = kfoldLoss(ClassTreeEns,'Mode','Cumulative');
min(genError)
figure
plot(genError);
xlabel('Number of Learning Cycles');
ylabel('Generalization Error');
disp('Boosting Done')

% Bagging


BAGClassTreeEns = fitensemble(X{1}, Y{1},'Bag',100,'Tree',...
    'CrossVal','on','Type','regression');
BAGgenError = kfoldLoss(BAGClassTreeEns,'Mode','Cumulative');
min(BAGgenError)
figure
plot(BAGgenError);
xlabel('Number of Learning Cycles');
ylabel('Generalization Error');

disp('Bagging Done')