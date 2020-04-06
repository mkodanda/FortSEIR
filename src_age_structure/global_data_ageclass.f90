module global_data

! Module to contain global model parameters

implicit none

integer, parameter           :: nac = 16       ! Number of age classes
integer, parameter           :: ncmp = 6       ! Number of compartments, 6th compartment are the total population fractions
integer, parameter           :: nnodes = 3     ! number of geographic clusters/nodes
integer, parameter           :: max_ngbr = 3   ! maximum number of neighbours allowed for a node
integer, parameter           :: neq = nac*ncmp ! Number of equations per node
integer, parameter           :: totneq = neq*nnodes ! Total number of equations
integer, parameter           :: npv = 12       ! Number of parameters classified according age class
integer, PARAMETER           :: homo_lockdown = 2  ! If 1 - all contact places are impacted equally, 2 - age structured effect
real(8), dimension(nac)      :: rho, kappa, gamm, mu_n, mu_d   ! SEIR model parameters, check SEIR_main_ageclass
real(8), dimension(nac)      :: w_s, w_w, w_o, w_h, Nis, S0, I0  ! age class modifiers, population fractions and initial values
real(8)                      :: Rm0, t_lck, t_ulck, N_tot, t_tot, alpha, beta, lambda, rho_sc ! SEIR model parameters, check SEIR_main_ageclass
real(8), dimension(nac,nac)  :: C_h, C_o, C_s, C_w, C_tot  ! Contact matrices
character(len=60), parameter :: outdir = '/out/', indir = '/input/'
character(len=600)           :: cwd, infile, outfile, path_contact, out_cont  ! infile contains age classified model parameters, outfile outputs results, path_contact
character(len=600)           :: file_h, file_w, file_s, file_o ! Files for contact-matrices

integer, dimension(nnodes)           :: nngbr    ! total number of neighbours of each node
integer, dimension(nnodes,max_ngbr)  :: ngbrlst  ! list of the neighbours of each node
real(8), dimension(nac,nac)          :: omg      ! nodal interaction matrix (assume to be constant between all nodes (for now)

contains

    subroutine filenames
    implicit none
    
    CALL get_environment_variable('PWD',cwd) ! Access the current directory
    ! Path to parameter inputs
	infile = trim(cwd)//trim(indir)//('inparams_SEIR_ageclass')  ! The input parameters file
	
	! Path to contact matrices
	path_contact = trim(cwd)//trim(indir)//('mat_files_India/')  ! Path to the contact matrices for India from Prem et al.
	file_h = trim(path_contact)//('home.txt')             ! Home contacts
	file_o = trim(path_contact)//('other_locations.txt')  ! Contacts in other locations
	file_s = trim(path_contact)//('school.txt')           ! School contacts
	file_w = trim(path_contact)//('work.txt')             ! Work contacts
	file_ntp = trim(path_contact)//('nodal_topology.txt')   ! geographic nodal topology 
	
	! Path to output files	
	outfile = trim(cwd)//trim(outdir)//('pred_out')  ! The output unformatted file
	out_cont = trim(cwd)//trim(outdir)//('contact_out') ! Output containing contacts
    end subroutine filenames

end module global_data
