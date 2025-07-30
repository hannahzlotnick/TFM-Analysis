    clearvars -except ini_path
close all
scrsz = get(0,'ScreenSize');

escape=0;
dataOutput=[];

%%Open first .jpg image
[filename, pathname, filterindex] = uigetfile('*.jpg', 'Open Cell Image');
ini_path=pathname;

%%Initialize counter for cells/image number
cell_num = 0;

while escape==0
cell_num = cell_num + 1;
disp(cell_num);
close all

%%Extract num
%extract_num = regexp(filename, '\d+', 'match');  % Find one or more digits
%extract_num = str2double(extract_num{1});  % Convert the matched string to a number
%disp(extract_num);


extract_num = regexp(filename, '_(\d+)', 'tokens');  % Match digits after the last underscore

% Check if a match was found
if ~isempty(extract_num)
    extract_num = str2double(extract_num{end}{1});  % Extract the number from the last match and convert
    disp(extract_num);  % Display the number
else
    disp('No match found');
end


name = strcat(pathname,filename);
I = imread(name);
    orig=I;
    Hfig=figure;
    temp=get(gcf,'Position');
    set(gcf,'Name',['Cell # ' extract_num],'Position',[scrsz(3)/2 - temp(3)-150 temp(2:4)])
    imshow(I);
    
%Show Force Data as Guide
    data=dlmread(fullfile(pathname,strcat('Traction_PIV_Stack',num2str(extract_num),'.txt')));
    disp(extract_num);

x = reshape(data(:,1),60,60)'; %Might need to alter 60, 60 based on slots in matrix. This works for 3600.
y = reshape(data(:,2),60,60)';
z = reshape(data(:,5),60,60)'; 
X=x;
Y=y;
Z=z;

gridS=(max(max(x))-min(min(x)))/(length(x)-1);

Traction_x = reshape(data(:,3),60,60)'; 
Traction_y = reshape(data(:,4),60,60)'; 

%952px=59 %968px=60 %984px=61 %1000px=62

hFig = figure(2);
imshow(I);
temp=get(gcf,'Position');
set(hFig, 'Position', [scrsz(3)/2 temp(2:4)])

set(gca,'Ydir','normal')

hold off
 surf(x,y,z) ,view(0, 270)
 colormap(jet)
    
figure(Hfig)
    message = sprintf('Left click and hold to begin drawing the outline of the cell.\nSimply lift the mouse button to finish');
uiwait(msgbox(message));
cellOut = drawfreehand();
    binaryImage1 = cellOut.createMask();
    labeledBinary = bwlabel(binaryImage1);
    imshow(binaryImage1);
    cellAreaP = sum(binaryImage1(:));
    cellArea = cellAreaP*0.04696;  % um^2
structBoundaries = bwboundaries(binaryImage1); 
xy=structBoundaries{1};
props = regionprops(labeledBinary, 'centroid');
centroid=props.Centroid;
Num_x = xy(:, 2); % Columns.
Num_y = xy(:, 1); % Rows.


Num_x2=Num_x;
Num_y2=Num_y;
dilatedMask1 = poly2mask(Num_x2,Num_y2,1216,1920);

labeledDilatedMask = bwlabel(dilatedMask1);
props2 = regionprops(labeledDilatedMask, 'centroid');
centroid2=props2.Centroid;

trans_x=centroid2(1,1)-centroid(1,1);
trans_y=centroid2(1,2)-centroid(1,2);

 Num_x2=Num_x2-trans_x;
 Num_y2=Num_y2-trans_y;

 hold on
%plot(Num_x, Num_y, 'r','LineWidth', 2);
plot(Num_x2, Num_y2, 'b','LineWidth', 2);
burnedImage=I;
hold off
% close all


%% USE TRACTION FORCE DATA

% data=dlmread(fullfile(pathname,strcat('Traction_PIV_',header,'_cell',cell_num,'_stack.txt')));
% %data=dlmread(strcat('Traction_PIV_',header,'_',cell_num,'_stack.txt'));
% 
% %(_,??,??)= ?? are How many unique slots are in matrix 
% 
% x = reshape(data(:,1),62,62)';
% y = reshape(data(:,2),62,62)';
% z = reshape(data(:,5),62,62)'; 
% 
% Traction_x = reshape(data(:,3),62,62)'; 
% Traction_y = reshape(data(:,4),62,62)'; 
% 
% %952px=59 %968px=60 %984px=61 %1000px=62
% 
% colormap(jet)
% hFig = figure(2);
% set(hFig, 'Position', [10 10 600 600])
%  surf(x,y,z) ,view(0, 270)

figure(hFig)
 hold on
% 
%surf(x,y,z) ,view(90, 0)
ht = plot(Num_x2, Num_y2, 'w','LineWidth', 2);
% picsave=strcat(filename(1:end-4), '_outlined.jpg');
% print('-dtiff','-r300',picsave);
    message = sprintf('Left click and hold to begin drawing. Can go outside image.\nSimply lift the mouse button to finish');
uiwait(msgbox(message));
Tbound=imfreehand();
% binaryImage = Tbound.createMask();

vFig=figure('Visible','off');
Ifig=imshow(I);
binaryImage2 = createMask(Tbound,Ifig);
close(vFig)

structBoundaries = bwboundaries(binaryImage2); 
Txy=structBoundaries{1};
TNum_x = Txy(:, 2); % Columns.
TNum_y = Txy(:, 1); % Rows.
% dilatedMask2 = poly2mask(TNum_x,TNum_y,1024,1024);
Fmask = binaryImage1;
ind = (binaryImage2 ~= 0);
Fmask(ind) = binaryImage2(ind);
AreaT = sum(Fmask(:));
AreaT = AreaT*0.04696;  % um^2

structBoundaries = bwboundaries(Fmask); 
Fxy=structBoundaries{1};
FNum_x = Fxy(:, 2); % Columns.
FNum_y = Fxy(:, 1); % Rows.
% FNum_x = xy(:, 2); % Columns.
% FNum_y = xy(:, 1); % Rows.

hold off
surf(x,y,z) ,view(0, 270)
hold on
plot(FNum_x, FNum_y, 'w','LineWidth', 2);


% in1 = inpolygon(x,y,Num_x2,Num_y2);
% in2 = inpolygon(x,y,TNum_x,TNum_y);
% in =  union(in1,in2);

in = inpolygon(x,y,FNum_x,FNum_y);
in=double(in);
in=reshape(in,1,3600)';


z = reshape(z,1,3600)'; 
Traction_x = reshape(Traction_x,1,3600)'; 
Traction_y = reshape(Traction_y,1,3600)'; 

total=0;
avg_count=0;
in_count=0;
F = nan(size(z));

for count=1:1:length(in) 
    
    if(in(count,1)==0)
        Traction_x(count,1)=0;
        Traction_y(count,1)=0;
        z(count,1)=0;
        F(count,1)=0;
    else
        in_count=in_count+1;
        F(count,1)=z(count,1)*gridS^2*0.04696*1e-12;   % N, note that this is dependent on resolution and grid size
    end
end

% Read displacement data for strain energy
Dispdata=dlmread(fullfile(pathname,strcat('PIV_Stack',num2str(extract_num),'.txt')));
disp=Dispdata(:,5)*0.2167*1e-6;     % in meters
FD=0;


for count=1:1:length(z) 
    total=z(count,1)+total;
    FD=F(count,1)*disp(count,1) + FD;
    if(z(count,1)>0)
        avg_count=avg_count+1;
    end
end

% totalForceOld = ((total/avg_count)* cellArea)/1000;
% totalForce = ((total/avg_count)* AreaT)/1000;       % Avg traction stress times total area from ROI where tractions are calculated
totalForce = sum(F)*1e9;
AvgT = totalForce*1e-9/(cellArea*1e-12);
energy = FD/2*1e12;  % pJ
SurfTens = energy*1e-12/(cellArea*1e-12);  % J/m^2 or N/m

sampled = imresize(Fmask,[60 60]) ;
CoM=regionprops(sampled, Z,{'Centroid','WeightedCentroid'});
c1=cat(1,CoM.Centroid);
c2=cat(1,CoM.WeightedCentroid);
poldist=(sqrt(((c1(1)-c2(1))^2)+((c1(2)-c2(2))^2)))*.2167; %microns per px


errorPct=((abs(sum(Traction_x))+abs(sum(Traction_y)))/total)*100;

dataOutput= [dataOutput; extract_num, cellArea, total, AvgT, max(z), totalForce, energy, SurfTens, sum(Traction_x),sum(Traction_y),poldist,errorPct];


more= questdlg('Do you have more data to load?','Next File','Yes','No','No');
switch more 
    case 'Yes' 
        escape=0;
        [filename, pathname, filterindex] = uigetfile('*.jpg', 'Open Cell Image',ini_path);
    case 'No'
        break
end

end 


export= {'Cell #','Cell Area (um2)', 'Sum of Stress (Pa)','Avg. Traction Stress (Pa)','Max Traction Stress (Pa)','Total Force (nN)','Energy (pJ)','Surface Tension (N/m)','Sum of Traction in x','Sum of Traction in y','Polarization Distance (um)','Percent Error'};

temp = inputdlg('Enter Output Excel Filename (with extension):','Output Filename',1,{'TFMdata.xlsx'});
 mat = cell2mat(temp);
 xlswrite(fullfile(pathname,mat),export, 'Sheet1','B1');
 xlswrite(fullfile(pathname,mat),dataOutput,'Sheet1','B2');
 msgbox('Output complete: Excel File','Output')

