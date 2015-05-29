#!/usr/bin/env bats

load test_helper

#
# Test 
#
@test "png files in data dir, but they are not 8-bit" {
  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  mkdir -p "$THE_TMP/data" 2>&1
  echo "hi" > "$THE_TMP/data/foo.png"

  echo "0,1536x2048::8-RGB,," > "$THE_TMP/bin/command.tasks"

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
  [[ "${lines[1]}" == "detailed.error.message=Error Expected 8-Gray for depth and colorspace, but got 8-RGB : "* ]]

  run cat "$THE_TMP/$WORKFLOW_STATUS"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "# Seconds since"* ]]
  [[ "${lines[1]}" == "time="* ]]
  [[ "${lines[3]}" == "phase=Examining"* ]]

}


