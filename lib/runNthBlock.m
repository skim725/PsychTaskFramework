function Data = runNthBlock(Data, n)
  % RunNthBlock runs Data.blocks{n}.trials using Data.blocks{n}.config and
  % saves the collected results to Data.blocks{n}.data. See lib/configDefaults.m for
  % the parameters that a block can have.
  %
  % If `Data.filename` does not exist, it will not know how to save the trial
  % choices (and will issue a warning).
  %
  % (Replaces `runBlock`, which is now deprecated.)

  %% 0. Validate the arguments
  if ~isstruct(Data) || ~isfield(Data, 'blocks') || ~iscell(Data.blocks)
    error(['First argument must be a struct that contains a cell array in the', ...
      '"blocks" field.']);
  end
  if ~isnumeric(n)
    error('Second argument must be an index to Data.blocks.');
  end
  if numel(Data.blocks) < n || n <= 0
    error('There is no block %d to run; aborting.', n);
  end

  Data = prepForRecording(Data);

  % 1. Extract the important parts from the struct
  block = Data.blocks{n};
  blockConfig = block.config;
  trials = block.trials;

  runTrialFn = blockConfig.task.fnHandles.trialFn;
  if ~isFunction(runTrialFn)
    error(['Function to draw trials not supplied! Make sure that you''ve set' ...
      ' config.task.fnHandles.trialFn = @your_function_to_draw_trials']);
  end

  % 2a. If config say so, run pre-block callback (e.g. display title)
  if isfield(blockConfig.task.fnHandles, 'preBlockFn') && ...
     isFunction(blockConfig.task.fnHandles.preBlockFn)
    blockConfig.task.fnHandles.preBlockFn(Data, blockConfig);
  end

  % 2b. Iterate through trials and save if required
  numTrials = height(trials);
  firstTrial = getFirstTrial(Data);

  for k = firstTrial : numTrials
    trialData = trials(k, :);
    trialData = runTrialFn(trialData, blockConfig);
    Data = addTrial(Data, trialData);
    if blockConfig.device.saveAfterTrial
      saveData(Data);
    end
  end

  %% 3. Save subject file after block
  Data = finishBlock(Data);
  if blockConfig.device.saveAfterBlock || blockConfig.device.saveAfterTrial
    saveData(Data);
  end

  %% 4. If config say so, run post-block callback
  if isfield(blockConfig.task.fnHandles, 'postBlockFn') && ...
     isFunction(blockConfig.task.fnHandles.postBlockFn)
    blockConfig.task.fnHandles.postBlockFn(Data, blockConfig);
  end
end

%% Helper functions
function [ tbl ] = appendRow(row, tbl)
% APPENDROW If `tbl` is defined, append `row` and return it; otherwise, just
%   make `row` the new contents of `tbl`.
  if isempty(tbl)
    tbl = row;
  else
    tbl = [tbl; row]; % will scream if table and row have different columns
  end
end

function [ DataObject ] = addTrial(DataObject, trialData)
% Appends `trialData` to the latest incomplete block record in DataObject.
%
% Assumes that prepForRecording already ran on the DataObject.

% Get the index of the current block being recorded
currentBlockIdx = DataObject.numFinishedBlocks + 1;

% Initialize data table if not recorded yet
if ~isfield(DataObject.blocks{currentBlockIdx}, 'data')
  DataObject.blocks{currentBlockIdx}.data = [];
end

% Add trialData to the DataObject
DataObject.blocks{currentBlockIdx}.data = appendRow(trialData, ...
  DataObject.blocks{currentBlockIdx}.data);
end

function [ DataObject ] = finishBlock(DataObject)
% Mark that the block is finished and shouldn't be resumed.
  blockIdx = DataObject.numFinishedBlocks + 1;
  DataObject.blocks{blockIdx}.finished = true;
  DataObject.numFinishedBlocks = blockIdx;
end

function [ DataObject ] = prepForRecording(DataObject)
% Ensure that DataObject has the fields it is expected to have.
  if ~isfield(DataObject, 'numFinishedBlocks')
    DataObject.numFinishedBlocks = 0;
  end
end

function [ firstTrial ] = getFirstTrial(DataObject)
% Determine the first trial to run if the block was previously interrupted
numStartedBlocks = sum(cellfun(@(x) isfield(x, 'data'), DataObject.blocks));
numFinishedBlocks = DataObject.numFinishedBlocks;

if numStartedBlocks > numFinishedBlocks
  firstTrial = height(DataObject.blocks{numStartedBlocks}.data) + 1;
else
  firstTrial = 1;
end
end
