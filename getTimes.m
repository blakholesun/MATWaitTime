function [TimetoReady ] = getTimes(input)

% Split Data into start dates and Ready For Treatment dates
startTime= input(input(:,1) ~= 10, :);
RFT = input(input(:,1) == 10, :);

% Get last patient CT-Sim value
[~,indStartTime,~] = unique(startTime(:,2),'last','legacy');
startTime = startTime(indStartTime,:);

% Get the patients that have a start time and Ready For Treatment
[~,indstart2,indRFT] = intersect(startTime(:,2),RFT(:,2),'stable');
startTime = startTime(indstart2,:);
RFT = RFT(indRFT,:);

% Get the matrix into a vector of times for each patient
TimetoReady = cat(2, startTime(:,2), RFT(:,3) - startTime(:,3));

% Filter out any negative values and greater than 30 days
TimetoReady = TimetoReady(TimetoReady(:,2)>0,:);
TimetoReady = TimetoReady(TimetoReady(:,2)<30,:);