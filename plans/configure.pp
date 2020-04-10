plan nexus_bootstrap::configure(
  TargetSpec $targets,
  String $password,
  String $repo
){
  $install_nexus = run_task('nexus_bootstrap::install_nexus', $targets)
  run_task('nexus_bootstrap::choco_repo', $targets, password => $install_nexus[0]['password'], repo => $repo )
  run_task('nexus_bootstrap::write_api_key', $targets, password => $install_nexus[0]['password'] )
}
