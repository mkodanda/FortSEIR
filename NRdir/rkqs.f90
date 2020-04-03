	SUBROUTINE rkqs(y,dydx,x,htry,eps,yscal,hdid,hnext,derivs)
	USE nrtype; USE nrutil, ONLY : assert_eq,nrerror
	USE nr_bsstep, ONLY : rkck
	IMPLICIT NONE
	REAL(DP), DIMENSION(:), INTENT(INOUT) :: y
	REAL(DP), DIMENSION(:), INTENT(IN) :: dydx,yscal
	REAL(DP), INTENT(INOUT) :: x
	REAL(DP), INTENT(IN) :: htry,eps
	REAL(DP), INTENT(OUT) :: hdid,hnext
	INTERFACE
		SUBROUTINE derivs(x,y,dydx)
		USE nrtype
		IMPLICIT NONE
		REAL(DP), INTENT(IN) :: x
		REAL(DP), DIMENSION(:), INTENT(IN) :: y
		REAL(DP), DIMENSION(:), INTENT(OUT) :: dydx
		END SUBROUTINE derivs
	END INTERFACE
	INTEGER(I4B) :: ndum
	REAL(DP) :: errmax,h,htemp,xnew, NAN, arg
	REAL(DP), DIMENSION(size(y)) :: yerr,ytemp
	REAL(DP), PARAMETER :: SAFETY=0.9_dp,PGROW=-0.2_dp,PSHRNK=-0.25_dp,&
		ERRCON=1.89e-4
	arg = -1.d0
	NAN = sqrt(arg)
	ndum=assert_eq(size(y),size(dydx),size(yscal),'rkqs')
	h=htry
	do
		call rkck(y,dydx,x,h,ytemp,yerr,derivs)
		errmax=maxval(abs(yerr(:)/yscal(:)))/eps
		if (errmax <= 1.0) exit
		htemp=SAFETY*h*(errmax**PSHRNK)
		h=sign(max(abs(htemp),0.1_dp*abs(h)),h)
		xnew=x+h
		if (xnew == x) then
			y=NAN
			x=NAN
			exit
		endif
	end do
	if (errmax > ERRCON) then
		hnext=SAFETY*h*(errmax**PGROW)
	else
		hnext=5.0_dp*h
	end if
	hdid=h
	x=x+h
	y(:)=ytemp(:)
	END SUBROUTINE rkqs
