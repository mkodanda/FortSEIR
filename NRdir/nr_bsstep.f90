MODULE nr_bsstep
	
	INTERFACE
		SUBROUTINE bsstep(y,dydx,x,htry,eps,yscal,hdid,hnext,derivs)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(INOUT) :: y
		REAL(DP), DIMENSION(:), INTENT(IN) :: dydx,yscal
		REAL(DP), INTENT(INOUT) :: x
		REAL(DP), INTENT(IN) :: htry,eps
		REAL(DP), INTENT(OUT) :: hdid,hnext
		INTERFACE
			SUBROUTINE derivs(x,y,dydx)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP), DIMENSION(:), INTENT(IN) :: y
			REAL(DP), DIMENSION(:), INTENT(OUT) :: dydx
			END SUBROUTINE derivs
		END INTERFACE
		END SUBROUTINE bsstep
	END INTERFACE
	INTERFACE
		SUBROUTINE mmid(y,dydx,xs,htot,nstep,yout,derivs)
		USE nrtype
		INTEGER(I4B), INTENT(IN) :: nstep
		REAL(DP), INTENT(IN) :: xs,htot
		REAL(DP), DIMENSION(:), INTENT(IN) :: y,dydx
		REAL(DP), DIMENSION(:), INTENT(OUT) :: yout
		INTERFACE
			SUBROUTINE derivs(x,y,dydx)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP), DIMENSION(:), INTENT(IN) :: y
			REAL(DP), DIMENSION(:), INTENT(OUT) :: dydx
			END SUBROUTINE derivs
		END INTERFACE
		END SUBROUTINE mmid
	END INTERFACE
	INTERFACE
		SUBROUTINE pzextr(iest,xest,yest,yz,dy)
		USE nrtype
		INTEGER(I4B), INTENT(IN) :: iest
		REAL(DP), INTENT(IN) :: xest
		REAL(DP), DIMENSION(:), INTENT(IN) :: yest
		REAL(DP), DIMENSION(:), INTENT(OUT) :: yz,dy
		END SUBROUTINE pzextr
	END INTERFACE
	INTERFACE
		SUBROUTINE rkck(y,dydx,x,h,yout,yerr,derivs)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: y,dydx
		REAL(DP), INTENT(IN) :: x,h
		REAL(DP), DIMENSION(:), INTENT(OUT) :: yout,yerr
		INTERFACE
			SUBROUTINE derivs(x,y,dydx)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP), DIMENSION(:), INTENT(IN) :: y
			REAL(DP), DIMENSION(:), INTENT(OUT) :: dydx
			END SUBROUTINE derivs
		END INTERFACE
		END SUBROUTINE rkck
	END INTERFACE	
        INTERFACE
		SUBROUTINE simpr(y,dydx,dfdx,dfdy,xs,htot,nstep,yout,derivs)
		USE nrtype
		REAL(DP), INTENT(IN) :: xs,htot
		REAL(DP), DIMENSION(:), INTENT(IN) :: y,dydx,dfdx
		REAL(DP), DIMENSION(:,:), INTENT(IN) :: dfdy
		INTEGER(I4B), INTENT(IN) :: nstep
		REAL(DP), DIMENSION(:), INTENT(OUT) :: yout
		INTERFACE
			SUBROUTINE derivs(x,y,dydx)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP), DIMENSION(:), INTENT(IN) :: y
			REAL(DP), DIMENSION(:), INTENT(OUT) :: dydx
			END SUBROUTINE derivs
		END INTERFACE
		END SUBROUTINE simpr
	END INTERFACE
	INTERFACE
		SUBROUTINE lubksb(a,indx,b)
		USE nrtype
		REAL(DP), DIMENSION(:,:), INTENT(IN) :: a
		INTEGER(I4B), DIMENSION(:), INTENT(IN) :: indx
		REAL(DP), DIMENSION(:), INTENT(INOUT) :: b
		END SUBROUTINE lubksb
	END INTERFACE
	INTERFACE
		SUBROUTINE ludcmp(a,indx,d)
		USE nrtype
		REAL(DP), DIMENSION(:,:), INTENT(INOUT) :: a
		INTEGER(I4B), DIMENSION(:), INTENT(OUT) :: indx
		REAL(DP), INTENT(OUT) :: d
		END SUBROUTINE ludcmp
	END INTERFACE
	INTERFACE
		SUBROUTINE stifbs(y,dydx,x,htry,eps,yscal,hdid,hnext,derivs)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(INOUT) :: y
		REAL(DP), DIMENSION(:), INTENT(IN) :: dydx,yscal
		REAL(DP), INTENT(IN) :: htry,eps
		REAL(DP), INTENT(INOUT) :: x
		REAL(DP), INTENT(OUT) :: hdid,hnext
		INTERFACE
			SUBROUTINE derivs(x,y,dydx)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP), DIMENSION(:), INTENT(IN) :: y
			REAL(DP), DIMENSION(:), INTENT(OUT) :: dydx
			END SUBROUTINE derivs
		END INTERFACE
		END SUBROUTINE stifbs
	END INTERFACE
	INTERFACE
		SUBROUTINE stiff(y,dydx,x,htry,eps,yscal,hdid,hnext,derivs)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(INOUT) :: y
		REAL(DP), DIMENSION(:), INTENT(IN) :: dydx,yscal
		REAL(DP), INTENT(INOUT) :: x
		REAL(DP), INTENT(IN) :: htry,eps
		REAL(DP), INTENT(OUT) :: hdid,hnext
		INTERFACE
			SUBROUTINE derivs(x,y,dydx)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP), DIMENSION(:), INTENT(IN) :: y
			REAL(DP), DIMENSION(:), INTENT(OUT) :: dydx
			END SUBROUTINE derivs
		END INTERFACE
		END SUBROUTINE stiff
	END INTERFACE
	INTERFACE
		SUBROUTINE stoerm(y,d2y,xs,htot,nstep,yout,derivs)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: y,d2y
		REAL(DP), INTENT(IN) :: xs,htot
		INTEGER(I4B), INTENT(IN) :: nstep
		REAL(DP), DIMENSION(:), INTENT(OUT) :: yout
		INTERFACE
			SUBROUTINE derivs(x,y,dydx)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP), DIMENSION(:), INTENT(IN) :: y
			REAL(DP), DIMENSION(:), INTENT(OUT) :: dydx
			END SUBROUTINE derivs
		END INTERFACE
		END SUBROUTINE stoerm
	END INTERFACE
	INTERFACE
		SUBROUTINE rkqs(y,dydx,x,htry,eps,yscal,hdid,hnext,derivs)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(INOUT) :: y
		REAL(DP), DIMENSION(:), INTENT(IN) :: dydx,yscal
		REAL(DP), INTENT(INOUT) :: x
		REAL(DP), INTENT(IN) :: htry,eps
		REAL(DP), INTENT(OUT) :: hdid,hnext
		INTERFACE
			SUBROUTINE derivs(x,y,dydx)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP), DIMENSION(:), INTENT(IN) :: y
			REAL(DP), DIMENSION(:), INTENT(OUT) :: dydx
			END SUBROUTINE derivs
		END INTERFACE
		END SUBROUTINE rkqs
	END INTERFACE
	INTERFACE
		FUNCTION savgol(nl,nrr,ld,m)
		USE nrtype
		INTEGER(I4B), INTENT(IN) :: nl,nrr,ld,m
		REAL(DP), DIMENSION(nl+nrr+1) :: savgol
		END FUNCTION savgol
	END INTERFACE
	INTERFACE
	SUBROUTINE amoeba(p,y,ftol,func,iter,rtol)
		USE nrtype; USE nrutil, ONLY : assert_eq,imaxloc,iminloc,nrerror,swap
		IMPLICIT NONE
		INTEGER(I4B), INTENT(OUT) :: iter
		REAL(DP), INTENT(IN) :: ftol
		REAL(DP), INTENT(OUT):: rtol
		REAL(DP), DIMENSION(:), INTENT(INOUT) :: y
		REAL(DP), DIMENSION(:,:), INTENT(INOUT) :: p
		INTERFACE
			FUNCTION func(x)
			USE nrtype
			IMPLICIT NONE
			REAL(DP), DIMENSION(:), INTENT(IN) :: x
			REAL(DP) :: func
			END FUNCTION func
		END INTERFACE
	END SUBROUTINE
	END INTERFACE
	INTERFACE
		SUBROUTINE mnbrak(ax,bx,cx,fa,fb,fc,func)
		USE nrtype
		REAL(DP), INTENT(INOUT) :: ax,bx
		REAL(DP), INTENT(OUT) :: cx,fa,fb,fc
		INTERFACE
			FUNCTION func(x)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP) :: func
			END FUNCTION func
		END INTERFACE
		END SUBROUTINE mnbrak
	END INTERFACE
	INTERFACE
		FUNCTION brent(ax,bx,cx,func,tol,xmin)
		USE nrtype
		REAL(DP), INTENT(IN) :: ax,bx,cx,tol
		REAL(DP), INTENT(OUT) :: xmin
		REAL(DP) :: brent
		INTERFACE
			FUNCTION func(x)
			USE nrtype
			REAL(DP), INTENT(IN) :: x
			REAL(DP) :: func
			END FUNCTION func
		END INTERFACE
		END FUNCTION brent
	END INTERFACE
	INTERFACE
		SUBROUTINE linmin(p,xi,fret)
		USE nrtype
		REAL(DP), INTENT(OUT) :: fret
		REAL(DP), DIMENSION(:), TARGET, INTENT(INOUT) :: p,xi
		
		END SUBROUTINE linmin
	END INTERFACE
	INTERFACE
		SUBROUTINE powell(p,xi,ftol,iter,fret)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(INOUT) :: p
		REAL(DP), DIMENSION(:,:), INTENT(INOUT) :: xi
		INTEGER(I4B), INTENT(OUT) :: iter
		REAL(DP), INTENT(IN) :: ftol
		REAL(DP), INTENT(OUT) :: fret
		END SUBROUTINE powell
	END INTERFACE
	INTERFACE
		RECURSIVE SUBROUTINE tridag_par(a,b,c,r,u)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: a,b,c,r
		REAL(DP), DIMENSION(:), INTENT(OUT) :: u
		END SUBROUTINE tridag_par
	END INTERFACE
	INTERFACE
		SUBROUTINE tridag_ser(a,b,c,r,u)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: a,b,c,r
		REAL(DP), DIMENSION(:), INTENT(OUT) :: u
		END SUBROUTINE tridag_ser
	END INTERFACE
	INTERFACE rc
		FUNCTION rc_s(x,y)
		USE nrtype
		REAL(DP), INTENT(IN) :: x,y
		REAL(DP) :: rc_s
		END FUNCTION rc_s
!BL
		FUNCTION rc_v(x,y)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: x,y
		REAL(DP), DIMENSION(size(x)) :: rc_v
		END FUNCTION rc_v
	END INTERFACE
	INTERFACE rd
		FUNCTION rd_s(x,y,z)
		USE nrtype
		REAL(DP), INTENT(IN) :: x,y,z
		REAL(DP) :: rd_s
		END FUNCTION rd_s
!BL
		FUNCTION rd_v(x,y,z)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: x,y,z
		REAL(DP), DIMENSION(size(x)) :: rd_v
		END FUNCTION rd_v
	END INTERFACE
	INTERFACE rf
		FUNCTION rf_s(x,y,z)
		USE nrtype
		REAL(DP), INTENT(IN) :: x,y,z
		REAL(DP) :: rf_s
		END FUNCTION rf_s
!BL
		FUNCTION rf_v(x,y,z)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: x,y,z
		REAL(DP), DIMENSION(size(x)) :: rf_v
		END FUNCTION rf_v
	END INTERFACE
	INTERFACE rj
		FUNCTION rj_s(x,y,z,p)
		USE nrtype
		REAL(DP), INTENT(IN) :: x,y,z,p
		REAL(DP) :: rj_s
		END FUNCTION rj_s
!BL
		FUNCTION rj_v(x,y,z,p)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: x,y,z,p
		REAL(DP), DIMENSION(size(x)) :: rj_v
		END FUNCTION rj_v
	END INTERFACE
	INTERFACE
		FUNCTION expint(n,x)
		USE nrtype
		INTEGER(I4B), INTENT(IN) :: n
		REAL(DP), INTENT(IN) :: x
		REAL(DP) :: expint
		END FUNCTION expint
	END INTERFACE
	INTERFACE
		FUNCTION ei(x)
		USE nrtype
		REAL(DP), INTENT(IN) :: x
		REAL(DP) :: ei
		END FUNCTION ei
	END INTERFACE
	INTERFACE elle
		FUNCTION elle_s(phi,ak)
		USE nrtype
		REAL(DP), INTENT(IN) :: phi,ak
		REAL(DP) :: elle_s
		END FUNCTION elle_s
!BL
		FUNCTION elle_v(phi,ak)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: phi,ak
		REAL(DP), DIMENSION(size(phi)) :: elle_v
		END FUNCTION elle_v
	END INTERFACE
	INTERFACE ellf
		FUNCTION ellf_s(phi,ak)
		USE nrtype
		REAL(DP), INTENT(IN) :: phi,ak
		REAL(DP) :: ellf_s
		END FUNCTION ellf_s
!BL
		FUNCTION ellf_v(phi,ak)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: phi,ak
		REAL(DP), DIMENSION(size(phi)) :: ellf_v
		END FUNCTION ellf_v
	END INTERFACE
	INTERFACE ellpi
		FUNCTION ellpi_s(phi,en,ak)
		USE nrtype
		REAL(DP), INTENT(IN) :: phi,en,ak
		REAL(DP) :: ellpi_s
		END FUNCTION ellpi_s
!BL
		FUNCTION ellpi_v(phi,en,ak)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: phi,en,ak
		REAL(DP), DIMENSION(size(phi)) :: ellpi_v
		END FUNCTION ellpi_v
	END INTERFACE
	INTERFACE
		SUBROUTINE polint(xa,ya,x,y,dy)
		USE nrtype; USE nrutil, ONLY : assert_eq,iminloc,nrerror
		REAL(DP), DIMENSION(:), INTENT(IN) :: xa,ya
		REAL(DP), INTENT(IN) :: x
		REAL(DP), INTENT(OUT) :: y,dy
		END SUBROUTINE polint
	END INTERFACE
	INTERFACE
		SUBROUTINE ratint(xa,ya,x,y,dy)
		USE nrtype; USE nrutil, ONLY : assert_eq,iminloc,nrerror
		REAL(DP), DIMENSION(:), INTENT(IN) :: xa,ya
		REAL(DP), INTENT(IN) :: x
		REAL(DP), INTENT(OUT) :: y,dy
		END SUBROUTINE ratint
	END INTERFACE

	INTERFACE
		FUNCTION locate(xx,x)
		USE nrtype
		REAL(DP), DIMENSION(:), INTENT(IN) :: xx
		REAL(DP), INTENT(IN) :: x
		INTEGER(I4B) :: locate
		END FUNCTION locate
	END INTERFACE
END MODULE nr_bsstep
