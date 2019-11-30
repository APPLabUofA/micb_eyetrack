function EEG = reject_trials_inspect(EEG,part_name,exp,rejtrial)

i_set = 1; %code changed so now always 3

%only when using this specific settings
if strcmpi(exp.settingname,'byFix_v4') || strcmpi(exp.settingname,'byFix_v5')  
    
    if strcmpi(part_name,'015') 
%         EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        rejtrial(i_set,3).ids = [];
%         EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
    
    elseif strcmpi(part_name,'016')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(83)=1;
        EEG.reject.rejthresh(144)=1;
        EEG.reject.rejthresh(174:175)=1;
        EEG.reject.rejthresh(199)=1;
        EEG.reject.rejthresh(221)=1;
        EEG.reject.rejthresh(283)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'017') 
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(112)=1;
        EEG.reject.rejthresh(116)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'018')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(5)=1;
        EEG.reject.rejthresh(8)=1;
        EEG.reject.rejthresh(42)=1;
        EEG.reject.rejthresh(187)=1;
        EEG.reject.rejthresh(254)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);  

    elseif strcmpi(part_name,'019')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(41)=1;
        EEG.reject.rejthresh(118)=1;
        EEG.reject.rejthresh(135:136)=1;
        EEG.reject.rejthresh(155)=1;
        EEG.reject.rejthresh(200:201)=1;
        EEG.reject.rejthresh(206)=1;
        EEG.reject.rejthresh(241)=1;
        EEG.reject.rejthresh(256)=1;
        EEG.reject.rejthresh(262)=1;
        EEG.reject.rejthresh(270)=1;
        EEG.reject.rejthresh(279:280)=1;
        EEG.reject.rejthresh(283)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'020')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(49)=1;
        EEG.reject.rejthresh(127)=1;
        EEG.reject.rejthresh(141)=1;
        EEG.reject.rejthresh(143)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    

    elseif strcmpi(part_name,'021')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(145)=1;
        EEG.reject.rejthresh(254)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'022')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(127)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'023')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(5)=1;
        EEG.reject.rejthresh(10)=1;
        EEG.reject.rejthresh(47:48)=1;
        EEG.reject.rejthresh(52)=1;
        EEG.reject.rejthresh(85)=1;
        EEG.reject.rejthresh(131:132)=1;
        EEG.reject.rejthresh(139)=1;
        EEG.reject.rejthresh(143)=1;
        EEG.reject.rejthresh(149:150)=1;
        EEG.reject.rejthresh(171)=1;
        EEG.reject.rejthresh(186)=1;
        EEG.reject.rejthresh(244:245)=1;
        EEG.reject.rejthresh(265)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'024')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(5)=1;
        EEG.reject.rejthresh(231)=1;
        EEG.reject.rejthresh(259)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'025') 
%         EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        rejtrial(i_set,3).ids = [];
%         EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
    
    elseif strcmpi(part_name,'026') 
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(69)=1;
        EEG.reject.rejthresh(102)=1;
        EEG.reject.rejthresh(163)=1;
        EEG.reject.rejthresh(184)=1;
        EEG.reject.rejthresh(242)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    

    elseif strcmpi(part_name,'027')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(54:55)=1;
        EEG.reject.rejthresh(138:139)=1;
        EEG.reject.rejthresh(150)=1;
        EEG.reject.rejthresh(212)=1;
        EEG.reject.rejthresh(242)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    

    elseif strcmpi(part_name,'028') 
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(30)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'030') 
%         EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        rejtrial(i_set,3).ids = [];
%         EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
    
    elseif strcmpi(part_name,'031') 
%         EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        rejtrial(i_set,3).ids = [];
%         EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
    
    elseif strcmpi(part_name,'032')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(33)=1;
        EEG.reject.rejthresh(41)=1;
        EEG.reject.rejthresh(47)=1;
        EEG.reject.rejthresh(59)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'033')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(6)=1;
        EEG.reject.rejthresh(13)=1;
        EEG.reject.rejthresh(25)=1;
        EEG.reject.rejthresh(32:33)=1;
        EEG.reject.rejthresh(70)=1;
        EEG.reject.rejthresh(85)=1;
        EEG.reject.rejthresh(137)=1;
        EEG.reject.rejthresh(165)=1;
        EEG.reject.rejthresh(186)=1;
        EEG.reject.rejthresh(219)=1;
        EEG.reject.rejthresh(228)=1;
        EEG.reject.rejthresh(238)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'034') 
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(30)=1;
        EEG.reject.rejthresh(37:38)=1;
        EEG.reject.rejthresh(45)=1;
        EEG.reject.rejthresh(77)=1;
        EEG.reject.rejthresh(94:95)=1;
        EEG.reject.rejthresh(97)=1;
        EEG.reject.rejthresh(103)=1;
        EEG.reject.rejthresh(110)=1;
        EEG.reject.rejthresh(114:115)=1;
        EEG.reject.rejthresh(117:118)=1;
        EEG.reject.rejthresh(143)=1;
        EEG.reject.rejthresh(160)=1;
        EEG.reject.rejthresh(178:179)=1;
        EEG.reject.rejthresh(188:190)=1;
        EEG.reject.rejthresh(233)=1;
        EEG.reject.rejthresh(241)=1;
        EEG.reject.rejthresh(263:264)=1;
        EEG.reject.rejthresh(270:271)=1;
        EEG.reject.rejthresh(275:278)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'035')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(1)=1;
        EEG.reject.rejthresh(95)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'036')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(14)=1;
        EEG.reject.rejthresh(46)=1;
        EEG.reject.rejthresh(76)=1;
        EEG.reject.rejthresh(87)=1;
        EEG.reject.rejthresh(97)=1;
        EEG.reject.rejthresh(159)=1;
        EEG.reject.rejthresh(187)=1;
        EEG.reject.rejthresh(231:232)=1;
        EEG.reject.rejthresh(284:285)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'037')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(50)=1;
        EEG.reject.rejthresh(57:58)=1;
        EEG.reject.rejthresh(61)=1;
        EEG.reject.rejthresh(126)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);

    elseif strcmpi(part_name,'038')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(63)=1;
        EEG.reject.rejthresh(65)=1;
        EEG.reject.rejthresh(144)=1;
        EEG.reject.rejthresh(149)=1;
        EEG.reject.rejthresh(270)=1;
        EEG.reject.rejthresh(281)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);  
        
    elseif strcmpi(part_name,'040')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(45)=1;
        EEG.reject.rejthresh(120)=1;
        EEG.reject.rejthresh(193)=1;
        EEG.reject.rejthresh(220)=1;
        EEG.reject.rejthresh(222)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);   
        
    elseif strcmpi(part_name,'041') 
        %consider removing F4 electrode
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(64)=1;
        EEG.reject.rejthresh(85)=1;
        EEG.reject.rejthresh(91)=1;
        EEG.reject.rejthresh(104:105)=1;
        EEG.reject.rejthresh(133)=1;
        EEG.reject.rejthresh(157:158)=1;
        EEG.reject.rejthresh(70:171)=1;
        EEG.reject.rejthresh(174)=1;
        EEG.reject.rejthresh(183)=1;
        EEG.reject.rejthresh(185)=1;
        EEG.reject.rejthresh(192)=1;
        EEG.reject.rejthresh(160)=1;
        EEG.reject.rejthresh(210)=1;
        EEG.reject.rejthresh(217)=1;
        EEG.reject.rejthresh(241)=1;
        EEG.reject.rejthresh(280)=1;
        EEG.reject.rejthresh(288)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    
    
    elseif strcmpi(part_name,'042')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(49:50)=1;
        EEG.reject.rejthresh(97:98)=1;
        EEG.reject.rejthresh(145:148)=1;
        EEG.reject.rejthresh(193)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);     
    
    elseif strcmpi(part_name,'043')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(31)=1;
        EEG.reject.rejthresh(92)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    
    
    elseif strcmpi(part_name,'044')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(135)=1;
        EEG.reject.rejthresh(189)=1;
        EEG.reject.rejthresh(216)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    
        
    elseif strcmpi(part_name,'045')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(46)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);     
        
    elseif strcmpi(part_name,'046')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(10)=1;
        EEG.reject.rejthresh(83)=1;
        EEG.reject.rejthresh(190)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);   
    
    elseif strcmpi(part_name,'047')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(37)=1;
        EEG.reject.rejthresh(79)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);       
        
    elseif strcmpi(part_name,'048') 
%         EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        rejtrial(i_set,3).ids = [];
%         EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
    
    elseif strcmpi(part_name,'049') 
%         EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        rejtrial(i_set,3).ids = [];
%         EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
    
    elseif strcmpi(part_name,'050')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(1)=1;
        EEG.reject.rejthresh(33)=1;
        EEG.reject.rejthresh(49)=1;
        EEG.reject.rejthresh(81)=1;
        EEG.reject.rejthresh(97)=1;
        EEG.reject.rejthresh(122)=1;
        EEG.reject.rejthresh(133)=1;
        EEG.reject.rejthresh(152)=1;
        EEG.reject.rejthresh(188)=1;
        EEG.reject.rejthresh(193:194)=1;
        EEG.reject.rejthresh(241)=1;
        EEG.reject.rejthresh(243)=1;
        EEG.reject.rejthresh(276)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);
        
     elseif strcmpi(part_name,'051')
        EEG.reject.rejthresh = zeros(size(EEG.reject.rejthresh)); %reset variable to all 0s
        EEG.reject.rejthresh(18)=1;
        EEG.reject.rejthresh(96:97)=1;
        EEG.reject.rejthresh(124:126)=1;
        EEG.reject.rejthresh(139)=1;
        EEG.reject.rejthresh(143:146)=1;
        EEG.reject.rejthresh(149)=1;
        EEG.reject.rejthresh(187:188)=1;
        EEG.reject.rejthresh(192:196)=1;
        EEG.reject.rejthresh(212)=1;
        EEG.reject.rejthresh(233:234)=1;
        EEG.reject.rejthresh(238)=1;
        EEG.reject.rejthresh(241)=1;
        EEG.reject.rejthresh(255)=1;
        EEG.reject.rejthresh(281:283)=1;
        rejtrial(i_set,3).ids = find(EEG.reject.rejthresh==1);
        EEG = pop_rejepoch(EEG,EEG.reject.rejthresh,0);    
    
    end
% ````````````````````````````````````````````````````````````````````````````````````````````
% ````````````````````````````````````````````````````````````````````````````````````````````   
end
% ````````````````````````````````````````````````````````````````````````````````````````````
% ````````````````````````````````````````````````````````````````````````````````````````````


% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% save rejected trials
EEG.rejtrial = rejtrial;
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::














