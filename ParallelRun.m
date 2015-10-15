%MPI implementation for running a function file with different parameters
%  in parallel.  Uses matlabMPI.
%
%Main file to run via MPI_Run(). Contains all the MPI code, and 
%  should be edited for each specific use as mentioned in the comments.
%By Christopher Strickland. For personal use and for the CSU SIAM workshop,
%1/27/2012
%Version 2 - some major bug fixes.
%Distribute freely.

%Put the function to run here!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
programfunc = @GeneralRD;
%Scroll down and replace function inputs and outputs with appropriate
%parameter names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now edit getwork.m for how the parameters will be altered.
%Now edit procresult.m for how to process the result from each processor

%Note: ONE solution variable is expected, called result in this code.  If more are
%needed, search and replace "result" appropriately.

WORKTAG = 1;

MASTER = 0;
SLAVE = 1;

%Initialize MPI
MPI_Init;

%Create communicator
comm = MPI_COMM_WORLD;

%Find out my identity in the communicator and the total size of it
commsize = MPI_Comm_size(comm);
%since the master only manages, there must be at least 2 processes
if commsize <=1,
    error('Cannot be run with only one process');
end
myrank = MPI_Comm_rank(comm);
if myrank == 0,
    mytype = MASTER;
else
    mytype = SLAVE;
end
% Print rank.
disp(['my rank: ',num2str(myrank)])

%Begin run
switch mytype
    case MASTER
        tic;
        %seed the slaves with their first job
        for rank=1:commsize-1 %C++ thing here... count begins w/ 0
%%%%%%Edit the following with your parameters!!
            [a,r,w1a,w1b,w2a,w2b] = getwork(rank); %get job
%%%%%%Put the name of one of your parameters here.
            if isempty(a), %check for no more work
                break;
            else
                %send job
%%%%%%Edit the following with your parameters, fifth argument to end!!
                MPI_Send(rank, WORKTAG, comm, rank, a,r,w1a,w1b,w2a,w2b);
                disp(['Job sent to: ',num2str(rank)])
            end
        end
        
        %loop over receiving results and sending out more work until there
        %is no work left to be done
        
        jobnumber = commsize;
%%%%%%Edit the following with your parameters!!
        [a,r,w1a,w1b,w2a,w2b] = getwork(jobnumber);
%%%%%%Put the name of one of your parameters here.
        while ~isempty(a)
            %receive results from a slave
            keep_waiting = 1;
            while(keep_waiting)
                [msg_rank msg_tag] = MPI_Probe('*','*',comm); %listen for finished work
                if ~isempty(msg_rank),
                    keep_waiting = 0;
                end
            end
            numdone = size(msg_rank,1);
            
            for ii=1:numdone,
                [result, jobdone] = MPI_Recv(msg_rank(ii), msg_tag(ii), comm); %recieve finished work
                
                %tell user the result has been finished
                fprintf(1,'Result %u recieved\n',jobdone);
                
                %send the slave a new work unit
                %%%%%%Edit the following with your parameters, fifth argument to end!!
                MPI_Send(msg_rank(ii), WORKTAG, comm, jobnumber, a,r,w1a,w1b,w2a,w2b);
                
                disp(['New job sent to: ',num2str(msg_rank(ii))])
                
                %process the result
                dne = procresult(result, jobdone);
                
                fprintf(1,'Result %u processed\n',jobdone);
                
                %get the next unit of work to be done
                jobnumber = jobnumber + 1;
                %%%%%%Edit the following with your parameters!!
                [a,r,w1a,w1b,w2a,w2b] = getwork(jobnumber);
            end
        end
        
        disp('The last job has been sent')
        %There's no more work to be done, so receive all the outstanding
        %results from the slaves
        
        for rank=1:commsize-1,
            [result, jobdone] = MPI_Recv(rank, WORKTAG, comm);
            
            %process the result, if it's not null
            if ~isempty(result)
                dne = procresult(result, jobdone);
                %Tell the slave to exit if it hasn't already
%%%%%%Put in EXACTLY the number of empty strings as you have parameters!!
                MPI_Send(rank, WORKTAG, comm, 0, '','','','','','');
            end
            
            fprintf(1,'Last result from %u recieved and processed\n',rank);
            
        end
        toc; 
    case SLAVE
        while(1)
            %Receive a message from the master
%%%%%%Edit the following with your parameters (don't erase jobnumber)!!
            [jobnumber, a,r,w1a,w1b,w2a,w2b] = MPI_Recv(0, WORKTAG, comm);

            %Message recieved
            disp('Message recieved');
            
            %Check for no more work, break
%%%%%%Put the name of one of your parameters here.
            if isempty(a)
                disp('No more work');
                MPI_Send(0, WORKTAG, comm, '','');
                disp('Null result sent, exiting...')
                break;
            end
            
            %Do the work
%%%%%%Edit the following with only your parameters!!
%%%%%%This is the main function call.
            result = programfunc(a,r,w1a,w1b,w2a,w2b);

            disp('Job done');
            
            %Send the result back with the job number
            MPI_Send(0, WORKTAG, comm, result, jobnumber);
            
            disp('Result sent');
        end
end

%Clean up and shut down MPI
MPI_Finalize;
disp('SUCCESS');
if myrank==0,
    dlmwrite('done.txt', 'task finished','delimiter','');
end

%Don't exit if we are the host
if myrank ~= MatMPI_Host_rank(comm),
    exit;
end
            
