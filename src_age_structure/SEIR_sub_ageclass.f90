module SEIR_sub

! Numerical Recipes Typecast

use nrtype ! Numerical Recipes type definitions
use global_data ! Paramter definitions
use omp_lib ! OMP runtime directives

contains

!--------------------------------------------------------------------------------------------!
! Subroutine to add nodal interaction to the time derivatives
!--------------------------------------------------------------------------------------------!
SUBROUTINE add_nodal_interaction(t,y,dydt,inod)

USE nrtype

implicit none

REAL(8), INTENT(IN)                  :: t
REAL(8), DIMENSION(:), INTENT(IN)    :: y
REAL(8), DIMENSION(:), INTENT(INOUT) :: dydt
integer, intent(in)                  :: inod

integer ingbr, ip, iq 

! for all the neighbours of the current node
ip = (inod-1)*neq
do ingbr = 1,nngbr(inod)
   iq = (ingbr-1)*neq
   dydt(ip+1:ip+neq:ncmp) = dydt(ip+1:ip+neq:ncmp) + matvec_MKL(omg,y(ip+1:ip+neq:ncmp)) 
   dydt(ip+2:ip+neq:ncmp) = dydt(ip+2:ip+neq:ncmp) + matvec_MKL(omg,y(ip+2:ip+neq:ncmp)) 
   dydt(ip+4:ip+neq:ncmp) = dydt(ip+4:ip+neq:ncmp) + matvec_MKL(omg,y(ip+4:ip+neq:ncmp)) 
   dydt(ip+5:ip+neq:ncmp) = dydt(ip+5:ip+neq:ncmp) + matvec_MKL(omg,y(ip+5:ip+neq:ncmp)) 
   dydt(ip+6:ip+neq:ncmp) = dydt(ip+6:ip+neq:ncmp) + matvec_MKL(omg,y(ip+6:ip+neq:ncmp)) 
end do

END SUBROUTINE add_nodal_interaction


!--------------------------------------------------------------------------------------------!
! Subroutine for defining ageclass model time derivatives
!--------------------------------------------------------------------------------------------!

SUBROUTINE derivs_agc(t,y,dydt)

USE nrtype

implicit none

REAL(8), INTENT(IN)                :: t
REAL(8), DIMENSION(:), INTENT(IN)  :: y
REAL(8), DIMENSION(:), INTENT(OUT) :: dydt
real(8)                            :: locdown_func
real(8), DIMENSION(nac,nac)        :: C_sl, C_wl, C_hl, C_ol
integer                            :: i


if (homo_lockdown == 1) then
!--------------------------------------------------------------------------------------------------!
! No age structure in lockdown, all contact matrices are affected equally
!--------------------------------------------------------------------------------------------------!
	locdown_func  = 1 - 0.5d0*(tanh((t-t_lck)/0.5d0) - tanh((t-t_ulck)/0.5d0))
	C_tot = locdown_func*C_s + C_h + locdown_func*C_o + locdown_func*C_w

elseif (homo_lockdown == 2) then
!--------------------------------------------------------------------------------------------------!
! Modify contact matrices for age-dependent effect of lockdown scenarios
!--------------------------------------------------------------------------------------------------!
	if ((t>t_lck).and.(t<t_ulck)) then
		do i = 1,nac
			C_sl(:,i) = w_s(i)*C_s(:,i)   ! Age-group dependent modification at school
			C_wl(:,i) = w_w(i)*C_w(:,i)   ! Age-group dependent modification at work
			C_hl(:,i) = w_h(i)*C_h(:,i)   ! Age-group dependent modification at home
			C_ol(:,i) = w_o(i)*C_o(:,i)   ! Age-group dependent modification at other locations
		enddo
	else
		C_sl(:,:) = C_s(:,:)
		C_wl(:,:) = C_w(:,:)
		C_hl(:,:) = C_h(:,:)
		C_ol(:,:) = C_o(:,:)
	endif
	C_tot = C_sl + C_hl + C_ol + C_wl
endif		
! function for defining derivatives for SEIR model
! y: Independent variables, the time series
! t: Time
! dydt: derivatives
! All proportions with respect to initial population
! yt(1:neq:ncmp) --> Intial proportion of susceptible - S_a's
! yt(2:neq:ncmp) --> Initial # of exposed - E_a's
! yt(3:neq:ncmp) --> Initial # of infected and symptomatic - I_ac's
! yt(4:neq:ncmp) --> Initial # of infected but asymptomatic - I_asc's
! yt(5:neq:ncmp) --> Initial # of recovered - R_a's
! yt(6:neq:ncmp) --> Total proportion - R_a's

dydt(1:neq:ncmp) = lambda*y(6:neq:ncmp) - beta*y(1:neq:ncmp)*matvec_MKL(C_tot,y(3:neq:ncmp)/Nis) &
  - alpha*beta*y(1:neq:ncmp)*matvec_MKL(C_tot,y(4:neq:ncmp)/Nis) - mu_n(:)*y(1:neq:ncmp)
dydt(2:neq:ncmp) = beta*y(1:neq:ncmp)*matvec_MKL(C_tot,y(3:neq:ncmp)/Nis) &
 + alpha*beta*y(1:neq:ncmp)*matvec_MKL(C_tot,y(4:neq:ncmp)/Nis) &
 - kappa(:)*y(2:neq:ncmp) - mu_n(:)*y(2:neq:ncmp)
dydt(3:neq:ncmp) = rho(:)*kappa(:)*y(2:neq:ncmp) - (gamm(:)+mu_d(:))*y(3:neq:ncmp)
dydt(4:neq:ncmp) = (1.d0-rho(:))*kappa(:)*y(2:neq:ncmp) - (gamm(:)+mu_d(:))*y(4:neq:ncmp)
dydt(5:neq:ncmp) = gamm(:)*y(3:neq:ncmp) + gamm(:)*y(4:neq:ncmp) - mu_n(:)*y(5:neq:ncmp)
dydt(6:neq:ncmp) = lambda*y(6:neq:ncmp) - mu_n(:)*(y(1:neq:ncmp)+y(2:neq:ncmp)+y(5:neq:ncmp)) &
 - mu_d(:)*(y(3:neq:ncmp)+y(4:neq:ncmp))

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
 integer 			                 :: m, k, n

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


!-----------------------------------------------------------------------------------------------------!
!-----------------------------------------------------------------------------------------------------!
!!! Printing a matrix sometimes to see whats happening in the code, taken from intel MKL, old style F77
!!!
      SUBROUTINE print_matrix(DESC, M, N, A)
      CHARACTER(len=*)           :: DESC
      INTEGER                    :: M, N, LDA
	  REAL(8)                    :: A(m,n)
	  CHARACTER(len=5)           :: ncols
	  CHARACTER(len=15)          :: FMT
      INTEGER                    :: I, J
      WRITE(*,*) DESC
	  WRITE(ncols,'(I5)') N
	  FMT = ('(')//trim(ncols)//('f10.4)')
      DO I = 1, M
         WRITE(*,adjustl(adjustr(FMT))) (A(I,J), J = 1, N)
      END DO
        
	  END subroutine PRINT_MATRIX



end module SEIR_sub
