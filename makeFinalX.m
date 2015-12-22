function [final_out] = makeFinalX(input)

%Oncs
uniques = unique(input(:,2), 'stable');
temp = repmat(input(:,2),[1 numel(uniques)]);
BinaryOnc = double(bsxfun(@eq,temp,uniques'));
% Prio
uniques = unique(input(:,4), 'stable');
temp = repmat(input(:,4),[1 numel(uniques)]);
BinaryPrio = double(bsxfun(@eq,temp,uniques'));

% Diag
uniques = unique(input(:,5), 'stable');
temp = repmat(input(:,5),[1 numel(uniques)]);
BinaryDiag = double(bsxfun(@eq,temp,uniques'));

size(BinaryOnc);
size(BinaryPrio);
size(BinaryDiag);

final_out = cat(2, input(:,[3 1]), BinaryOnc, BinaryPrio, BinaryDiag);