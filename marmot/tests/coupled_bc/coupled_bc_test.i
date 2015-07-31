[Mesh]
  file = square.e
[]

# Solves a pair of coupled diffusion equations where u=v on the boundary

[Variables]
  active = 'u v'

  [./u]
    order = FIRST
    family = LAGRANGE
    initial_condition = 3
  [../]

  [./v]
    order = FIRST
    family = LAGRANGE
    initial_condition = 2
  [../]
[]

[Kernels]
  active = 'diff_u diff_v'

  [./diff_u]
    type = Diffusion
    variable = u
  [../]

  [./diff_v]
    type = Diffusion
    variable = v
  [../]
[]

[BCs]
  active = 'right_v left_u'

  [./right_v]
    type = DirichletBC
    variable = v
    boundary = 2
    value = 3
  [../]

  [./left_u]
    type = MatchedValueBC
    variable = u
    boundary = 1
    v = v
    value = 3
  [../]
[]

[Executioner]
  type = Steady

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'



  nl_rel_tol = 1e-15
  l_tol = 1e-12
[]

[Outputs]
  file_base = out
  output_initial = true
  interval = 1
  exodus = true
  print_perf_log = true
[]


