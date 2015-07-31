[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 60
  xmax = 500
  elem_type = EDGE
[]

[GlobalParams]
  bulkindex = 1.0
  diffindex = 0.0
  polynomial_order = 8
[]

[Variables]
  [./c]
  [../]
  [./w]
    scaling = 1.0e2
  [../]
  [./T]
    initial_condition = 1000.0
    scaling = 1.0e8
  [../]
[]

[ICs]
  [./c_IC]
    type = SmoothCircleIC
    x1 = 125.0
    y1 = 0.0
    radius = 60.0
    invalue = 1.0
    outvalue = 0.01
    int_width = 100.0
    variable = c
  [../]
[]

[Kernels]
  [./c_res]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa
    w = w
    f_name = F
  [../]
  [./w_res]
    type = SplitCHWResGBSurfDiff
    variable = w
    c = c
    mob_name = M
  [../]
  [./w_res_Tgrad]
    type = SplitCHWResTGrad
    variable = w
    c = c
    T = T
    diff_name = D
    Q_name = Qstar
  [../]
  [./time]
    type = CoupledImplicitEuler
    variable = w
    v = c
  [../]
  [./HtCond]
    type = HeatConduction
    variable = T
  [../]
[]

[BCs]
  [./Left_T]
    type = DirichletBC
    variable = T
    boundary = left
    value = 1000.0
  [../]

  [./Right_T]
    type = DirichletBC
    variable = T
    boundary = right
    value = 1025.0
  [../]
[]

[Materials]
  [./Copper]
    type = PFParamsPolyFreeEnergy
    block = 0
    c = c
    T = T # K
    int_width = 60.0
    length_scale = 1.0e-9
    time_scale = 1.0e-9
    D0 = 3.1e-5 # m^2/s, from Brown1980
    Em = 0.71 # in eV, from Balluffi1978 Table 2
    Ef = 1.28 # in eV, from Balluffi1978 Table 2
    surface_energy = 0.708 # Total guess
  [../]
  [./UO2]
    type = MesoUO2
    block = 0
    eta = c
    temp = T
    LANL_vals = true
    Gas_conductivity = 0.5 #W/m-K (Xe)
    GBtype = 1
    outputs = exodus
  [../]
  [./free_energy]
    type = PolynomialFreeEnergy
    block = 0
    c = c
    derivative_order = 2
    T = T
  [../]
[]

[Preconditioning]
  [./SMP]
   type = SMP
   full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'

  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value =  'asm         31   preonly   lu      1'

  l_max_its = 30
  l_tol = 1.0e-4
  nl_max_its = 25
  nl_rel_tol = 1.0e-10

  num_steps = 60
  dt = 20.0
[]

[Outputs]
  output_initial = true
  interval = 1
  exodus = true
  print_linear_residuals = true
  print_perf_log = true
[]
