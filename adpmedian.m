function f = adpmedian(g, Smax)
%ADPMEDIAN performs adaptive median filtering
%F = ADEMEDIAN(G, Smax) performs adaptive median filtering of
%image G. The median filter starts at size 3-by-3 and iterates up
%to sze SMAX-by-SMAX. SMAX must be an odd integetr greater than 1.

%SMAX must be an odd, positive integer greater than 1.
if (Smax <= 1)| (Smax/2 == round(Smax/2)) | (Smax ~= round(Smax))
    error('SMAX must be an odd interge >1.')
end
[M, N] = size(g);

%Intial setup.
f = g;
f(:) = 0;
alreadyProcessed = false(size(g));

%Begin filtering.
for k = 3:2:Smax
    zmin = ordfilt2(g, 1, ones(k, k), 'symmetric');
    zmax = ordfilt2(g, k*k, ones(k,k), 'symmetric');
    zmed = medfilt2(g, [k k], 'symmetric');
    processUsingLevelB = (zmed > zmin) & (zmax > zmed) & ~alreadyProcessed;
    zB = (g >zmin) & (zmax > g);
    outputZxy = processUsingLevelB & zB;
    outputZmed = processUsingLevelB & ~zB;
    f(outputZxy) = g(outputZxy);
    f(outputZmed) = zmed(outputZmed);
    
    alreadyProcessed = alreadyProcessed | processUsingLevelB;
    if all(alreadyProcessed(:))
        break;
    end
end
%
%
%
f(~alreadyProcessed) = zmed(~alreadyProcessed);