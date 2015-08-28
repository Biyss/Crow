[GlobalParams]
  var_name_base = gr
  op_num = 2.0
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 60
  ny = 30
  nz = 0
  xmin = 0.0
  xmax = 30.0
  ymin = 0.0
  ymax = 15
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = -0.005
  [../]
[]

[AuxVariables]
  # [./gr0]
  # [../]
  # [./gr1]
  # [../]
  # [./df0]
  # order = CONSTANT
  # family = MONOMIAL
  # [../]
  # [./df1]
  # order = CONSTANT
  # family = MONOMIAL
  # [../]
  [./bnds]
  [../]
  [./total_en]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dF00]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dF01]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dF10]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dF11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv00]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv01]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv10]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv_div0]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadv_div1]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Preconditioning]
  active = 'SMP'
  [./PBP]
    type = PBP
    solve_order = 'w c'
    preconditioner = 'AMG ASM'
    off_diag_row = 'c '
    off_diag_column = 'w '
  [../]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Kernels]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0  gr1 '
  [../]
  [./wres]
    type = SplitCHWRes
    variable = w
    mob_name = D
  [../]
  [./time]
    type = CoupledImplicitEuler
    variable = w
    v = c
  [../]
  [./PolycrystalSinteringKernel]
    c = c
  [../]
  [./motion]
    type = MultiGrainRigidBodyMotion
    variable = w
    c = c
    v = 'gr0 gr1'
  [../]
  [./vadv_gr0]
    type = SingleGrainRigidBodyMotion
    variable = gr0
    c = c
    v = 'gr0 gr1'
  [../]
  [./vadv_gr1]
    type = SingleGrainRigidBodyMotion
    variable = gr1
    c = c
    v = 'gr0 gr1'
  [../]
[]

[AuxKernels]
  # [./df0]
  # type = MaterialStdVectorRealGradientAux
  # variable = df0
  # index = 0
  # component = 1
  # property = force_density
  # [../]
  # [./df1]
  # type = MaterialStdVectorRealGradientAux
  # variable = df1
  # index = 1
  # component = 1
  # property = force_density
  # [../]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1 '
  [../]
  [./Total_en]
    type = TotalFreeEnergy
    variable = total_en
    kappa_names = 'kappa_c kappa_op kappa_op'
    interfacial_vars = 'c  gr0 gr1'
  [../]
  [./dF00]
    type = MaterialStdVectorRealGradientAux
    variable = dF00
    property = force_density
  [../]
  [./dF01]
    type = MaterialStdVectorRealGradientAux
    variable = dF01
    property = force_density
    component = 1
  [../]
  [./dF10]
    type = MaterialStdVectorRealGradientAux
    variable = dF10
    property = force_density
    index = 1
  [../]
  [./dF11]
    type = MaterialStdVectorRealGradientAux
    variable = dF11
    property = force_density
    index = 1
    component = 1
  [../]
  [./vadv00]
    type = MaterialStdVectorRealGradientAux
    variable = vadv00
    property = advection_velocity
  [../]
  [./vadv01]
    type = MaterialStdVectorRealGradientAux
    variable = vadv01
    property = advection_velocity
    component = 1
  [../]
  [./vadv10]
    type = MaterialStdVectorRealGradientAux
    variable = vadv10
    property = advection_velocity
    index = 1
  [../]
  [./vadv11]
    type = MaterialStdVectorRealGradientAux
    variable = vadv11
    property = advection_velocity
    index = 1
    component = 1
  [../]
  [./vadv_div0]
    type = MaterialStdVectorAux
    variable = vadv_div0
    property = advection_velocity_divergence
  [../]
  [./vadv_div1]
    type = MaterialStdVectorAux
    variable = vadv_div1
    index = 1
    property = advection_velocity_divergence
  [../]
[]

[Materials]
  active = 'constant_mat CH_mat force_density_ext vadv force_density free_energy'
  [./free_energy]
    type = SinteringFreeEnergy
    block = 0
    c = c
    v = 'gr0 gr1'
    f_name = F
    derivative_order = 2
    outputs = console
  [../]
  [./CH_mat]
    type = PFDiffusionGrowth
    block = 0
    rho = c
    v = 'gr0 gr1 '
    outputs = console
  [../]
  [./force_density]
    type = ForceDensityMaterial
    block = 0
    c = c
    etas = 'gr0 gr1'
    cgb = 0.14
  [../]
  [./force_density_ext]
    type = ExternalForceDensityMaterial
    block = 0
    c = c
    k = 1.0
    force_y = load
    etas = 'gr0 gr1'
  [../]
  [./vadv]
    type = GrainAdvectionVelocity
    block = 0
    grain_force = grain_force
    etas = 'gr0 gr1'
    grain_data = grain_center
  [../]
  [./vadv_ext]
    type = GrainAdvectionVelocity
    block = 0
    grain_force = grain_force_ext
    etas = 'gr0 gr1'
    grain_data = grain_center
  [../]
  [./constant_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'A B L  kappa_op'
    prop_values = '16.0 1.0 1.0 0.5'
  [../]
  [./poreGBmaT]
    type = PoreGBPurdueMaterial
    block = 0
    Em = 0.94498
    Qs = 1.023
    GBmob0 = 3.986e-6
    surfindex = 1
    c = c
    Ds0 = 4e-6
    Qgb = 1.01
    Q = 1.0307
    T = 1000
    gbindex = 1
    GB_energy = 2.4
    surface_energy = 2.4
    Dgb0 = 4e-5
    D0 = 3.1376e-7
    int_width = 20
  [../]
[]

[VectorPostprocessors]
  [./centers]
    type = GrainCentersPostprocessor
    grain_data = grain_center
  [../]
  [./forces]
    type = GrainForcesPostprocessor
    grain_force = grain_force
  [../]
  [./forces_ext]
    type = GrainForcesPostprocessor
    grain_force = grain_force_ext
  [../]
[]

[UserObjects]
  # [./grain_force_const]
  # type = ConstantGrainForceAndTorque
  # execute_on = 'initial linear'
  # torque = '0.0 0.0 5.0 0.0 0.0 5.0'
  # force = '0.2 0.3 0.0 -0.2 -0.3 0.0'
  # [../]
  [./grain_center]
    type = ComputeGrainCenterUserObject
    etas = 'gr0 gr1'
    execute_on = 'initial linear'
  [../]
  [./grain_force]
    type = ComputeGrainForceAndTorque
    grain_data = grain_center
  [../]
  [./grain_force_ext]
    type = ComputeGrainForceAndTorque
    execute_on = 'initial linear'
    grain_data = grain_center
    force_density = force_density_ext
    force_density_derivative = dFdc_ext
  [../]
[]

[Postprocessors]
  active = 'elem_c elem_bnds bnds_avg'
  [./mat_D]
    type = ElementIntegralMaterialProperty
    mat_prop = D
  [../]
  [./elem_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
  [./elem_bnds]
    type = ElementIntegralVariablePostprocessor
    variable = bnds
  [../]
  [./bnds_avg]
    type = ElementAverageValue
    variable = bnds
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = BDF2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  l_max_its = 20
  nl_max_its = 20
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-10
  dt = 0.01
  num_steps = 10000
  end_time = 60
  [./Adaptivity]
    refine_fraction = 0.7
    coarsen_fraction = 0.1
    max_h_level = 2
    initial_adaptivity = 1
  [../]
[]

[Outputs]
  exodus = true
  output_on = 'initial timestep_end'
  print_linear_residuals = true
  csv = true
  file_base = dens_ext
  [./console]
    type = Console
    perf_log = true
    output_on = 'timestep_end failed nonlinear linear'
  [../]
[]

[ICs]
  [./ic_gr1]
    int_width = 2.0
    x1 = 15.0
    y1 = 15.0
    radius = 7.5
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./multip]
    x_positions = '15.0 15.0'
    int_width = 2.0
    z_positions = '0 0'
    y_positions = '0.0 15.0 '
    radii = '7.5 7.5'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
    type = SpecifiedSmoothCircleIC
    block = 0
  [../]
  [./ic_gr0]
    int_width = 2.0
    x1 = 15.0
    y1 = 0.0
    radius = 7.5
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
