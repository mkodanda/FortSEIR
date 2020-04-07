program seir_main_ageclass

! Numerical recipes types
USE nrtype
USE nr_bsstep
USE global_data
USE SEIR_sub

implicit none

real(8), dimension(nac,npv+1)        :: Ain   ! nodal Matrix to read in the age classified input parameters, 
                                              ! for last 2 column details, see below
real(8), dimension(:), allocatable   :: st, et, it, rt, t_loc   ! The SEIR Time Series Predictions and time points
real(8), dimension(neq)              :: yt, dydt, yt_scale, ytsv, dydtsv   	! Vectors for RKQS

real(8)                              :: dt_try, dt_next, time, timesv, dt_did
real(8)                              :: dt, rtol, atol, acc
integer                              :: nt, fid
integer                              :: i, inod, ix, ioerr1, ioerr2, irecout, sizeout(2), t_count, irecspace
real                                 :: start, finish, time_tot
real(8), DIMENSION(ncmp,nac)         :: output
INTEGER, DIMENSION(2)                :: shp_out

!--------------------------------------------------------------------------------------------------!
! Assign all filenames for input, and, contact matrices !
!--------------------------------------------------------------------------------------------------!
call filenames   ! Call the subroutine to assign all filenames

!--------------------------------------------------------------------------------------------------!
! Read in the inputs and contact matrices
!--------------------------------------------------------------------------------------------------!
! 1 - Input file
!--------------------------------------------------------------------------------------------------!
open(unit=10,file=infile,STATUS='OLD',IOSTAT = ioerr1) ! Open the text file and assign it a number
do ix = 1,nac
    read(fid,*) Ain(ix,:)
end do
close(10)        ! Close after reading
!--------------------------------------------------------------------------------------------------!
! 2 - Contact file school
!--------------------------------------------------------------------------------------------------!
open(unit=10,file=file_s,STATUS='OLD',IOSTAT = ioerr1) ! Open the text file and assign it a number
read(10,*) C_s
close(10)        ! Close after reading
!--------------------------------------------------------------------------------------------------!
! 3 - Contact file home
!--------------------------------------------------------------------------------------------------!
open(unit=10,file=file_h,STATUS='OLD',IOSTAT = ioerr1) ! Open the text file and assign it a number
read(10,*) C_h
close(10)        ! Close after reading
!--------------------------------------------------------------------------------------------------!
! 4 - Contact file work
!--------------------------------------------------------------------------------------------------!
open(unit=10,file=file_w,STATUS='OLD',IOSTAT = ioerr1) ! Open the text file and assign it a number
read(10,*) C_w
close(10)        ! Close after reading
!--------------------------------------------------------------------------------------------------!
! 5 - Contact file other locations
!--------------------------------------------------------------------------------------------------!
open(unit=10,file=file_o,STATUS='OLD',IOSTAT = ioerr1) ! Open the text file and assign it a number
read(10,*) C_o
close(10)        ! Close after reading
!--------------------------------------------------------------------------------------------------!
! 6 - Geographic topology
!--------------------------------------------------------------------------------------------------!
open(unit=10,file=file_ntp,STATUS='OLD',IOSTAT = ioerr1) ! Open the text file and assign it a number
do inod = 1,nnodes
  read(10,*) nngbr(inod)
  do ix = 1,nngbr(inod)
     read(10,*) ngbrlst(inod,ix)
  enddo 
end do
close(10)        ! Close after reading

! assuming a constant flow of people into each node (for testing code)
omg = 0.0d0
do ix = 1,nac
   omg(ix,ix) = 0.005
end do

!--------------------------------------------------------------------------------------------------!
! Assign parameters
!--------------------------------------------------------------------------------------------------!

! Ain description: Age class dependent parameter vectors
! A = [rho,kappa,gamm,mu_n,mu_d,w_s,w_w,w_h,w_o,Nis,I0,S0];
rho = Ain(:,1) ! Ain(1,:) = rho  --> probability that an exposed person turns infectious
kappa  = Ain(:,2) ! Ain(2,:) = kappa  --> inverse of the incubation period (1/t_incubation)
gamm  = Ain(:,3) ! Ain(3,:) = gamm  --> inverse of the mean infectious period (1/t_infectious)
mu_n  = Ain(:,4) ! Ain(4,:) = age-specific mortality rate under normal circumstances
mu_d  = Ain(:,5) ! Ain(5,:) = age-specific mortality rate with disease
w_s = Ain(:,6) ! Ain(6,:) = age-classified factor controlling effect of lockdown at workplace
w_w = Ain(:,7) ! Ain(7,:) = age-classified factor controlling effect of lockdown at workplace
w_h = Ain(:,8) ! Ain(8,:) = age-classified factor controlling effect of lockdown at home
w_o = Ain(:,9) ! Ain(9,:) = age-classified factor controlling effect of lockdown at other locations
Nis = Ain(:,10) ! Ain(10,:) = initial population proportions
I0  = Ain(:,11) ! Ain(11,:) = initial age distribution of infected people
S0  = Ain(:,12) ! Ain(11,:) = initial age distribution of susceptible people
! Now we will assign the last three parameters, all scalars, you can input more t_lck values if you want 
! [alpha;beta;t_tot;N_tot;t_l1;t_l2]
alpha = Ain(1,npv+1) ! Prob that infected asymptomatic infects
beta  = Ain(2,npv+1) ! Prob. that infectious transmits disease to susceptible
lambda = Ain(3,npv+1) ! Rate of birth
t_tot = Ain(4,npv+1) ! How long do you want to run the code in days
N_tot = Ain(5,npv+1) ! Total population, we will solve ODEs in proportions   
t_lck = Ain(6,npv+1) ! Time for introduction of lockdown
t_ulck = Ain(7,npv+1) ! Time for introduction of lockdown

! Calculate R0
Rm0 = beta/gamm(1)


! iterate over nodes to build the initial conditions
do inod = 1,nnodes
   ix = (inod-1)*neq
   !--------------------------------------------------------------------------------------------------!
   ! Initiate solution vectors
   !--------------------------------------------------------------------------------------------------!
   ! Define initial values for the simulation, all proportions with respect to N_tot
   yt(ix+1:ix+neq:ncmp) = S0(:)           ! Intial proportion of susceptible - S_a's
   yt(ix+2:ix+neq:ncmp) = I0(:)           ! Initial population of exposed    - E_a's
   yt(ix+3:ix+neq:ncmp) = I0(:)           ! Initial proportion of infected, symptomatic   - I_s's
   yt(ix+4:ix+neq:ncmp) = 0.d0*I0(:)      ! Initial proportion of infected, symptomatic   - I_a's
   yt(ix+5:ix+neq:ncmp) = 0.d0            ! Initial proportion of recovered  - R_a's
   yt(ix+6:ix+neq:ncmp) = Nis             ! Initial value of population fraction
end do
!--------------------------------------------------------------------------------------------------!
! Set up solver stuff
!--------------------------------------------------------------------------------------------------!
dt = 0.1d0   ! Assign time step

write(*,'(A15, F7.4)') 'Initial time step: ', dt

nt = ceiling(t_tot/dt)  ! Number of time steps
write(*,*) 'Total # of time steps :', nt 

allocate(t_loc(nt))

! Define time points
t_loc = 0.d0
do i=2,nt
	t_loc(i) = t_loc(i-1) + dt
enddo

!--------------------------------------------------------------------------------------------------!
! Open output file
!--------------------------------------------------------------------------------------------------!
! Set block size in file access for unformatted file
inquire(iolength = irecspace) output(:,:)  ! How many machine specific units of data shall we dump on each write?
open(unit=20,file=outfile,form="unformatted", access="direct", recl=irecspace, status = 'REPLACE') ! Open the unformatted binary file for writing
!open(unit=20,file=outfile,STATUS='REPLACE',IOSTAT = ioerr2) ! Open the text file and assign it a number
! Header: alpha, beta, gamma, rho, R0 --> First line of values are model parameters
!write(20,'(5e16.9)') alpha, beta, gamm, rho_in, Rm0
! First output: Format >>> t S(t) E(t) I(t) R(t)
!write(20,'(5e16.9)') t_loc(1), N_tot*yt(1:4)

rtol   = 1.d-6 ! When 0.d0, pure absolute error control
atol   = 0.d0 ! When 0.d0, pure relative error control
acc    = 1.d-6
time   = t_loc(1)

! First write, initial conditions
shp_out = (/6, 16/)
output = reshape(yt(:),shp_out)
write(20,rec=1) output*N_tot
call print_matrix('ouput: ',6,16,output)

do i = 2,nt

	dt_try = dt
!-----------------------------------------------------------------------------
! Use num. recipes rqks
!-----------------------------------------------------------------------------
	do while (abs(time-t_loc(i)) >= acc)
 	     do inod = 1,nnodes
                 ix = (inod-1)*neq
	         call derivs_agc(time,yt(ix+1:ix+neq),dydt(ix+1:ix+neq))
	         call add_nodal_interaction(time,yt,dydt,inod)
             end do
	!---------------------------------------------------------------------
	! Define scaling according to Numerical Recipes trick in Chapter 16.2 
	!---------------------------------------------------------------------
		  yt_scale = abs(yt)+abs(dt_try*dydt)
	!---------------------------------------------------------------------
	!---------------------------------------------------------------------
	          ytsv = yt
          	  dydtsv = dydt
	  	  timesv = time
	! Use Runge-Kutta 4,5 integrator to integrate 
	          call rkqs(yt,dydt,time,dt_try,rtol,yt_scale,dt_did,dt_next,derivs_agc)
	          if (time.gt.t_loc(i)) then
	        	yt   = ytsv
	        	dydt = dydtsv
	        	time = timesv
	         	dt_try = t_loc(i) - time  
	         else
	        	dt_try = dt_next
	         endif
	end do
	write(*,'(A23,I6,A8,I6,A6)') '# of completed steps = ', i, ' out of ', nt, ' steps'
      	! Time steps output: Format >>> t S(t) E(t) I(t) R(t)
	!  write(20,'(5e16.9)') t_loc(i), N_tot*yt(1:4)
	!  write(*,'(I8,A8,I8,A6)') i, ' out of ', nt, ' steps'
	output = reshape(yt(:),shp_out)
	write(20,rec=(i-1)+1) output*N_tot  ! Write out file
enddo

close(20)

end program seir_main_ageclass
