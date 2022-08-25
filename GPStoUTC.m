function [tUTC,tLST] = GPStoUTC(tGPS,filename,leapsecs)

% get the sunday start time for the filename
% returns also the time in local time for San Diego
% Needs some changes to account for local time in date of filename

% check to see if tGPS is actually in SecFromSunday or Posix

if tGPS(1)<24*60*60*7
    
    % figure out filename date format
    dstart = regexp(filename,'[0-9]{6}');
    
    if isempty(dstart)
        disp('No time in the filename, please enter what day the data was collected in datetime format')
        prompt = 'Date in string format (datetime(yyyy,mm,dd))?)';
        filedate = input(prompt);
    elseif dstart == 1
        filedate = datetime(filename(1:8),'InputFormat','yyyyMMdd');
    elseif dstart ~=1
        dd = [dstart; dstart+5]';
        dstr = filename([dd(1,1):dd(1,2) dd(2,1):dd(2,2)]);
        filedate = datetime(dstr,'InputFormat','yyyyMMddHHmm');
    end
    
    sunstart = dateshift(filedate,'dayofweek','sunday','previous');
    sunstart = dateshift(sunstart,'start','day');
    
    % account for leapseconds
    if nargin<3 && year(sunstart) >=2019
        leapsecs = 18;
    elseif nargin<3 && year(sunstart) ~=2019
        disp('Please enter in leapseconds for your time period')
    end
    
    % tGPS is seconds since the sunday start time
    secondsinoneday = 60*60*24;
    sunstart = datenum(sunstart);
    t_in_days = (tGPS-leapsecs)./secondsinoneday;
    tUTC = sunstart+t_in_days;
    
    
    
    % get local time
    tUTCdt = datetime(tUTC(1),'ConvertFrom','datenum','TimeZone','Etc/UTC');
    tLSTt = tUTCdt;
    tLSTt.TimeZone = 'America/Los_Angeles';
    
    
    
    % get datenum of local time
    tLST = tUTC + seconds(tzoffset(tLSTt))./secondsinoneday;
    
else
    epoch = datetime(1980,1,6,'TimeZone','UTCLeapSeconds');
    tUTC = epoch + seconds(tGPS)+seconds(1e9);
    tUTC.TimeZone = 'Etc/UTC';
    tLST = tUTC;
    tLST.TimeZone = 'America/Los_Angeles';
    
    %return into datenum
    tUTC = datenum(tUTC);
    tLST = datenum(tLST);
end

