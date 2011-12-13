function [output] = run(filename, framecount, bb)
    persistent tld;
	
    % initialization
    if framecount < 2
        framecount = 2;
        opt.source          = struct('camera',1,'input','D:/Dev/Mobile/OpenTLD/data','bb0',[]);
        opt.output          = '_output/'; mkdir(opt.output); % output directory that will contain bounding boxes + confidence

        min_win             = 24; % minimal size of the object's bounding box in the scanning griopt.source.camerad, it may significantly influence speed of TLD, set it to minimal size of the object
        patchsize           = [15 15]; % size of normalized patch in the object detector, larger sizes increase discriminability, must be square
        fliplr              = 0; % if set to one, the model automatically learns mirrored versions of the object
        maxbbox             = 1; % fraction of evaluated bounding boxes in every frame, maxbox = 0 means detector is truned off, if you don't care about speed set it to 1
        update_detector     = 1; % online learning on/off, of 0 detector is trained only in the first frame and then remains fixed
        opt.plot            = struct('pex',1,'nex',1,'dt',1,'confidence',1,'target',1,'replace',0,'drawoutput',3,'draw',0,'pts',1,'help', 0,'patch_rescale',1,'save',0); 

        % Do-not-change -----------------------------------------------------------

        opt.model           = struct('min_win',min_win,'patchsize',patchsize,'fliplr',fliplr,'ncc_thesame',0.95,'valid',0.5,'num_trees',10,'num_features',13,'thr_fern',0.5,'thr_nn',0.65,'thr_nn_valid',0.7);
        opt.p_par_init      = struct('num_closest',10,'num_warps',20,'noise',5,'angle',20,'shift',0.02,'scale',0.02); % synthesis of positive examples during initialization
        opt.p_par_update    = struct('num_closest',10,'num_warps',10,'noise',5,'angle',10,'shift',0.02,'scale',0.02); % synthesis of positive examples during update
        opt.n_par           = struct('overlap',0.2,'num_patches',100); % negative examples initialization/update
        opt.tracker         = struct('occlusion',10);
        opt.control         = struct('maxbbox',maxbbox,'update_detector',update_detector,'drop_img',1,'repeat',1);

        opt.source.idx    = 1:10000; 
        
        %f = figure(2); set(2, 'KeyPressFcn', @handleKey);
        
        % init first image and bounding box
        opt.source.im0  = img_alloc(filename);
%         bb = dlmread([opt.source.input '/init.txt']);
        opt.source.bb = bb(:);

        
        tld = tldInit(opt,[]); % train initial detector and initialize the 'tld' structure
        tld = tldDisplay(0,tld); % initialize display
    end
    
    tld = tldProcessFrame(tld,framecount,filename); % process frame i
    tldDisplay(1,tld,framecount); % display results on frame i
    output = tld.bb(:, framecount);
end