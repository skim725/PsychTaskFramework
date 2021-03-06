function [ DataObject ] = addGeneratedBlock(DataObject, blockTrials, config, conditions)
% Properly stores block components (trials and config) in a DataObject.

% 1. Initialize and check arguments
if ~isfield(DataObject, 'blocks')
  DataObject.blocks = cell.empty;
end
if ~istable(blockTrials)
  error('`blockTrials must be a table, but is %s!`', class(blockTrials));
end
if exist('conditions', 'var')
  if ~isstruct(conditions)
    warning('Warning: `conditions` should be a structure.');
  end
else
  if isfield(config.runSetup, 'conditions')
    conditions = config.runSetup.conditions;
  else
    conditions = struct.empty;
  end
end

% 2. Put arguments in the correct place in DataObject
% NOTE: The duplication of `conditions` placement is intentional: some scripts
%   rely on the ability to read their condition from the block's config.
config.runSetup.conditions = conditions;
blocksSoFar = numel(DataObject.blocks);
DataObject.blocks{blocksSoFar + 1} = struct('trials', blockTrials, 'config', config, ...
  'conditions', conditions, 'data', table(), 'finished', false);
end
