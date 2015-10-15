%Function file for processing the results of a parallel job.  Any
%processing should be done here, with saving the results to a txt file in an
%appropriate location.  This location must be on the file path of the
%master process.
%
%By Christopher Strickland. For personal use and for the CSU SIAM workshop,
%10/26/2011
%Distribute freely.

function doneflag = procresult(solution, jobnumber)

if exist('/scratch/strickla/solution.txt','file') == 0,
    dlmwrite('/scratch/strickla/solution.txt', solution);
    dlmwrite('/scratch/strickla/solorder.txt', jobnumber);
else
    dlmwrite('/scratch/strickla/solution.txt', solution, '-append');
    dlmwrite('/scratch/strickla/solorder.txt', jobnumber, '-append');
end

doneflag = 1;
end
