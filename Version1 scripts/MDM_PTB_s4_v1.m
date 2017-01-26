function MDM_PTB_s4_v1(observer);
% This function runs the forth two blocks of the task, one Monetary and
% one Medical Block.



% Skip sync test. May be commented out on the laptop
% Screen('Preference','SkipSyncTests',1);

KbName('KeyNamesWindows');
s = RandStream.create('mt19937ar','seed',sum(100*clock));
RandStream.setGlobalStream(s); % ????????????????????????????????????????????????????
whichScreen = 0;
thisdir = pwd; % identify current folder

% % make a data directory if necessary
% if ~isdir(fullfile(thisdir,'data')) % determine whether input is folder
%     disp('Making data directory');
%     mkdir('data'); % make new folder
% end
% 
% % make an observer directory if necessary
% datadirname = fullfile(thisdir,'data',num2str(observer));
% if ~isdir(datadirname);
%     mkdir(datadirname);
% end

% load data from last session
load([thisdir '\data\' num2str(observer) '\MDM_MON_' num2str(observer)]); 
load([thisdir '\data\' num2str(observer) '\MDM_MED_' num2str(observer)]); 

Datamon.observer=observer;
Datamed.observer=observer;
Datamon.date=datestr(now,'yyyymmddTHHMMSS');
Datamed.date=datestr(now,'yyyymmddTHHMMSS');


% Set reference lottery side
if mod(observer,2)==0
    Datamon.refSide=1;
else
    Datamon.refSide=2;
end

if mod(observer,2)==0
    Datamed.refSide=1;
else
    Datamed.refSide=2;
end


Datamon.filename=fullfile('data',num2str(observer),['MDM_MON_' num2str(observer)]);
Datamon.stimulus=setParams_LSRA; % setParams_LSRA is a function defined below, for monetary

Datamed.filename=fullfile('data',num2str(observer),['MDM_MED_' num2str(observer)]);
Datamed.stimulus=setParams_LSRAmed; % setParams_LSRAmed is a function defined below, for medical 


% window dimesion open window
[Win.win Win.winrect] = Screen(whichScreen, 'OpenWindow',0); %[handel,window dimensin matrix]
HideCursor(Win.win); % Hide screen cursor

Screen('TextFont', Win.win, Datamon.stimulus.fontName);
Datamon.colorKey={'blue','red'};
% Need to change for new design, trial time structure
Datamon.stimulus.responseWindowDur=3.5; 
Datamon.stimulus.feedbackDur=.5;
Datamon.stimulus.lottoDisplayDur=6;

Datamed.colorKey={'blue','red'};
% Need to change for new design, trial time structure
Datamed.stimulus.responseWindowDur=3.5; 
Datamed.stimulus.feedbackDur=.5;
Datamed.stimulus.lottoDisplayDur=6;

%load image, structure: Img
imgpath = [thisdir '\symbol'];
addpath(imgpath);
noeffData = imread('no effect.jpg');
Img.noeffTexture = Screen('MakeTexture', Win.win, noeffData); 
slData = imread('slight improvement.jpg');
Img.slTexture = Screen('MakeTexture', Win.win, slData); 
mdData = imread('moderate improvement.jpg');
Img.mdTexture = Screen('MakeTexture', Win.win, mdData); 
mjData = imread('major improvement.jpg');
Img.mjTexture = Screen('MakeTexture', Win.win, mjData); 
rcvData = imread('recovery.jpg');
Img.rcvTexture = Screen('MakeTexture', Win.win, rcvData);

[Img.imgHeight, Img.imgWidth, Img.imgcolors] = size(noeffData); % assuming that images for each level are of the same size


%% % Set up the trial parameters
% % Risk and ambig levels, amount levels
% % only one repetition for $5
% % for MDM, 3 val, 6 risk+ambig, 4 repeat
% n_repeats=4;
% riskyVals=[8,12,25];
% riskyProbs=[.75 .5 .25];
% [valsR, sprobs, repeat]=ndgrid(riskyVals,riskyProbs, 1:n_repeats); % Seems to create trials, repeating prob for each value,and value for each prob 
% ambigVals=[8,12,25];
% ambigLevels=[.24 .5 .74];
% [valsA, sambigs, repeat]=ndgrid(ambigVals,ambigLevels, 1:n_repeats);
% 
% % add the one repeat for $5 
% n_repeats5=1;
% riskyVals5=[5];
% [valsR5, sprobs5, repeat5]=ndgrid(riskyVals5,riskyProbs, 1:n_repeats5);  
% ambigVals5=[5];
% [valsA5, sambigs5, repeat5]=ndgrid(ambigVals5,ambigLevels, 1:n_repeats5);
%  
% % group the trials together, add two more trials with $5
% Datamon.numTrials = length(valsR(:))+length(valsA(:))+length(valsR5(:))+length(valsA5(:))+2; % should be 78+2
% vals=[valsR(:); valsA(:); valsR5(:); valsA5(:);5;5];
% probs=[sprobs(:); .5*ones(size(sambigs(:))); sprobs5(:); .5*ones(size(sambigs5(:)));0.25;0.5];
% ambigs=[zeros(size(sprobs(:))); sambigs(:); zeros(size(sprobs5(:))); sambigs5(:);0;0.5];
% 
% % make colors sum to same value. The numbers in the vectors are tial
% % numbers, they are of the same color . 
% % Two colors, blue and red
% colorIndex1=[1     2     5     6     7    11    14    15    18  20];
% colorIndex2=[3     4     8     9    10    12    13    16    17  19];
% 
% % color for all trials
% start=1;  
% for cond=1:4 % start = 1, 21, 41, 61
%     finish=start+19; % finish = 20,40,60,80
%     assocColorIndex=randperm(2); % shuffle two colors
%     colors(colorIndex1)=assocColorIndex(1);
%     colors(colorIndex2)=assocColorIndex(2);
%     shufColors(start:finish)=colors;
%     start=start+20;
% end
% 
% % below shows how the trials are randomized
% paramPrep=[vals probs ambigs shufColors' randperm(length(vals))']; % make the parameters in to matrix. Each row is a trial. The last column is the randomized trial order
% expParams=sortrows(paramPrep,5); % present trial in randomized order
% 
% 
% % for medical block, just need to shuffle the color again, randomize a different order, and change the vals
% Datamed.numTrials = length(valsR(:))+length(valsA(:))+length(valsR5(:))+length(valsA5(:))+2; % should be 78+2
% 
% colorIndex1=[1     3     6     8     9    11    13    15    17  19];
% colorIndex2=[2     4     5     7    10    12    14    16    18  20];
% 
% start=1;  
% for cond=1:4 % start = 1, 21, 41, 61
%     finish=start+19; % finish = 20,40,60,80
%     assocColorIndex=randperm(2); % shuffle two colors
%     colors(colorIndex1)=assocColorIndex(1);
%     colors(colorIndex2)=assocColorIndex(2);
%     shufColors(start:finish)=colors;
%     start=start+20;
% end
% 
% paramPrepmed=[vals probs ambigs shufColors' randperm(length(vals))']; % make the parameters in to matrix. Each row is a trial. The last column is the randomized trial order
% expParamsmed=sortrows(paramPrepmed,5); % present trial in randomized order
% 

%% % Set up block
% % start and final trial number of each block. S1 F1 are used for expParams,
% % S2 and F2 are real trial numbers in the task design
% % 91 trials in total, 19+20+19+20 trials for the corresponding block
% S1=[1 21 41 61]; % start of each block
% F1=S1+19; % finish of each block 
% % S2=[1 25 48 72]; % start of each block's first trial. The first trial is the catch trial.
% % F2=S2+[23 22 23 23]; % finish of each block
% % tmpColors=[randperm(2) randperm(2)]; % color for the catch trials
% ITIs=[4*ones(1,6) 5*ones(1,8) 6*ones(1,6)]; % 20 ITIs for each block
% 
% %Set up stimulus parameters for every block.
% for block=1:4
% 
% Datamon.block(S1(block):F1(block))=block; % block number of each trial
%     
% % Datamon.vals(S2(block))=4; % val for catch trial
% Datamon.vals(S1(block):F1(block))=expParams(S1(block):F1(block),1);
%  
% % Datamon.probs(S2(block))=.5;
% Datamon.probs(S1(block):F1(block))=expParams(S1(block):F1(block),2);
%  
% % Datamon.ambigs(S2(block))=0;
% Datamon.ambigs(S1(block):F1(block))=expParams(S1(block):F1(block),3);
%  
% % Datamon.colors(S2(block))=tmpColors(block);
% Datamon.colors(S1(block):F1(block))=expParams(S1(block):F1(block),4);
%  
% % Datamon.ITIs(S2(block))=10;
% Datamon.ITIs(S1(block):F1(block))=ITIs(randperm(length(ITIs)));
% 
% end
% 
% % record trial parameters in the Data struct
% Datamon.block=Datamon.block';
% Datamon.vals=Datamon.vals';
% Datamon.probs=Datamon.probs';
% Datamon.ambigs=Datamon.ambigs';
% Datamon.numTrials=length(Datamon.vals);
% 
% % same thing, for medical blocks
% % Set up stimulus parameters for the first trial in every block. ITI = 10s
% for block=1:4
%     Datamed.block(S1(block):F1(block))=block; % block number of each trial
% 
%     % Datamon.vals(S2(block))=4; % val for catch trial
%     Datamed.vals(S1(block):F1(block))=expParamsmed(S1(block):F1(block),1);
% 
%     % Datamon.probs(S2(block))=.5;
%     Datamed.probs(S1(block):F1(block))=expParamsmed(S1(block):F1(block),2);
% 
%     % Datamon.ambigs(S2(block))=0;
%     Datamed.ambigs(S1(block):F1(block))=expParamsmed(S1(block):F1(block),3);
% 
%     % Datamon.colors(S2(block))=tmpColors(block);
%     Datamed.colors(S1(block):F1(block))=expParamsmed(S1(block):F1(block),4);
% 
%     % Datamon.ITIs(S2(block))=10;
%     Datamed.ITIs(S1(block):F1(block))=ITIs(randperm(length(ITIs)));
% end
% 
% % record trial parameters in the Data struct
% Datamed.block=Datamed.block';
% Datamed.vals=Datamed.vals';
% Datamed.probs=Datamed.probs';
% Datamed.ambigs=Datamed.ambigs';
% Datamed.numTrials=length(Datamed.vals);


%% Run through the trials
% decide mon/med go first
blockNum=4; % forth block of both monetary and medical

randblock = randperm(2); % 1-monetary, 2-medical
% randblock = [1 2];

% get the text dimension for probabilities
Datamed.stimulus.textDims.probabilities = getTextDims(Win.win,'50', Datamed.stimulus.fontSize.probabilities);% get the text dimensons for probability
Datamon.stimulus.textDims.probabilities = getTextDims(Win.win,'50', Datamon.stimulus.fontSize.probabilities);% get the text dimensons for probability

% if first is monetary/medical block, first show the text of "Monetary/Medical Block 1"
% run the first block
% introduce a pause, "Medical/Monetary Block 1"
% run the second block
% "First two block finished"

    if randblock(1)==1 %monetay block first
        Screen(Win.win, 'FillRect',1); % what is 1 here?????????????????????????
        Screen('TextSize', Win.win, Datamon.stimulus.fontSize.pause);
        DrawFormattedText(Win.win, ['Monetary Block ' num2str(blockNum)],'center','center',Datamon.stimulus.fontColor);
        %DrawFormattedText(wPtr,textString,sx,sy,color,wrapat,flipHorizontal,flipVertical, vSpacing, rightoleft, winRect)
        drawRef(Datamon,Win)
        Screen('flip',Win.win);
        
        waitForBackTick;

        % run through the monetary first block        
        for trial=(blockNum-1)*21+1 : blockNum*21
            Datamon.trialTime(trial).trialStartTime=datevec(now);
            Datamon=drawLotto_LSRA(Datamon,trial,Win); % Draw lottery. The function also controls lottory display time
            Datamon.trialTime(trial).trialEndTime=datevec(now);
            eval(sprintf('save %s.mat Datamon',Datamon.filename)) % save data
        end
        
        % introduce a pause 
        Screen(Win.win, 'FillRect',1);
        Screen('TextSize', Win.win, Datamed.stimulus.fontSize.pause);
        DrawFormattedText(Win.win, ['Medical Block ' num2str(blockNum)],'center','center',Datamon.stimulus.fontColor);
        drawRefmed(Datamed,Win,Img)
        Screen('flip',Win.win);
        waitForBackTick;
        
        % run through the medical block
        for trial=(blockNum-1)*21+1 : blockNum*21 
            Datamed.trialTime(trial).trialStartTime=datevec(now);
            Datamed=drawLotto_LSRAmed(Datamed,trial,Win,Img); % Draw lottery. The function also controls lottory display time
            Datamed.trialTime(trial).trialEndTime=datevec(now);
            eval(sprintf('save %s.mat Datamed',Datamed.filename)) % save data
        end
        
        % finish the first two blocks
        Screen(Win.win, 'FillRect',1);
        Screen('TextSize', Win.win, Datamed.stimulus.fontSize.pause);
        DrawFormattedText(Win.win,'Finished all blocks','center','center',Datamed.stimulus.fontColor);
        Screen('flip',Win.win);
        waitForBackTick;
     
    elseif randblock(1)==2 %medical block first
        Screen(Win.win, 'FillRect',1); % what is 1 here?????????????????????????
        Screen('TextSize', Win.win, Datamed.stimulus.fontSize.pause);
        DrawFormattedText(Win.win, ['Medical Block ' num2str(blockNum)],'center','center',Datamed.stimulus.fontColor);
        %DrawFormattedText(wPtr,textString,sx,sy,color,wrapat,flipHorizontal,flipVertical, vSpacing, rightoleft, winRect)
        drawRefmed(Datamed,Win,Img)
        Screen('flip',Win.win);
        
        waitForBackTick;

        % run through the medical block
        for trial=(blockNum-1)*21+1 : blockNum*21
            Datamed.trialTime(trial).trialStartTime=datevec(now);
            Datamed=drawLotto_LSRAmed(Datamed,trial,Win,Img); % Draw lottery. The function also controls lottory display time
            Datamed.trialTime(trial).trialEndTime=datevec(now);
            eval(sprintf('save %s.mat Datamed',Datamed.filename)) % save data
        end
        
        % introduce a pause 
        Screen(Win.win, 'FillRect',1);
        Screen('TextSize', Win.win, Datamon.stimulus.fontSize.pause);
        DrawFormattedText(Win.win, ['Monetary Block ' num2str(blockNum)],'center','center',Datamon.stimulus.fontColor);
        drawRef(Datamon,Win)
        Screen('flip',Win.win);
        waitForBackTick;
        
        % run through the monetary first block
        for trial=(blockNum-1)*21+1 : blockNum*21 
            Datamon.trialTime(trial).trialStartTime=datevec(now);
            Datamon=drawLotto_LSRA(Datamon,trial,Win); % Draw lottery. The function also controls lottory display time
            Datamon.trialTime(trial).trialEndTime=datevec(now);
            eval(sprintf('save %s.mat Datamon',Datamon.filename)) % save data
        end
        
        Screen(Win.win, 'FillRect',1);
        Screen('TextSize', Win.win, Datamon.stimulus.fontSize.pause);
        DrawFormattedText(Win.win,'Finished all blocks','center','center',Datamon.stimulus.fontColor);
        Screen('flip',Win.win);
        waitForBackTick;

    end    
    % finish the first two blocks

Datamon=experimentSummary(Datamon);  
Datamed=experimentSummaryMed(Datamed);  

eval(sprintf('save %s.mat Datamed',Datamed.filename)) % save data
eval(sprintf('save %s.mat Datamon',Datamon.filename)) % save data
Screen('CloseAll') % Close screen and psychtoolbox
end

%% Functions:

% draw medical block treatment
function Data=drawLotto_LSRAmed(Data,trial,Win,Img);
% Data struct specifies the 
% Trial specifies prob, val, ambig
% Probability for each color
if strcmp(Data.colorKey{Data.colors(trial)},'blue')
    redProb=1-Data.probs(trial);
    blueProb=Data.probs(trial);
elseif strcmp(Data.colorKey{Data.colors(trial)},'red')
    redProb=Data.probs(trial);
    blueProb=1-Data.probs(trial);
end

H=Win.winrect(4); % Height
W=Win.winrect(3); % Width
Y1=(H-Data.stimulus.lotto.height)/2; % Top of lottery
Y2=Y1+Data.stimulus.lotto.height*redProb; % bottom of red bar
Y3=Y2+Data.stimulus.lotto.height*blueProb; % bottom of blue bar

Y2occ=Y1+Data.stimulus.lotto.height*((1-Data.ambigs(trial))/2); % top of occluder
Y3occ=Y2occ+Data.stimulus.lotto.height*((Data.ambigs(trial))); % bottom of occluder

Screen(Win.win, 'FillRect', 1  ); % what does 1 mean here??????????????????????????
lottoRedDims=[W/2-Data.stimulus.lotto.width/2, Y1, W/2+Data.stimulus.lotto.width/2, Y2]; % dimension of red bar
Screen(Win.win,'FillRect',[255 0 0],lottoRedDims);
lottoBlueDims=[W/2-Data.stimulus.lotto.width/2, Y2, W/2+Data.stimulus.lotto.width/2, Y3];
Screen(Win.win,'FillRect',[0 0 255],lottoBlueDims);
lottoAmbigDims=[W/2-Data.stimulus.occ.width/2, Y2occ, W/2+Data.stimulus.occ.width/2, Y3occ];
Screen(Win.win,'FillRect',[127 127 127],lottoAmbigDims);

% specify medical improvement level
if Data.vals(trial) == 5
    medlevel1 = 'slight';
    medlevel2 = 'improvement';
    imgTexture = Img.slTexture;
elseif Data.vals(trial) == 8
    medlevel1 = 'moderate';
    medlevel2 = 'improvement';
    imgTexture = Img.mdTexture;
elseif Data.vals(trial) == 12
    medlevel1 = 'major';
    medlevel2 = 'improvement';
    imgTexture = Img.mjTexture;
elseif Data.vals(trial) == 25
    medlevel1 = 'recovery';
    imgTexture = Img.rcvTexture;
end

% Wirite text of value and probability
if strcmp(Data.colorKey{Data.colors(trial)},'blue') % blue trial, down
    Screen('TextSize', Win.win, Data.stimulus.fontSize.lotteryValues);
    if strcmp(medlevel1,'recovery')==0;
        medlevel1Dims = getTextDims(Win.win,medlevel1,Data.stimulus.fontSize.lotteryValues);
        Screen('DrawText', Win.win, medlevel1,W/2-medlevel1Dims(1)/2, Y3+10, Data.stimulus.fontColor); 
        medlevel2Dims = getTextDims(Win.win,medlevel2,Data.stimulus.fontSize.lotteryValues);
        Screen('DrawText', Win.win, medlevel2,W/2-medlevel2Dims(1)/2, Y3+10+medlevel1Dims(2), Data.stimulus.fontColor); 
        Screen('DrawTexture',Win.win,imgTexture,[],[W/2-Img.imgWidth/2,Y3+10+medlevel1Dims(2)+medlevel2Dims(2),W/2+Img.imgWidth/2,Y3+10+medlevel1Dims(2)+medlevel2Dims(2)+Img.imgHeight])
    else
        medlevel1Dims = getTextDims(Win.win,medlevel1,Data.stimulus.fontSize.lotteryValues);
        Screen('DrawText', Win.win, medlevel1,W/2-medlevel1Dims(1)/2, Y3+10, Data.stimulus.fontColor); 
        Screen('DrawTexture',Win.win,imgTexture,[],[W/2-Img.imgWidth/2,Y3+10+medlevel1Dims(2),W/2+Img.imgWidth/2,Y3+10+medlevel1Dims(2)+Img.imgHeight])
    end
    nulllevelDims = getTextDims(Win.win,'no effect',Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Win.win, 'no effect',W/2-nulllevelDims(1)/2, Y1-10-nulllevelDims(2), Data.stimulus.fontColor); % no effect
    Screen('DrawTexture',Win.win,Img.noeffTexture,[],[W/2-Img.imgWidth/2,Y1-10-nulllevelDims(2)-Img.imgHeight,W/2+Img.imgWidth/2,Y1-10-nulllevelDims(2)])
    Screen('TextSize', Win.win, Data.stimulus.fontSize.probabilities);
    if Data.ambigs(trial)==0
        Screen('Drawtext', Win.win, sprintf('%s',num2str(blueProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y2+(Y3-Y2)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('Drawtext', Win.win, sprintf('%s',num2str(redProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    else
        Screen('Drawtext', Win.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y3occ+(Y3-Y3occ)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('Drawtext', Win.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2occ-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    end
elseif strcmp(Data.colorKey{Data.colors(trial)},'red') %red trial, up
    Screen('TextSize', Win.win, Data.stimulus.fontSize.lotteryValues);
    if strcmp(medlevel1,'recovery')==0;
        medlevel2Dims = getTextDims(Win.win,medlevel2,Data.stimulus.fontSize.lotteryValues);
        Screen('DrawText', Win.win, medlevel2,W/2-medlevel2Dims(1)/2, Y1-10-medlevel2Dims(2), Data.stimulus.fontColor); 
        medlevel1Dims = getTextDims(Win.win,medlevel1,Data.stimulus.fontSize.lotteryValues);
        Screen('DrawText', Win.win, medlevel1,W/2-medlevel1Dims(1)/2, Y1-10-medlevel2Dims(2)-medlevel1Dims(2), Data.stimulus.fontColor);
        Screen('DrawTexture',Win.win,imgTexture,[],[W/2-Img.imgWidth/2,Y1-10-medlevel2Dims(2)-medlevel1Dims(2)-Img.imgHeight,W/2+Img.imgWidth/2,Y1-10-medlevel2Dims(2)-medlevel1Dims(2)]);
    else
        medlevel1Dims = getTextDims(Win.win,medlevel1,Data.stimulus.fontSize.lotteryValues);
        Screen('DrawText', Win.win, medlevel1,W/2-medlevel1Dims(1)/2, Y1-10-medlevel1Dims(2), Data.stimulus.fontColor);
        Screen('DrawTexture',Win.win,imgTexture,[],[W/2-Img.imgWidth/2,Y1-10-medlevel1Dims(2)-Img.imgHeight,W/2+Img.imgWidth/2,Y1-10-medlevel1Dims(2)]);
    end
    
    nulllevelDims = getTextDims(Win.win,'no effect',Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Win.win, 'no effect',W/2-nulllevelDims(1)/2, Y3+10, Data.stimulus.fontColor); % no effect
    Screen('DrawTexture',Win.win,Img.noeffTexture,[],[W/2-Img.imgWidth/2,Y3+10+nulllevelDims(2),W/2+Img.imgWidth/2,Y3+10+nulllevelDims(2)+Img.imgHeight])
    
%   DrawFormattedText(Win.win, medlevel,W/2-lotteryValueDims(1)/2, Y1-lotteryValueDims(2), Data.stimulus.fontColor);
%   DrawFormattedText(Win.win, 'No effect',W/2-Data.stimulus.textDims.lotteryValues.Digit1(1)/2, Y3, Data.stimulus.fontColor);
    Screen('TextSize', Win.win, Data.stimulus.fontSize.probabilities);
    if Data.ambigs(trial)==0
        Screen('Drawtext', Win.win, sprintf('%s',num2str(blueProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y2+(Y3-Y2)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('Drawtext', Win.win, sprintf('%s',num2str(redProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    else
        Screen('Drawtext', Win.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y3occ+(Y3-Y3occ)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('Drawtext', Win.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2occ-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    end
end

drawRefmed(Data,Win,Img)% need to change for medical situation
Screen('flip',Win.win);

% control lottory display time
elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime<Data.stimulus.lottoDisplayDur
    elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
end

% Draw green response cue, diameter=20
Screen('FillOval', Win.win, [0 255 0], [Win.winrect(3)/2-20 Win.winrect(4)/2-20 Win.winrect(3)/2+20 Win.winrect(4)/2+20]);
drawRefmed(Data,Win, Img)
Screen('flip',Win.win);

% Response time
Data.trialTime(trial).respStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime);
while elapsedTime<Data.stimulus.responseWindowDur % while the resposne time limit is not reached
    [keyisdown, secs, keyCode, deltaSecs] = KbCheck;
    if keyisdown && (keyCode(KbName('2@')) || keyCode(KbName('1!'))) % 1 or 2 is pressed
        elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime); % response time
        break
    end
    elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime); % response time again, why?????????????????????????????
end

% record response, and specify feedback drawing parameters
if keyisdown && keyCode(KbName('1!'))            %% Reversed keys '1' and '2' - DE
    Data.choice(trial)=1;
    Data.rt(trial)=elapsedTime;
    if Data.refSide==2 % if ref is on the right
        yellowDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        whiteDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    else
        yellowDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        whiteDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    end
    yellowColor=[255 255 0]; % yellow
elseif keyisdown && keyCode(KbName('2@'))        %% Reversed keys '2' and '1' - DE
    Data.choice(trial)=2;
    Data.rt(trial)=elapsedTime;
    if Data.refSide==2
        % how to calculate dims seems mysterious ??????????????????????????????????????
        whiteDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        yellowDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    else
        whiteDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        yellowDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    end
    Data.rt(trial)=elapsedTime;
    yellowColor=[255 255 0]; % yellow
else
    Data.choice(trial)=0;
    Data.rt(trial)=NaN;
    yellowColor=[255 255 255]; % white
    if Data.refSide==2
        whiteDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        yellowDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    else
        whiteDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        yellowDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    end
end

% draw response feedback. On the same side of the reference lottery.
Screen(Win.win,'FillRect',yellowColor,yellowDims);
Screen(Win.win,'FillRect',[255 255 255],whiteDims);
drawRefmed(Data,Win, Img)
Screen('flip',Win.win);

% control feedback display time
Data.trialTime(trial).feedbackStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
while elapsedTime<Data.stimulus.feedbackDur
    elapsedTime=etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
end

% draw ITI cue
Screen('FillOval', Win.win, [255 255 255], [Win.winrect(3)/2-20 Win.winrect(4)/2-20 Win.winrect(3)/2+20 Win.winrect(4)/2+20]);
drawRefmed(Data,Win, Img)
Screen('flip',Win.win);

% control ITI time
Data.trialTime(trial).ITIStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime<Data.stimulus.lottoDisplayDur+Data.stimulus.responseWindowDur+Data.stimulus.feedbackDur+Data.ITIs(trial)
    elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
end
end


%% draw lottery
function Data=drawLotto_LSRA(Data,trial,Win)
if strcmp(Data.colorKey{Data.colors(trial)},'blue')
    redProb=1-Data.probs(trial);
    blueProb=Data.probs(trial);
elseif strcmp(Data.colorKey{Data.colors(trial)},'red')
    redProb=Data.probs(trial);
    blueProb=1-Data.probs(trial);
end

H=Win.winrect(4);
W=Win.winrect(3);
Y1=(H-Data.stimulus.lotto.height)/2; % top of red 
Y2=Y1+Data.stimulus.lotto.height*redProb; % top of blue
Y3=Y2+Data.stimulus.lotto.height*blueProb; % bottom of blue

Y2occ=Y1+Data.stimulus.lotto.height*((1-Data.ambigs(trial))/2); % top of occ
Y3occ=Y2occ+Data.stimulus.lotto.height*((Data.ambigs(trial))); % bottom of occ

Screen(Win.win, 'FillRect', 1  );
lottoRedDims=[W/2-Data.stimulus.lotto.width/2, Y1, W/2+Data.stimulus.lotto.width/2, Y2];
Screen(Win.win,'FillRect',[255 0 0],lottoRedDims);
lottoBlueDims=[W/2-Data.stimulus.lotto.width/2, Y2, W/2+Data.stimulus.lotto.width/2, Y3];
Screen(Win.win,'FillRect',[0 0 255],lottoBlueDims);
lottoAmbigDims=[W/2-Data.stimulus.occ.width/2, Y2occ, W/2+Data.stimulus.occ.width/2, Y3occ];
Screen(Win.win,'FillRect',[127 127 127],lottoAmbigDims);
if strcmp(Data.colorKey{Data.colors(trial)},'blue')
    Screen('TextSize', Win.win, Data.stimulus.fontSize.lotteryValues);
    lotteryValueDims = getTextDims(Win.win, sprintf('$%s',num2str(Data.vals(trial))),Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Win.win, sprintf('$%s',num2str(Data.vals(trial))),W/2-lotteryValueDims(1)/2, Y3, Data.stimulus.fontColor);
    zeroValueDims = getTextDims(Win.win,'$0',Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Win.win, '$0',W/2-zeroValueDims(1)/2, Y1-zeroValueDims(2), Data.stimulus.fontColor);
    Screen('TextSize', Win.win, Data.stimulus.fontSize.probabilities);
    if Data.ambigs(trial)==0
        Screen('DrawText',Win.win, sprintf('%s',num2str(blueProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y2+(Y3-Y2)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('DrawText',Win.win, sprintf('%s',num2str(redProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    else
        Screen('DrawText',Win.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y3occ+(Y3-Y3occ)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('DrawText',Win.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2occ-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    end
elseif strcmp(Data.colorKey{Data.colors(trial)},'red')
    Screen('TextSize', Win.win, Data.stimulus.fontSize.lotteryValues);
    lotteryValueDims = getTextDims(Win.win, sprintf('$%s',num2str(Data.vals(trial))),Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Win.win, sprintf('$%s',num2str(Data.vals(trial))),W/2-lotteryValueDims(1)/2, Y1-lotteryValueDims(2), Data.stimulus.fontColor);
    zeroValueDims = getTextDims(Win.win,'$0',Data.stimulus.fontSize.lotteryValues);
    Screen('DrawText',Win.win, '$0',W/2-zeroValueDims(1)/2, Y3, Data.stimulus.fontColor);
    Screen('TextSize', Win.win, Data.stimulus.fontSize.probabilities);
    if Data.ambigs(trial)==0
        Screen('DrawText',Win.win, sprintf('%s',num2str(blueProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y2+(Y3-Y2)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('DrawText',Win.win, sprintf('%s',num2str(redProb*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    else
        Screen('DrawText',Win.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y3occ+(Y3-Y3occ)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
        Screen('DrawText',Win.win, sprintf('%s',num2str((1-Data.ambigs(trial))/2*100)),W/2-Data.stimulus.textDims.probabilities(1)/2, Y1+(Y2occ-Y1)/2-Data.stimulus.textDims.probabilities(2)/2, Data.stimulus.fontColor);
    end
end

drawRef(Data,Win)
Screen('flip',Win.win);

elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime<Data.stimulus.lottoDisplayDur
    elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
end

Screen('FillOval', Win.win, [0 255 0], [Win.winrect(3)/2-20 Win.winrect(4)/2-20 Win.winrect(3)/2+20 Win.winrect(4)/2+20]);
drawRef(Data,Win)
Screen('flip',Win.win);
Data.trialTime(trial).respStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime);
while elapsedTime<Data.stimulus.responseWindowDur
    [keyisdown, secs, keycode, deltaSecs] = KbCheck;
    if keyisdown && (keycode(KbName('2@')) || keycode(KbName('1!')))
        elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime);
        break
    end
    elapsedTime=etime(datevec(now),Data.trialTime(trial).respStartTime);
end

if keyisdown && keycode(KbName('1!'))            %% Reversed keys '1' and '2' - DE
    Data.choice(trial)=1;
    Data.rt(trial)=elapsedTime;
    if Data.refSide==2
        yellowDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        whiteDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    else
        yellowDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        whiteDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    end
    yellowColor=[255 255 0];
elseif keyisdown && keycode(KbName('2@'))        %% Reversed keys '2' and '1' - DE
    Data.choice(trial)=2;
    Data.rt(trial)=elapsedTime;
    if Data.refSide==2
        whiteDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        yellowDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    else
        whiteDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        yellowDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    end
    Data.rt(trial)=elapsedTime;
    yellowColor=[255 255 0];
else
    Data.choice(trial)=0;
    Data.rt(trial)=NaN;
    yellowColor=[255 255 255];
    if Data.refSide==2
        whiteDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        yellowDims=[.5*Win.winrect(3)/10 -100 .5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    else
        whiteDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[4.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 4.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
        yellowDims=[-.5*Win.winrect(3)/10 -100 -.5*Win.winrect(3)/10 -100]+[5.5*Win.winrect(3)/10-20 Win.winrect(4)/2-20 5.5*Win.winrect(3)/10+20 Win.winrect(4)/2+20];
    end
end
Screen(Win.win,'FillRect',yellowColor,yellowDims);
Screen(Win.win,'FillRect',[255 255 255],whiteDims);
drawRef(Data,Win)
Screen('flip',Win.win);

Data.trialTime(trial).feedbackStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
while elapsedTime<Data.stimulus.feedbackDur
    elapsedTime=etime(datevec(now),Data.trialTime(trial).feedbackStartTime);
end

Screen('FillOval', Win.win, [255 255 255], [Win.winrect(3)/2-20 Win.winrect(4)/2-20 Win.winrect(3)/2+20 Win.winrect(4)/2+20]);
drawRef(Data,Win)
Screen('flip',Win.win);

Data.trialTime(trial).ITIStartTime=datevec(now);
elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
while elapsedTime<Data.stimulus.lottoDisplayDur+Data.stimulus.responseWindowDur+Data.stimulus.feedbackDur+Data.ITIs(trial)
    elapsedTime=etime(datevec(now),Data.trialTime(trial).trialStartTime);
end
end

%% function to set text and rectangle parameters
function params = setParams_LSRAmed; 
params.fontName='Ariel';
params.fontColor=[255 255 255]; % white
% font of probability inside the rectangle
params.fontSize.probabilities=20;
% params.textDims.probabilities=[31 30];
% params.fontSize.refProbabilities=10;
% params.textDims.refProbabilities=[12 19];

params.fontSize.pause=38;

% font of lottery values
% textDims, [width height]
params.fontSize.lotteryValues=18;
% params.textDims.lotteryValues.Digit1=[64 64];
% params.textDims.lotteryValues.Digit2=[92 64];
% params.textDims.lotteryValues.Digit3=[120 64];

%font of reference
params.fontSize.refValues=18;
% params.textDims.refValues.Digit1=[31 30];
% params.textDims.refValues.Digit2=[42 30];

% rectangle size
params.lotto.width=150;
params.lotto.height=300;
% params.ref.width=50;
% params.ref.height=100;
params.occ.width=170;

end
%% function to set text and rectangle parameters
function params = setParams_LSRA; 
params.fontName='Ariel';
params.fontColor=[255 255 255]; % white

% font of probability inside the rectangle
params.fontSize.probabilities=20;
% params.textDims.probabilities=[31 30];
% params.fontSize.refProbabilities=10;
% params.textDims.refProbabilities=[12 19];

params.fontSize.pause=38;

% font of lottery values
% textDims, [width height]
params.fontSize.lotteryValues=42;
% params.textDims.lotteryValues.Digit1=[64 64];
% params.textDims.lotteryValues.Digit2=[92 64];
% params.textDims.lotteryValues.Digit3=[120 64];

%font of reference
params.fontSize.refValues=42;
% params.textDims.refValues.Digit1=[31 30];
% params.textDims.refValues.Digit2=[42 30];

% rectangle size
params.lotto.width=150;
params.lotto.height=300;
% params.ref.width=50;
% params.ref.height=100;
params.occ.width=170;
end

%% Function to get text dimensions
function textDims = getTextDims(win,myText,textSize)
Screen('TextSize',win,textSize);
textRect = Screen ('TextBounds',win,myText);
textDims = [textRect(3) textRect(4)]; % text width and height
end

%% function to draw reference "slight improvement"
function drawRefmed(Data,Win,Img)
H=Win.winrect(4);
W=Win.winrect(3);
if Data.refSide==1 % reference on left
    refDims.x=W/4;
elseif Data.refSide==2 % reference on right
    refDims.x=3*(W/4);
end
refDims.y=H/4;
Screen('TextSize', Win.win, Data.stimulus.fontSize.refValues);
slightDims = getTextDims(Win.win, 'slight', Data.stimulus.fontSize.refValues);
improvDims = getTextDims(Win.win, 'improvement', Data.stimulus.fontSize.refValues);
refHeight = Img.imgHeight+slightDims(2)+improvDims(2);
refimgRect = [refDims.x-Img.imgWidth/2, refDims.y-refHeight/2, refDims.x+Img.imgWidth/2,refDims.y-refHeight/2+Img.imgWidth];
Screen('DrawTexture',Win.win,Img.slTexture,[],refimgRect);
Screen('DrawText', Win.win, 'slight',refDims.x-slightDims(1)/2, refDims.y-refHeight/2+Img.imgWidth, Data.stimulus.fontColor);
Screen('DrawText', Win.win, 'improvement',refDims.x-improvDims(1)/2, refDims.y-refHeight/2+Img.imgWidth+slightDims(2), Data.stimulus.fontColor);
end

%% function to draw reference $5
function drawRef(Data,Win)
H=Win.winrect(4);
W=Win.winrect(3);
if Data.refSide==1 % reference on left
    refDims.x=W/4;
elseif Data.refSide==2 % reference on right
    refDims.x=3*(W/4);
end
refDims.y=H/4;
Screen('TextSize', Win.win, Data.stimulus.fontSize.refValues);
fiveDims = getTextDims(Win.win,'$5',Data.stimulus.fontSize.refValues);
Screen('DrawText',Win.win, '$5',refDims.x-fiveDims(1)/2, refDims.y-fiveDims(2)/2, Data.stimulus.fontColor);
end


%% function to wait for start key-number 5
function waitForBackTick;
while 1 % always true
    [keyisdown, secs, keyCode, deltaSecs] = KbCheck; % no need to indicate device number????
    % [keyIsDown, secs, keyCode, deltaSecs] = KbCheck([deviceNumber])
    if keyisdown && keyCode(KbName('5%'))==1 % check if 5 is pressed
        break
    end
end
end

%% add Data.Summary
function Data=experimentSummary(Data)
block=1;
trial=1;
for t=1:Data.numTrials
        %choice
        if Data.choice(t)==1 && Data.refSide==2
            Data.Summary(block,trial).choice='Lottery';
        elseif Data.choice(t)==2 && Data.refSide==1
            Data.Summary(block,trial).choice='Lottery';
        elseif Data.choice(t)==0
            Data.Summary(block,trial).choice='None';
        else
            Data.Summary(block,trial).choice='Reference';
        end
        
        % bag number
        % first risk, then ambig, so that ambig trials with p=0.5 will be overitten
        if Data.probs(t)==.5
            Data.Summary(block,trial).bagNumber=4;
        elseif Data.probs(t)==.25 && Data.colors(t)==1
            Data.Summary(block,trial).bagNumber=3;
        elseif Data.probs(t)==.25 && Data.colors(t)==2
            Data.Summary(block,trial).bagNumber=5;
        elseif Data.probs(t)==.75 && Data.colors(t)==1
            Data.Summary(block,trial).bagNumber=5;
        elseif Data.probs(t)==.75 && Data.colors(t)==2
            Data.Summary(block,trial).bagNumber=3;
        end

        if Data.ambigs(t)==.24
            Data.Summary(block,trial).bagNumber=10;
        elseif Data.ambigs(t)==.5
            Data.Summary(block,trial).bagNumber=11;
        elseif Data.ambigs(t)==.74
            Data.Summary(block,trial).bagNumber=12;
        end

        if Data.colors(t)==1
            Data.Summary(block,trial).blueValue=sprintf('$%s',num2str(Data.vals(t)));
            Data.Summary(block,trial).redValue='$0';
        elseif Data.colors(t)==2
            Data.Summary(block,trial).redValue=sprintf('$%s',num2str(Data.vals(t)));
            Data.Summary(block,trial).blueValue='$0';
        end
    
    if trial ~=20
        trial=trial+1;
    else
        trial=1;
        block=block+1;
    end
end
end

%%
function Data=experimentSummaryMed(Data)
block=1;
trial=1;
for t=1:Data.numTrials
        if Data.choice(t)==1 && Data.refSide==2
            Data.Summary(block,trial).choice='Experimental treatment';
        elseif Data.choice(t)==2 && Data.refSide==1
            Data.Summary(block,trial).choice='Experimental treatment';
        elseif Data.choice(t)==0
            Data.Summary(block,trial).choice='None';
        else
            Data.Summary(block,trial).choice='Conservative treatment: Slight improvement';
        end

        if Data.probs(t)==.5
            Data.Summary(block,trial).bagNumber=4;
        elseif Data.probs(t)==.25 && Data.colors(t)==1
            Data.Summary(block,trial).bagNumber=3;
        elseif Data.probs(t)==.25 && Data.colors(t)==2
            Data.Summary(block,trial).bagNumber=5;
        elseif Data.probs(t)==.75 && Data.colors(t)==1
            Data.Summary(block,trial).bagNumber=5;
        elseif Data.probs(t)==.75 && Data.colors(t)==2
            Data.Summary(block,trial).bagNumber=3;
        end

        if Data.ambigs(t)==.24
            Data.Summary(block,trial).bagNumber=10;
        elseif Data.ambigs(t)==.5
            Data.Summary(block,trial).bagNumber=11;
        elseif Data.ambigs(t)==.74
            Data.Summary(block,trial).bagNumber=12;
        end

        if Data.vals(t)==5
            if Data.colors(t)==1
                Data.Summary(block,trial).blueValue=sprintf('slight improvement');
                Data.Summary(block,trial).redValue='no effect';
            elseif Data.colors(t)==2
                Data.Summary(block,trial).redValue=sprintf('slight improvement');
                Data.Summary(block,trial).blueValue='no effect';
            end
        elseif Data.vals(t) ==8
             if Data.colors(t)==1
                Data.Summary(block,trial).blueValue=sprintf('moderate improvement');
                Data.Summary(block,trial).redValue='no effect';
            elseif Data.colors(t)==2
                Data.Summary(block,trial).redValue=sprintf('moderate improvement');
                Data.Summary(block,trial).blueValue='no effect';
            end
         elseif Data.vals(t) ==12
             if Data.colors(t)==1
                Data.Summary(block,trial).blueValue=sprintf('major improvement');
                Data.Summary(block,trial).redValue='no effect';
            elseif Data.colors(t)==2
                Data.Summary(block,trial).redValue=sprintf('major improvement');
                Data.Summary(block,trial).blueValue='no effect';
            end
         elseif Data.vals(t) ==25
             if Data.colors(t)==1
                Data.Summary(block,trial).blueValue=sprintf('recovery');
                Data.Summary(block,trial).redValue='no effect';
            elseif Data.colors(t)==2
                Data.Summary(block,trial).redValue=sprintf('recovery');
                Data.Summary(block,trial).blueValue='no effect';
            end
        end 
        
    if trial ~=20
        trial=trial+1;
    else
        trial=1;
        block=block+1;
    end
end
end
