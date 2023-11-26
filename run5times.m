% Benchmark "ImageLocateSubImage".

function data = run5times(base, sub)
pkg load io;

cmd = sprintf("./imageTool %s %s tic locate toc", sub, base);
    for i = 1:5
        [status, out] = system(sprintf("%s | tail -n 1", cmd));
        out;
        
        data = ostrsplit(out, " ", true);

        raw_time(i) = str2double(data{1});
        raw_caltime(i) = str2double(data{2});
        pixmem = str2num(data{3});
        pixops = str2num(data{4});
    end

    avgtime = sum(raw_time) / length(raw_time);
    avgcaltime = sum(raw_caltime) / length(raw_caltime);
    
    c = { base, sub, avgtime, avgcaltime, pixmem, pixops }
    cell2csv("benchmark/results/csv/loc.csv", c)
end
