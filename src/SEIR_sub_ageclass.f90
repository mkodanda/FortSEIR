module SEIR_sub

! Numerical Recipes Typecast

use nrtype ! Numerical Recipes type definitions
use global_data ! Paramter definitions
use omp_lib ! OMP runtime directives

contains

!--------------------------------------------------------------------------------------------!
! Subroutine for defining ageclass model time derivatives
!--------------------------------------------------------------------------------------------!

SUBROUTINE derivs_agc(t,y,dydt)

USE nrtype

implicit none

REAL(8), INTENT(IN) :: t
REAL(8), DIMENSION(:), INTENT(IN) :: y
REAL(8), DIMENSION(:), INTENT(OUT) :: dydt
real(8)                 :: locdown_func

locdown_func  = 0.5d0*(tanh((t-t_lck)/0.5d0) - tanh((t-t_ulck)/0.5d0))
C_tot = C_s + C_h + C_o + C_w
C_tot = locdown_func*C_tot
			
! function for defining derivatives for SEIR model
! y: Independent variables, the time series
! t: Time
! dydt: derivatives
! yt(1:neq:ncmp) --> Intial proportion of susceptible - S_a's
! yt(2:neq:ncmp) --> Initial # of exposed - E_a's
! yt(3:neq:ncmp) --> Initial # of infected and symptomatic - I_ac's
! yt(4:neq:ncmp) --> Initial # of infected but asymptomatic - I_asc's
! yt(5:neq:ncmp) --> Initial # of recovered                  - R_a's
! yt(6:neq:ncmp) --> Initial proportion of recovered                  - R_a's

dydt(1:neq:ncmp) = lambda*y(6:neq:ncmp) - beta*y(1:neq:ncmp)*matvec_MKL(C_tot,y(3:neq:ncmp)/(Nis*N_tot)) &
  - alpha*beta*y(1:neq:ncmp)*matvec_MKL(C_tot,y(4:neq:ncmp)/(Nis*N_tot)) - mu_n(:)*y(1:neq:ncmp)
dydt(2:neq:ncmp) = beta*y(1:neq:ncmp)*matvec_MKL(C_tot,y(3:neq:ncmp)/(Nis*N_tot)) + alpha*beta*y(1:neq:ncmp)*matvec_MKL(C_tot,y(4:neq:ncmp)/(Nis*N_tot)) &
 - mu_n(:)*y(2:neq:ncmp)
dydt(3:neq:ncmp) = rho(:)*kappa(:)*y(2:neq:ncmp) - (gamm(:)+mu_d(:))*y(3:neq:ncmp)
dydt(4:neq:ncmp) = (1.d0-rho(:))*kappa(:)*y(2:neq:ncmp) - (gamm(:)+mu_d(:))*y(4:neq:ncmp)
dydt(5:neq:ncmp) = gamm(:)*y(3:neq:ncmp) + gamm(:)*y(4:neq:ncmp) - mu_n(:)*y(5:neq:ncmp)
dydt(6:neq:ncmp) = lambda*y(6:neq:ncmp) - mu_n(:)*(y(1:neq:ncmp)+y(2:neq:ncmp)+y(5:neq:ncmp)) - mu_d(:)*(y(3:neq:ncmp)+y(4:neq:ncmp))

END SUBROUTINE derivs_agc

!-----------------------------------------------------------------------------------------------------!
!-----------------------------------------------------------------------------------------------------!
!!! Multithreaded matrix vector multiplication using Intel MKL library function dgemm
!!!
 function matvec_MKL(Amat,v) result(y)

 real(8), dimension(:,:), intent(in) :: Amat ! Input matrix for the matrix vector product A*v
 real(8), dimension(:), intent(in)   :: v
 real(8), dimension(size(Amat,1))    :: y ! Output vector, y = A*v
 real(8)                             :: alpha, beta ! scalars, dgemm allows for the product C = alpha*A*B + beta*C
 integer 			     :: m, k, n

 if (size(Amat,2) /= size(v)) then
	write(*,'(A,I4,A,I4)') 'size(Amat,2) = ', size(Amat,2), ', size(v) = ', size(v)
 	stop 'Matrix-vector multiplication rule violated in C=A*v, ncolA .neq. nrowv' ! Check for valid multiplication
 end if
 m = size(Amat,1); k = size(Amat,2); n = 1 ! Assigning size values
 !----------------------------------------------------------------------------!
 ! DGEMV calculates y = alpha*A*x + beta*y
 ! call dgemv(trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
 !----------------------------------------------------------------------------!
 alpha = 1.d0 ! Unscaled product
 beta  = 0.d0 ! Nothing is being added
 !----------------------------------------------------------------------------!
 CALL DGEMV('N',m,n,alpha,Amat,m,v,1,beta,y,1)
 
 end function matvec_MKL



end module SEIR_sub
