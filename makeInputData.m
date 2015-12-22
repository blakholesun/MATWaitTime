function [final, Output] = makeInputData(times,features)

final = times;

for i = 1:length(features)

[~,indF,indin] = intersect(final(:,1),features{i}(:,1),'stable');
final = cat(2,final(indF,:), features{i}(indin,2));

end

Output = final(:,2);
final = final(:,3:end);