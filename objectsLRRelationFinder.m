% Main Function 
% Reads the relation files generated by Saul 
% Finds relations between segments (i.e. Left, Right, Above, Below)

% Created by Umar Manzoor

MyFolderInfo = dir('relationfiles');
for k = 1 : size(MyFolderInfo)
   if(~MyFolderInfo(k).isdir)
    file = 'C:\Users\Umar Manzoor\Documents\GitHub\saul\data\mSprl\matlabcode\relationfiles\';
    outputfile = 'C:\Users\Umar Manzoor\Documents\GitHub\saul\data\mSprl\matlabcode\relationfiles\relations-';
    file = strcat(file, MyFolderInfo(k).name);
    outputfile = strcat(outputfile, MyFolderInfo(k).name);
	fid = fopen(file);
    outputfid = fopen(outputfile,'w');
	tline = fgetl(fid);

    while ischar(tline)
        objects = strsplit(tline, ',');
	    xyaxis = char(objects{3});
	    filename = strsplit(MyFolderInfo(k).name, '.');
        label = char(filename(1));
        image = strcat('C:\Users\Umar Manzoor\Documents\GitHub\saul\data\mSprl\matlabcode\00\images\', label);
        image = strcat(image, '.jpg');
    
        originalImage = imread(image);

%       figure, imshow(originalImage);
                       
	    Mask_1 = strcat(label, '_');
	    Mask_1 = strcat(Mask_1, char(objects(1)));
        Mask_1 = strcat(Mask_1, '.mat');
        Mask_1 = strcat('C:\Users\Umar Manzoor\Documents\GitHub\saul\data\mSprl\matlabcode\00\segmentation_masks\', Mask_1);
               
	    Mask_2 = strcat(label, '_');
	    Mask_2 = strcat(Mask_2, char(objects(2)));
        Mask_2 = strcat(Mask_2, '.mat');
        Mask_2 = strcat('C:\Users\Umar Manzoor\Documents\GitHub\saul\data\mSprl\matlabcode\00\segmentation_masks\', Mask_2);

        firstObjMask = objMaskLoader(Mask_1);
        secondObjMask = objMaskLoader(Mask_2);

        [rows columns depth] = size(originalImage);

        boundary1 = boundaryLocator(originalImage, firstObjMask);

%        figure, plot(boundary1(:,2), boundary1(:,1), 'r', 'LineWidth', 3);

        axis([0 columns 0 rows]);

        set(gca,'YDir','reverse');

        hold on

        boundary2 = boundaryLocator(originalImage, secondObjMask);

%        plot(boundary2(:,2), boundary2(:,1), 'r', 'LineWidth', 3);

        [x1,y1,x2,y2,minDistance, maxx1, maxx2, maxy1, maxy2] = calculateMinDistance(boundary1, boundary2);
        percent = disjointObjects(boundary1, boundary2);
        
%        line([x1, x2], [y1, y2], 'Color', 'y', 'LineWidth', 3);              
        
        if((minDistance~=0) && strcmp(xyaxis, 'y-aligned'))
            if (x2 - x1 > 0)
                fprintf(outputfid,'Left,%s,%s,%s,%s \r\n',char(objects{1}),char(objects{4}),char(objects{2}), char(objects{5}));
            elseif (x2 - x1 < 0)
                fprintf(outputfid,'Right,%s,%s,%s,%s \r\n',char(objects{1}),char(objects{4}),char(objects{2}), char(objects{5}));                
            end
        elseif ((minDistance~=0) && strcmp(xyaxis, 'x-aligned'))
            if (y2 - y1 > 0)2
                fprintf(outputfid,'Above,%s,%s, %s,%s \r\n',char(objects{1}),char(objects{4}),char(objects{2}), char(objects{5}));
            elseif (y2 - y1 < 0)                
                fprintf(outputfid,'Below,%s,%s,%s,%s \r\n',char(objects{2}),char(objects{5}),char(objects{1}), char(objects{4}));                
            end
        elseif(minDistance==0 && percent > 80.00)
                output = 'Ignore';
        elseif((minDistance==0) && strcmp(xyaxis, 'y-aligned'))
            if (maxx1 - maxx2 > 0)
                fprintf(outputfid,'Left,%s,%s,%s,%s \r\n',char(objects{1}),char(objects{4}),char(objects{2}), char(objects{5}));
            elseif (maxx2 - maxx1 < 0)
                fprintf(outputfid,'Right,%s,%s,%s,%s \r\n',char(objects{1}),char(objects{4}),char(objects{2}), char(objects{5}));              
            end
        elseif((minDistance==0) && strcmp(xyaxis, 'x-aligned'))
            if (maxy1 - maxy2 > 0)
                fprintf(outputfid,'Above,%s,%s,%s,%s \r\n',char(objects{1}),char(objects{4}),char(objects{2}), char(objects{5}));                
            elseif (maxy2 - maxy1 < 0)
                fprintf(outputfid,'Below,%s,%s,%s,%s \r\n',char(objects{2}),char(objects{5}),char(objects{1}), char(objects{4}));
            end
        end

	    tline = fgetl(fid);
	end
	fclose(fid);
    fclose(outputfid);
   end
end