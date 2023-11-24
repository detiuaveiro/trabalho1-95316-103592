function r = benchmark(method, nruns=5)

switch (method)
    case "blur"
        %           File path 🡳           🡳 Kernel size
        cmdfmt = "./imageTool %s tic blur %s toc 2>/dev/null"
    case "oldblur"
        %           File path 🡳              🡳 Kernel size
        cmdfmt = "./imageTool %s tic oldblur %s toc 2>/dev/null"
    otherwise
        error "Please specify \"blur\" or \"oldblur\"."
endswitch

files = {"pgm/small/bird_256x256.pgm"
         "pgm/medium/mandrill_512x512.pgm"
         "pgm/large/airfield-05_1600x1200.pgm"}

sizes = {"2,2"
         "4,4"
         "8,8"
         "16,16"
         "32,32"}

nbenches = length(files) * length(sizes);
r = cell(nbenches, 6 + 2);

tic
for fi = 1:length(files)
    for si = 1:length(sizes)
        raw_time = zeros(1, nruns);
        raw_caltime = zeros(1, nruns);

        cmd = sprintf(cmdfmt, files{fi}, sizes{si});
        n = (fi-1)*length(sizes) + si;
        printf("      Running stage %u out of %u: \"%s\"", n, nbenches, cmd);

        for ri = 1:nruns
            printf("\x0D[%u/%u] \n", ri, nruns);
            [status, out] = system(sprintf("%s | tail -n 1", cmd));

            printf("%s\033[2A", out);
            data = ostrsplit(out, " ", true);

            raw_time(ri) = str2double(data{1});
            raw_caltime(ri) = str2double(data{2});
        end
        printf("\n");

        r{n, 1} = files{fi};   # Filename
        r{n, 2} = sizes{si};   # Kernel size

        r{n, 3} = sum(raw_time) / length(raw_time);
        r{n, 4} = sum(raw_caltime) / length(raw_caltime);

        r{n, 5} = str2num(data{3});    # PIXMEM
        r{n, 6} = str2num(data{4});    # PIXOPS
        r{n, 7} = raw_time;
        r{n, 8} = raw_caltime;
    end
end

printf("\n\n");
toc

save (sprintf("perf.%s", method), "r");
