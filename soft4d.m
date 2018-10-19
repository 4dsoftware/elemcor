function varargout = soft4d(varargin)
% SOFT4D MATLAB code for soft4d.fig
%      SOFT4D, by itself, creates a new SOFT4D or raises the existing
%      singleton*.
%
%      H = SOFT4D returns the handle to a new SOFT4D or the handle to
%      the existing singleton*.
%
%      SOFT4D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOFT4D.M with the given input arguments.
%
%      SOFT4D('Property','Value',...) creates a new SOFT4D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before soft4d_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to soft4d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help soft4d

% Last Modified by GUIDE v2.5 22-May-2018 11:33:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @soft4d_OpeningFcn, ...
                   'gui_OutputFcn',  @soft4d_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before soft4d is made visible.
function soft4d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to soft4d (see VARARGIN)

% reset all figure axes
axes(handles.axes1);
cla reset
set(gca,'xtick',[],'ytick',[],'color',0.9*[1 1 1]);box on;
axes(handles.axes2);
cla reset
set(gca,'xtick',[],'ytick',[],'color',0.9*[1 1 1]);box on;
set(handles.edit2,'String','optional') %set initial radius of bright cells
set(handles.edit3,'String','1') %set initial radius of bright cells
set(handles.edit4,'String','100000') %set initial radius of bright cells

% Choose default command line output for soft4d
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes soft4d wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = soft4d_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[labeldata,path] = uigetfile('*.xlsx');
set(handles.edit1,'String',[path,'/',labeldata]) %set string

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

unlabeldata = uigetfile('*.xlsx');
set(handles.edit2,'String',[path,'/',unlabeldata]) %set string

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% tracer

set(gcf,'Pointer','watch'); %change cursor to loading watch
drawnow;	% Cursor won't change right away unless you do this.

try % the follow scripts may yield errors

str = get(handles.popupmenu1,'String');
val = get(handles.popupmenu1,'Value');
tracer = str{val};

% analyzer
analyzer = get(handles.popupmenu2,'Value');

dtl = readtable(get(handles.edit1,'String'),'ReadVariableNames',1,'ReadRowNames',0,'Sheet',1); %data table labeled
vname = dtl.Properties.VariableNames;
if isempty(regexp(get(handles.edit2,'String'),'xlsx','ONCE')) == 0
    has_unlabel_data = 1;
    dtu = readtable(get(handles.edit2,'String'),'ReadVariableNames',1,'ReadRowNames',0); %data table unlabeled
else
    has_unlabel_data = 0;
    dtu = 0;
end
purity = str2double(get(handles.edit3,'String')); %data table unlabeled
nomres = str2double(get(handles.edit4,'String')); %data table unlabeled
comp = dtl.Compound;
uniname = unique(comp);

tmdvl = [];
compnew = [];
tfam = [];
for k = 1:length(uniname)
    ind = find(strcmp(comp,uniname{k}) == 1);
    data = table2array(dtl(ind,3:end));
    formula = table2array(dtl(ind(1),2));
    mdvl = [];
    famr = [];
    for i = 1:size(data,2)
        fam = data(:,i);
        if fam(1) == 0
            fam = zeros(length(fam),1);
            fam(1) = 1;
        end
        fam = fam/sum(fam);
        famr = [famr fam];
        [x,~,~,nt,tracer_val,pool] = elemcor(fam,formula,tracer,purity,[],nomres,200,analyzer); %pool size added, 5/24/2018
        poolsize(k,i) = pool;
        enrichment(k,i) = mdv2enrichm(x,nt);
        mdvl = [mdvl x]; 
    end
    compnew = [compnew;repmat(uniname(k),length(x),1)]; %the same as the length of x, which may be different than that of fam due to padded zeros
    tmdvl = [tmdvl;mdvl];
    tfam = [tfam;famr];
end

vname(2) = [];
table1 = [compnew num2cell(tmdvl)];
table1 = [vname; table1];
set(handles.uitable1,'Data',table1);

%convert mdv to table and write to the original file 
tablem = [array2table(compnew) array2table(tmdvl)];
tablem.Properties.VariableNames = vname;
writetable(tablem,get(handles.edit1,'String'),'Sheet','MDV');

%convert enrichment to table and write to the original file
tablee = [array2table(uniname) array2table(enrichment)];
tablee.Properties.VariableNames = vname;
writetable(tablee,get(handles.edit1,'String'),'Sheet','Enrichment');

%convert pool size to table and write to the original file
tablep = [array2table(uniname) array2table(poolsize)];
tablep.Properties.VariableNames = vname;
writetable(tablep,get(handles.edit1,'String'),'Sheet','Pool_Size');

if has_unlabel_data == 1  
    tmdvu = [];
    for k = 1:length(uniname)
    ind = find(strcmp(comp,uniname{k}) == 1);
    data = table2array(dtl(ind,3:end));
    datau = table2array(dtu(ind,3:end));
    zun = datau./repmat(sum(datau),size(datau,1),1);
    zun_mean = mean(zun,2);
    zun_mean = zun_mean/sum(zun_mean);
    
    formula = table2array(dtl(ind(1),2));
    mdvu = [];
    for i = 1:size(data,2)
        fam = data(:,i);
        if fam(1) == 0
            fam = zeros(length(fam),1);
            fam(1) = 1;
        end
        fam = fam/sum(fam);
        [x,~,~,nt,tracer_val,pool] = elemcor(fam,formula,tracer,purity,zun_mean,nomres,[],analyzer);
        poolsize(k,i) = pool;
        enrichment(k,i) = mdv2enrichm(x,nt);
        mdvu = [mdvu x]; 
    end
    tmdvu = [tmdvu;mdvu];
    end
    
    table2 = [compnew num2cell(tmdvu)];
    table2 = [vname; table2];
    set(handles.uitable2,'Data',table2);
    handles.tb2 = table2;
    
    %convert mdv to table and write to the original file 
    tablem = [array2table(compnew) array2table(tmdvu)];
    tablem.Properties.VariableNames = vname;
    writetable(tablem,get(handles.edit2,'String'),'Sheet','MDV');

    %convert enrichment to table and write to the original file
    tablee = [array2table(uniname) array2table(enrichment)];
    tablee.Properties.VariableNames = vname;
    writetable(tablee,get(handles.edit2,'String'),'Sheet','Enrichment');

    %convert pool size to table and write to the original file
    tablep = [array2table(uniname) array2table(poolsize)];
    tablep.Properties.VariableNames = vname;
    writetable(tablep,get(handles.edit2,'String'),'Sheet','Pool_Size');

end

handles.tb1 = table1;
handles.tb3 = tfam;
handles.hud = has_unlabel_data;
handles.vtr = tracer_val;
guidata(hObject, handles);

catch

axes(handles.axes1);
cla reset
text(0.15,0.5,'Please reselect tracer!','fontsize',14,'color','r');
set(gca,'xtick',[],'ytick',[]);
axis off 

axes(handles.axes2);
cla reset
text(0.15,0.5,'Please reselect tracer!','fontsize',14,'color','r');
set(gca,'xtick',[],'ytick',[]);
axis off 

end
    
set(gcf,'Pointer','arrow'); %change cursor to arrow
drawnow;	% Cursor won't change right away unless you do this.


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(eventdata)
    id1 = eventdata.Indices(1);
    id2 = eventdata.Indices(2);
end

id1 = id1 - 1; 
if id1 <= 1
    id1 = 1; %selection is always larger or equal to 1, otherwise index is meaningless
end

id2 = id2 - 1; 
if id2 <= 1
    id2 = 1; %selection is always larger or equal to 1, otherwise index is meaningless
end

comp_ar = handles.tb1(2:end,1);
compound = comp_ar(id1);
ind = find(strcmp(comp_ar,compound) == 1);
fam = handles.tb3(ind,id2);
numtb1 = cell2mat(handles.tb1(2:end,2:end));
mdvla = numtb1(ind,id2);
sample_ar = handles.tb1(1,2:end);
sample = sample_ar(id2);

axes(handles.axes1);
cla reset
bar([fam mdvla],0.8,'edgecolor',[1 1 1]);
colormap([0.6 0.6 0.6;[0 110 190]/255]);
tt = strrep(sample,'_','\_');
title(strcat(tt,', ',compound,', IE = ',num2str(mdv2enrichm(mdvla,(length(ind)-1)),'%.3f')));  %mdv2enrichm updated 5/15/2018, valence added
legend('Before Correction','After Correction','location','north');
set(gca,'xtick',1:length(ind),'xticklabel',cellfun(@(x) ['M+',num2str(x)],num2cell(((1:length(ind))-1)*handles.vtr),'uniformoutput',0));
xlim([0.5 length(ind)+0.5]);
ylim([0 1.02]);

guidata(hObject, handles);

% --- Executes when selected cell(s) is changed in uitable2.
function uitable2_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if handles.hud == 1
    
if ~isempty(eventdata)
    id1 = eventdata.Indices(1);
    id2 = eventdata.Indices(2);
end

id1 = id1 - 1; 
if id1 <= 1
    id1 = 1; %selection is always larger or equal to 1, otherwise index is meaningless
end

id2 = id2 - 1; 
if id2 <= 1
    id2 = 1; %selection is always larger or equal to 1, otherwise index is meaningless
end

comp_ar = handles.tb2(2:end,1);
compound = comp_ar(id1);
ind = find(strcmp(comp_ar,compound) == 1);
fam = handles.tb3(ind,id2);
numtb2 = cell2mat(handles.tb2(2:end,2:end));
mdvlu = numtb2(ind,id2);
sample_ar = handles.tb2(1,2:end);
sample = sample_ar(id2);

axes(handles.axes2);
cla reset
bar([fam mdvlu],0.8,'edgecolor',[1 1 1]); 
colormap([0.6 0.6 0.6;[0 110 190]/255]);
tt = strrep(sample,'_','\_');
title(strcat(tt,', ',compound,', IE = ',num2str(mdv2enrichm(mdvlu,(length(ind)-1)),'%.3f')));
legend('Before Correction','After Correction','location','north');
set(gca,'xtick',1:length(ind),'xticklabel',cellfun(@(x) ['M+',num2str(x)],num2cell(((1:length(ind))-1)*handles.vtr),'uniformoutput',0));
xlim([0.5 length(ind)+0.5]);
ylim([0 1.02]);

end
