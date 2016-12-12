[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 20
  nz = 0
  xmax = 1000
  ymax = 1000
  zmax = 0
  #skip_partitioning = true
  elem_type = QUAD4
  uniform_refine = 2
[]

[GlobalParams]
  op_num = 10
  var_name_base = gr
  grain_num = 10
[]

[Variables]
  [./c]
    #[./InitialCondition]
    #  type = FunctionIC
    #  function = 'x0:=5.0;thk:=0.5;m:=2;r:=abs(x-x0);v:=exp(-(r/thk)^m);0.1+0.1*v'
    #[../]
  [../]
  [./mu]
  [../]
  [./jx]
  [../]
  [./jy]
  [../]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./PolycrystalVariables]
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalVoronoiIC]
    [../]
  [../]
  #[./c_ic]
  #  type = FunctionIC
  #  variable = c
  #  function = gb
  #[../]
[]

[AuxVariables]
  [./gb]
    family = LAGRANGE
    order  = FIRST
  [../]
  [./creep_strain_xx]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./creep_strain_yy]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./creep_strain_xy]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./stress_xx]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./stress_yy]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./stress_xy]
    family = MONOMIAL
    order  = CONSTANT
  [../]
[]

#[Functions]
#  [./gb]
#    type = ParsedFunction
#    vars = gb
#    vals = gb
#    value = gb
#  [../]
#[]

[Kernels]
  [./conc]
    type = CHSplitConcentration
    variable = c
    mobility = mobility_prop
    chemical_potential_var = mu
  [../]
  [./chempot]
    type = CHSplitChemicalPotential
    variable = mu
    chemical_potential_prop = mu_prop
    c = c
  [../]
  [./flux_x]
    type = CHSplitFlux
    variable = jx
    component = 0
    mobility_name = mobility_prop
    mu = mu
    c = c
  [../]
  [./flux_y]
    type = CHSplitFlux
    variable = jy
    component = 1
    mobility_name = mobility_prop
    mu = mu
    c = c
  [../]
  [./time]
    type = TimeDerivative
    variable = c
  [../]
  [./PolycrystalKernel]
  [../]
  #[./PolycrystalElasticDrivingForce]
  #[../]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]
[]

[AuxKernels]
  #[./gb]
  #  type = FunctionAux
  #  variable = gb
  #  function = 'x0:=5.0;thk:=0.5;m:=2;r:=abs(x-x0);v:=exp(-(r/thk)^m);v'
  #[../]
  [./gb]
    type = BndsCalcAux
    variable = gb
    #execute_on = timestep_end
  [../]
  [./creep_strain_xx]
    type = RankTwoAux
    variable = creep_strain_xx
    rank_two_tensor = creep_strain
    index_i = 0
    index_j = 0
  [../]
  [./creep_strain_yy]
    type = RankTwoAux
    variable = creep_strain_yy
    rank_two_tensor = creep_strain
    index_i = 1
    index_j = 1
  [../]
  [./creep_strain_xy]
    type = RankTwoAux
    variable = creep_strain_xy
    rank_two_tensor = creep_strain
    index_i = 0
    index_j = 1
  [../]
  [./stress_xx]
    type = RankTwoAux
    variable = stress_xx
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
  [../]
  [./stress_yy]
    type = RankTwoAux
    variable = stress_yy
    rank_two_tensor = stress
    index_i = 1
    index_j = 1
  [../]
  [./stress_xy]
    type = RankTwoAux
    variable = stress_xy
    rank_two_tensor = stress
    index_i = 0
    index_j = 1
  [../]
[]

[Materials]
  [./chemical_potential]
    type = DerivativeParsedMaterial
    block = 0
    f_name = mu_prop
    args = c
    function = 'c'
    derivative_order = 1
  [../]
  [./var_dependence]
    type = DerivativeParsedMaterial
    block = 0
    function = 'c*(1.0-c)'
    args = c
    f_name = var_dep
    derivative_order = 1
  [../]
  [./mobility]
    type = CompositeMobilityTensor
    block = 0
    M_name = mobility_prop
    tensors = diffusivity
    weights = var_dep
    args = c
  [../]
  [./phase_normal]
    type = PhaseNormalTensor
    phase = gb
    normal_tensor_name = gb_normal
  [../]
  [./aniso_tensor]
    type = GBDependentAnisotropicTensor
    gb = gb
    bulk_parameter = 0.1
    gb_parameter = 1
    gb_normal_tensor_name = gb_normal
    gb_tensor_prop_name = aniso_tensor
  [../]
  [./diffusivity]
    type = GBDependentDiffusivity
    gb = gb
    bulk_parameter = 0.1
    gb_parameter = 1
    gb_normal_tensor_name = gb_normal
    gb_tensor_prop_name = diffusivity
  [../]
  [./diffuse_strain_increment]
    type = FluxBasedStrainIncrement
    xflux = jx
    yflux = jy
    gb = gb
    property_name = diffuse
  [../]
  [./gb_relax_prefactor]
    type = DerivativeParsedMaterial
    block = 0
    function = '0.01*(c-0.15)*gb'
    args = 'c gb'
    f_name = gb_relax_prefactor
    derivative_order = 1
  [../]
  [./gb_relax]
    type = GBRelaxationStrainIncrement
    property_name = gb_relax
    prefactor_name = gb_relax_prefactor
    gb_normal_name = gb_normal
  [../]
  [./creep_strain]
    type = SumTensorIncrements
    tensor_name = creep_strain
    coupled_tensor_increment_names = 'diffuse gb_relax'
  [../]
  [./strain]
   type = ComputeIncrementalSmallStrain
    displacements = 'disp_x disp_y'
  [../]
  [./stress]
    type = ComputeStrainIncrementBasedStress
    inelastic_strain_names = creep_strain
  [../]
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    C_ijkl = '120.0 80.0'
    fill_method = symmetric_isotropic
  [../]
  [./Copper]
    type = GBEvolution
    block = 0
    T = 500 # K
    wGB = 15 # nm
    GBmob0 = 2.5e-6 # m^4/(Js) from Schoenfelder 1997
    Q = 0.23 # Migration energy in eV
    GBenergy = 0.708 # GB energy in J/m^2
  [../]
[]

[BCs]
  [./Periodic]
    [./cbc]
      auto_direction = 'x y'
      variable = 'c gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
    [../]
  [../]
  [./fix_x]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
  [./fix_y]
    type = PresetBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  solve_type = PJFNK

  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           1'

  nl_rel_tol = 1e-10
  nl_max_its = 5

  l_tol = 1e-4
  l_max_its = 20

  dt = 1
  num_steps = 50
[]

[Preconditioning]
  [./smp]
     type = SMP
     full = true
  [../]
[]

[Outputs]
  exodus = true
[]
