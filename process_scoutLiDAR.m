clear all
basedir = '/Users/juliafiedler/Desktop/SurfRanch_temp/';
filename = '20220503_SurfRanch_ScoutUltra_50m_Hover1.las';
s = LASread(fullfile(basedir,filename));
%%
xyz = [s.record.x s.record.y s.record.z];

[tUTC,tLST] = GPStoUTC(s.record.gps_time,filename);
[T, sortedInd] = sort(tUTC);

% x = x( sortedInd);
% y = y( sortedInd);
xyz = xyz( sortedInd,:);
int = s.record.intensity( sortedInd);
beamID = s.record.laser_id(sortedInd);
tUTC = tUTC(sortedInd);
tUTCdt = datetime(tUTC,'convertfrom','datenum');
dT = diff(tUTC);
tInd =  find(dT>1e-7); %TODO: What is the scan rate of the instrument?? Is that in the las?
%%
NumberofFrames = length(tInd);
TimeStamps = tUTC(tInd);
n = 1;
for i=1:NumberofFrames
    kk = n:tInd(i);
    XYZ{i} = xyz(kk,:);
    Beamnum{i} = beamID(kk);
    Intensity{i} = int(kk);
    n = tInd(i)+1;
end


%%
clf
framen = 300;

for i=0:31
    for nn = framen-10:framen;
        hback(i+1) = scatter(XYZ{nn}(Beamnum{nn}==i+1,1),...
            XYZ{nn}(Beamnum{nn}==i+1,2),30,Intensity{nn}(Beamnum{nn}==i+1),...
            'filled','MarkerFaceAlpha',0.05);
        %     h(i) = scatter(XYZ{1}(Beamnum{1}==i+1,1),XYZ{1}(Beamnum{1}==i+1,3));
        hold on
    end
end

%

for i=0:31
    %
    h(i+1) = scatter(XYZ{framen}(Beamnum{framen}==i+1,1),...
        XYZ{framen}(Beamnum{framen}==i+1,2),30,Intensity{framen}(Beamnum{framen}==i+1),'filled');
    %     h(i) = scatter(XYZ{1}(Beamnum{1}==i+1,1),XYZ{1}(Beamnum{1}==i+1,3));
    hold on
end


%use these as initial bounding area for plotting
xlim([s.header.min_x s.header.max_x])
ylim([s.header.min_y s.header.max_y])
% zlim([s.header.min_z s.header.max_z])
axis equal

%adjust axes to focus on only the area right under the drone, hard-coded
%for now
xlim([249250 249380])
ylim([4016300 4016550])
% colormap(jet(32))
% hc = colorbar; hc.Label.String = 'Laser ID'; hc.Label.FontSize = 14;

% colormap(jet(32))
hc = colorbar; hc.Label.String = 'Intensity'; hc.Label.FontSize = 14;
clim([0 20000])
ax = gca;

%draw rectangle and annotate
xrect = 249295;
yrect = 4016465; %again, hard coded for this test
szrect = 40;
patch([xrect xrect xrect+szrect xrect+szrect],[yrect yrect+szrect yrect+szrect yrect],'c','facealpha',0.1)
text(xrect+szrect/2,yrect-4,[num2str(szrect,'%2.0f') ' m'],'FontSize',20,'HorizontalAlignment','center')
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.XLabel.String = 'UTM Eastings';
ax.YLabel.String = 'UTM Northings';

ax.Title.String = filename; ax.Title.Interpreter = 'none';

%add timestamp
ht = text(0.05,0.05,['tUTC = ' datestr(TimeStamps(framen),'HH:MM:SS.FFF')]...
    ,'units','normalized','FontSize',16,'BackgroundColor','w','EdgeColor','k');
%%
for ii=4250:5:4700 %pick a chunk of time to plot

%     xyc = [XYZ{}]
    for i=0:31
        for nn = ii-10:ii
            set(hback(i+1),'XData',XYZ{nn}(Beamnum{nn}==i+1,1),...
                'YData',XYZ{nn}(Beamnum{nn}==i+1,2),...
                'CData',Intensity{nn}(Beamnum{nn}==i+1));
            hold on
        end
    end




    for i=0:31
        set(h(i+1),'XData',XYZ{ii}(Beamnum{ii}==i+1,1),'YData',XYZ{ii}(Beamnum{ii}==i+1,2),'CData',Intensity{ii}(Beamnum{ii}==i+1))
    end
    set(ht,'String',['tUTC = ' datestr(TimeStamps(ii),'HH:MM:SS.FFF')])
    pause(0.01)
end
%%
%% PLOT FROM SIDE
clf
framen = 300;
hs = scatter(xyz(beamID==1,2),xyz(beamID==1,3),30,tUTC(beamID==1),'filled')
clim([TimeStamps(1) TimeStamps(end)])
hs.MarkerFaceAlpha = 0.05;
hold on
for i=0
    %
    h(i+1) = scatter(XYZ{framen}(Beamnum{framen}==i+1,2),...
        XYZ{framen}(Beamnum{framen}==i+1,3),30,Intensity{framen}(Beamnum{framen}==i+1),'filled');
    %     h(i) = scatter(XYZ{1}(Beamnum{1}==i+1,1),XYZ{1}(Beamnum{1}==i+1,3));
    hold on
end
%add timestamp
ht = text(0.05,0.05,['tUTC = ' datestr(TimeStamps(framen),'HH:MM:SS.FFF')]...
    ,'units','normalized','FontSize',16,'BackgroundColor','w','EdgeColor','k');
ylim([58 60])
xlim([4016550 4016570])


%%
for ii=301:4000
    for i=0
        set(h(i+1),'XData',XYZ{ii}(Beamnum{ii}==i+1,2),'YData',XYZ{ii}(Beamnum{ii}==i+1,3),'CData',Beamnum{ii}(Beamnum{ii}==i+1))
    end
    set(ht,'String',['tUTC = ' datestr(TimeStamps(ii),'HH:MM:SS.FFF')])
    pause(0.01)
end

