function [sequence]=Make_Sequence(onetrial,trialrepeat)

    % calualte the time length
    % repmat(A,m,n) m for height, n for fat
    triallist = repmat(onetrial, trialrepeat,1);
    % ramdon trial: 1 is to get romdon rowrank
    rowrank = randperm(size(triallist,1));
    sequence = triallist(rowrank, :);
end