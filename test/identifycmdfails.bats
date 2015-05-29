#!/usr/bin/env bats

load test_helper

#
# Test 
#
@test "identify command has non zero exit code" {
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath


  echo "hi" > "$THE_TMP/foo.png"

  echo "1,hi,someerror," > "$THE_TMP/bin/command.tasks"

  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_jobname jname -CWS_user joe -CWS_jobid 123 -inputPathRaw "$THE_TMP" -identifyCmd "$THE_TMP/bin/command" -CWS_outputdir $THE_TMP $WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"

  # Verify we got a workflow failed txt file
  [ -s "$THE_TMP/$WORKFLOW_FAILED_TXT" ]

  # Check output of workflow failed txt file
  run cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "$status" -eq 0 ]
  cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "${lines[0]}" == "simple.error.message=No valid images found" ]
  [[ "${lines[1]}" == "detailed.error.message=Error Unable to get image info for image $THE_TMP/foo.png : someerror"* ]]

  run cat "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "# Seconds since"* ]]
  [[ "${lines[1]}" == "time="* ]]
  [[ "${lines[3]}" == "phase=Examining"* ]]

}


