%Work file for MPI implementation located in ParallelRun.m
%Given the task number, return appropriate parameters, or empty strings
%when the last job has been completed.
%
%By Christopher Strickland. For personal use and for the CSU SIAM workshop,
%10/26/2011
%Distribute freely.

function [a,r,w1a,w1b,w2a,w2b] = getwork(tasknumber)

var = tasknumber; %variable to run
LASTJOB = 20; %number of last job

if tasknumber <= LASTJOB,
   %Your parameters here, along with the way they change with var
    a = var*0.1;
    r = 1;
    w1a = 0;
    w1b = 1;
    w2a = 0;
    w2b = 0;
else
  %set all your parameters equal to the empty string
    a = '';
    r = '';
    w1a = '';
    w1b = '';
    w2a = '';
    w2b = '';
end
