function [ dates ] = getDates( inputcell, aliasname)

dates = double(strcmp(inputcell(:,1), aliasname));

switch(aliasname)
    case 'Ct-Sim'
        dates(dates(:,1) == 1,1) = 1;
    case 'READY FOR MD CONTOUR'
        dates(dates(:,1) == 1,1) = 2;
    case 'READY FOR DOSE CALCULATION'
        dates(dates(:,1) == 1,1) = 3;
    case 'PRESCRIPTION APPROVED'
        dates(dates(:,1) == 1,1) = 4;
    case 'READY FOR PHYSICS QA'
        dates(dates(:,1) == 1,1) = 5;
end

dates(dates(:,1) == 0,1) = 10;

dates(:,2) = cell2mat(inputcell(:,2));
dates(:,3) = datenum(inputcell(:,3));