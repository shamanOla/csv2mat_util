mkdir(pwd,'Output');
%% find out all folder with name 'rosbag'
fileFolder=fullfile(pwd);
files0=dir(pwd);
count=1;
for i=3:length(files0)
    if files0(i,1).isdir==1
        if strfind(files0(i,1).name,'rosbag')==1
            names_Folder{count,1}=files0(i,1).name;
            count=count+1;
        end
    end
end

for kkk=1:count-1
    vater_folder=names_Folder{kkk,1};
    dirOutput=dir(fullfile(fileFolder,vater_folder,'*.csv'));
    filefullNames={dirOutput.name}';
    
    %% choose minidest time ,dumm
    min_time_start=inf;
    for num=1:length(filefullNames)
        csv_path=convertCharsToStrings(fileFolder)+'\'+convertCharsToStrings(vater_folder)+'\'+convertCharsToStrings(filefullNames(num));
        A=readmatrix(csv_path,delimitedTextImportOptions('DataLines',[1,Inf]));
        min_time_start=min(str2num(A{2,1})/1000000000,min_time_start);
    end
    clear A
    
    for num=1:length(filefullNames)
        namex= strsplit(convertCharsToStrings(filefullNames(num)),'.');
        get_name=namex(1);
        csv_path=convertCharsToStrings(fileFolder)+'\'+convertCharsToStrings(vater_folder)+'\'+convertCharsToStrings(filefullNames(num));
        A=readmatrix(csv_path,delimitedTextImportOptions('DataLines',[1,Inf]));
        s=size(A);
        a=s(1,1);
        b=s(1,2);
        output=struct;
        save_t0(num)=str2num(A{2,1})/1000000000;
        for i=1:a-1
            time_loc_in(1,i)=(str2num(A{i+1,1})/1000000000-min_time_start);
        end
        
        for i=1:b
            field1='time';
            value1=time_loc_in(1,1:a-1);
            field2='value';
            for j=1:a-1
                if isempty(str2num(A{j+1,i}))
                    value2(1,j)=NaN;
                else
                    if length(str2num(A{j+1,i}))==1
                        value2(1,j)=str2num(A{j+1,i});
                    else
                        data_lane=str2num(A{j+1,i});
                        for id_lane=1:length(data_lane)
                            value2(id_lane,j)=data_lane(id_lane);
                        end
                    end
                end
            end
            field3=A{1,i};
            value3=struct(field1,value1,field2,value2);
            output.(field3)=value3;
            clear value2 data_lane
        end
        
        id_1=fieldnames(output);
        for tt=2:b
            id_2=id_1{tt,1};
            id_2_full=convertStringsToChars(get_name+'.'+id_2);
            save_name(num)=get_name;
            eval([id_2_full,'=timeseries',';']);
            eval([id_2_full,'.time=time_loc_in',''';' ]);
            eval([id_2_full,'.data=output.',id_2,'.value''',';']);
        end
        
        
        clear s a b field1 field2 field3 i value1 value2 value3 A j temp id_1 tt id_2 output id_2_full time_loc_in
        if(num==1)
            save(convertCharsToStrings(pwd)+'\'+convertCharsToStrings('Output')+'\'+convertCharsToStrings(vater_folder)+'.mat',save_name(num));
            save(convertCharsToStrings(pwd)+'\'+convertCharsToStrings(vater_folder)+'\'+convertCharsToStrings(vater_folder)+'.mat',save_name(num));
        else
            save(convertCharsToStrings(pwd)+'\'+convertCharsToStrings('Output')+'\'+convertCharsToStrings(vater_folder)+'.mat',save_name(num),'-append','-nocompression');
            save(convertCharsToStrings(pwd)+'\'+convertCharsToStrings(vater_folder)+'\'+convertCharsToStrings(vater_folder)+'.mat',save_name(num),'-append','-nocompression');
        end
    end
end
clear dirOutput namex num fileFolder filefullNames get_name vater_folder folder save_name count csv_road kkk

